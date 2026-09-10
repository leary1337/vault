---
title: Практический Go backend-проект
description: Поэтапный reference roadmap Ads Service с PostgreSQL, Redis, Kafka и observability.
tags: [practice, go, backend, project]
updated: 2026-09-10
---

# Практический Go backend-проект

Это roadmap самостоятельного Ads Service, а не обязательное приложение внутри repository базы знаний. Реализуйте его в отдельном Git repository и фиксируйте решения в коротких ADR. Ценность проекта — доказать contracts и failure behavior, а не просто подключить десять технологий.

## Product scope

Минимальные capabilities:

- создать объявление с idempotency key;
- получить объявление;
- изменить title/description/price/status с optimistic concurrency;
- добавить/удалить объявление в favorites пользователя;
- принять просмотр и показать eventually consistent counter.

Сразу запишите non-goals: полнотекстовый поиск, billing, moderation ML, media transcoding. Иначе учебный scope станет бесконечным.

## Целевые contracts

### REST

```text
POST   /v1/ads
GET    /v1/ads/{id}
PATCH  /v1/ads/{id}        If-Match: <version>
PUT    /v1/users/{uid}/favorites/{ad_id}
DELETE /v1/users/{uid}/favorites/{ad_id}
POST   /v1/ads/{id}/views  Idempotency-Key: <event-id>
```

Определите validation, authorization, stable error codes, page/cursor contract, request limits и semantics повторов. `PATCH` возвращает conflict при stale version. Create/view mutation не должны удваивать эффект после retry.

Внутренний gRPC API можно добавить для batch get или moderation capability. Это упражнение в protobuf evolution, deadlines, canonical errors и interceptors, а не замена REST «потому что быстрее».

## Data model

PostgreSQL — source of truth:

- `ads(id, owner_id, title, description, price_minor, currency, status, version, created_at, updated_at)`;
- `favorites(user_id, ad_id, created_at)` с unique `(user_id, ad_id)`;
- `idempotency_keys(scope, key_hash, request_hash, status, response, expires_at)`;
- `outbox(id, aggregate_id, event_type, payload, created_at, published_at)`.

Money храните integer minor units + currency, timestamps — UTC instant. Foreign keys/constraints поддерживают invariants. Migrations forward/backward compatible: expand → deploy compatible code/backfill → contract. Каждая migration имеет rehearsal на production-like volume и rollback/roll-forward plan.

Redis используйте позже как cache read model/counter buffer, не как обязательный старт. Задайте key schema, TTL+jitter, memory/eviction, invalidation и behavior при недоступности. Favorites correctness остаётся в PostgreSQL.

## Event flow

В transaction создания/изменения ad запишите outbox row. Relay публикует событие в Kafka, затем отмечает row; crash между publish и mark создаёт duplicate, поэтому consumer idempotent. Event envelope содержит event ID, type/version, aggregate ID, occurred time и trace context без PII payload по умолчанию.

Для views примите at-least-once event с producer event ID. Consumer дедуплицирует ограниченное окно, агрегирует и периодически переносит delta в durable store. Определите, допустима ли потеря/задержка, как выполняется replay и reconciliation. Не обещайте exactly-once end-to-end только из-за Kafka transaction.

## Архитектурный skeleton

```text
cmd/api             composition root
internal/ads        use cases, domain, ports
internal/favorites  capability и persistence
internal/views      ingestion/aggregation
internal/platform   PostgreSQL, Redis, Kafka, telemetry adapters
migrations          versioned SQL
deploy              Docker/Kubernetes/observability config
```

Начните с [modular monolith](../backend-architecture/modular-monolith.md). Module владеет данными и public contract. Выделение process/service выполняйте только после появления независимого scaling/failure/team boundary.

## Этапы реализации

### 1. Walking skeleton

Go process, config validation, `/livez` и `/readyz`, structured logs, request ID/trace setup, graceful shutdown. HTTP server имеет read/header/idle timeouts и bounded body. CI запускает formatting, static analysis, unit tests и docs/schema checks.

### 2. PostgreSQL CRUD

Create/get/update, migrations, transactions и optimistic concurrency. Используйте parameterized SQL и least-privilege DB role. Integration tests поднимают настоящую совместимую PostgreSQL version, проверяют constraints, rollback, concurrent update и cancellation.

### 3. Idempotency и favorites

Idempotency key scoped к caller+operation, request hash обнаруживает повтор ключа с другим body; concurrent duplicates получают один authoritative result. Favorites реализуются unique constraint и идемпотентным desired-state `PUT/DELETE`.

### 4. Cache

Добавьте cache-aside для `GET ad`: bounded TTL+jitter, negative cache осторожно, request coalescing для hot miss. Измерьте hit rate и stale window. Cache failure деградирует latency, но не correctness; защитите PostgreSQL от herd.

### 5. Kafka и Outbox

Relay с leasing/batching/retry, idempotent producer по подходящему contract, consumer group и DLQ/retry policy. Тесты моделируют crash до/после publish/commit, duplicate, reorder и poison record. Lag alert основан на oldest event age.

### 6. Observability

Prometheus RED metrics по route template, pool/Kafka/cache signals и business outcomes с bounded labels. OpenTelemetry context проходит HTTP → SQL/Redis/Kafka → consumer. Logs включают trace ID, но не tokens/PII. Определите SLI: success и latency create/get/update, freshness view counter; задайте учебный SLO и burn alerts.

### 7. Packaging и Kubernetes

Multi-stage Docker image, non-root runtime, read-only filesystem где возможно, SBOM/vulnerability process. Kubernetes Deployment/Service/ConfigMap+Secret, requests/limits, startup/readiness/liveness probes, PodDisruptionBudget при необходимости и autoscaling по meaningful signal. Проверьте rolling update и node/pod termination.

## Timeout, retry и shutdown contract

Inbound request получает budget. DB/cache/gRPC/Kafka operations используют меньшие bounded deadlines, оставляя время сформировать ответ. Retry выполняет один owner только для transient и idempotent operation, с cap, exponential backoff+jitter и общим deadline. Метрики различают logical operation и attempt.

При `SIGTERM` readiness становится false, admission прекращается, HTTP/gRPC drain-ятся, consumers перестают получать новые records и завершают/commit-ят текущие, relay останавливается, telemetry flush-ится, затем pools закрываются. Весь порядок ограничен Kubernetes grace period и тестируется.

## Test strategy

- unit: domain invariants, error mapping, retry/backoff с fake clock;
- integration: PostgreSQL/Redis/Kafka contracts и migrations на real services;
- API/contract: status/error/schema/compatibility;
- concurrency: duplicate idempotency key, version conflict, view deduplication;
- fault: dependency timeout, connection exhaustion, cache loss, consumer restart;
- load/soak: SLO, pool sizing, cache herd, heap/goroutine plateau;
- security: cross-user/tenant authorization, injection, limits, secret/log checks.

Не mock-айте то, что хотите доказать о isolation, broker offsets или TTL. Unit tests дают локальную скорость; integration/fault tests доказывают boundary semantics.

## Profiling и acceptance criteria

Expose `pprof` только на authenticated internal listener. Под load снимите CPU, heap, goroutine/block profiles и сравните с baseline; profiling — средство объяснения, не оптимизация вслепую.

Проект готов к демонстрации, когда:

- clean checkout запускается одной documented командой;
- migrations и rollback/roll-forward rehearsed;
- повтор mutation не удваивает эффект;
- traces не распадаются на Kafka boundary;
- dashboards показывают SLI, RED и dependency saturation;
- forced failures имеют ожидаемую degraded behavior;
- graceful shutdown не теряет acknowledged work;
- README объясняет trade-offs и известные ограничения.

## Карта знаний

[Go backend](../go/backend/README.md) · [PostgreSQL](../databases/postgresql/README.md) · [Redis](../databases/redis/README.md) · [Kafka](../messaging/kafka/README.md) · [Outbox](../backend-patterns/transactional-outbox.md) · [Observability](../observability/README.md) · [Docker](../containers/docker/README.md) · [Kubernetes](../containers/kubernetes/README.md) · [Security](../security/README.md)


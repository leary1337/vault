# Migration report

## Статус

Миграция и все content batches завершены 2026-09-10. В `docs/` находятся 310 публичных страниц и `SUMMARY.md`; все content pages имеют URL-friendly paths, YAML metadata и navigation entry. Legacy-каталоги `Programming/`/`Templates/`, промежуточные duplicates и внешние изображения удалены после проверки; старые версии восстановимы из Git history.

## Решения

- GitBook root: `docs/`; навигация: `docs/SUMMARY.md`.
- Старые block IDs удалены после замены summary transclusions явными ссылками.
- Исходная дата сохранена как `created`; `updated` ставится только после технической проверки.
- Локальных assets в исходном Vault не было. Внешние изображения заменены self-contained text и удалены.
- Большая Kafka-заметка использована для тематического rewrite и удалена из `docs/`, чтобы не создавать второй source of truth.
- Пустая Docker-заметка удалена после создания полноценного раздела.
- Obsidian templates не являются частью Backend Knowledge Base и удалены вместе с legacy tree после проверки.

## Перемещено

- `Programming/Go/**` → `docs/go/{language,data-structures,concurrency,runtime,performance}/**`.
- `Programming/База данных/**` → `docs/databases/**`.
- `Programming/Брокеры сообщений/Kafka.md` → `docs/messaging/kafka/**` как тематический KRaft-oriented rewrite.
- `Programming/Сети/**` → `docs/networking/{fundamentals,transport,application}/**`.
- `Programming/System Design/**` → `docs/system-design/fundamentals/**`.
- Пустая Docker-заметка → `docs/containers/docker/**` как новый production-oriented section.

Точное постраничное отображение зафиксировано в [`VAULT_AUDIT.md`](VAULT_AUDIT.md).

## Удалено

- `Programming/` после успешной проверки 53 исходных Markdown-файлов против 50 содержательных target pages и трёх пересобранных index pages.
- `Templates/`: четыре файла с Obsidian Templater syntax не относились к публичной backend-базе.

## Проверки Batch 1

- 70 Markdown-файлов в `docs/`.
- 67 уникальных пунктов навигации в `docs/SUMMARY.md`.
- Нет missing local targets, Obsidian wiki-links и block IDs.
- Локальных изображений в исходном репозитории не было; внешние images позднее удалены при content rewrite.

## Batch 2 — Critical Go

Переписаны `basics`, `slice`, `map`, `interfaces`, `errors`, `panic/recover`, `goroutines`, `channels` и `sync-primitives`. Добавлены отдельные страницы про strings/bytes/runes, generics, memory model, atomics, context, data races, goroutine leaks, backpressure и graceful shutdown.

Ключевые исправления:

- `string` больше не описывается как гарантированно валидный UTF-8.
- Удалено обещание автоматического ускорения в 5–10 раз после переписывания на Go.
- Current map implementation описана через Swiss Tables; legacy `hmap` оставлена только как отрицательная историческая граница.
- Исправлен ложный deadlock example: return из `main` завершает process без ожидания goroutines.
- Generic methods отмечены как stable feature Go 1.27, а `WaitGroup.Go` — как API Go 1.25+.
- Гарантии happens-before отделены от scheduler/runtime implementation.

Primary sources: Go 1.27 release notes и specification, Go Memory Model, standard library package docs и исходный код `internal/runtime/maps`.

## Batch 3 — Go runtime и backend

Runtime-материалы переписаны для Go 1.27: G-M-P без magic constants, container-aware `GOMAXPROCS`, netpoller, escape analysis, RSS vs heap, Green Tea GC, `GOGC` и soft `GOMEMLIMIT`. Performance-раздел дополнен pprof, runtime trace/flight recorder, `B.Loop`, race detector, PGO и новым профилем `goroutineleak`.

Созданы production-oriented разделы `go/backend`, `go/grpc` и `go/testing`. Они покрывают HTTP server/client timeouts и pooling, body lifecycle, retries/idempotency, request context, protobuf evolution, gRPC status/deadlines/streaming, unit/integration/HTTP/DB tests, fuzzing и Testcontainers.

Проверено по Go 1.25–1.27 release notes, current standard library docs/source, официальным gRPC и Protocol Buffers guides и официальной документации Testcontainers for Go. На рабочей машине Go toolchain отсутствует, поэтому snippets прошли manual review, но compilation check отложен до доступности `go`.

## Batch 4a — PostgreSQL

Раздел PostgreSQL переписан и расширен до 17 страниц для PostgreSQL 18.6. Generic lock terminology заменена конкретными PostgreSQL semantics: MVCC visibility, три реально различающихся isolation level, четыре row-lock mode, table/advisory locks, deadlock monitoring и optimistic concurrency.

Добавлены query и operations tracks: index access methods и write cost, planner statistics, безопасное чтение `EXPLAIN`, joins, WAL/PITR, vacuum/freeze, physical и logical replication, declarative partitioning, pooling, keyset pagination и SQL practice. Утверждения сверены с PostgreSQL 18 official documentation; PostgreSQL 19 на дату проверки остаётся beta и не используется как baseline.

## Batch 4b — Redis

Создан раздел из 10 страниц для Redis Open Source 8.10.1: native data structures и Streams, cache-aside и invalidation races, expiration/eviction, RDB/AOF, asynchronous replication, Sentinel, Cluster, hot/big keys и distributed leases. Для Redlock явно зафиксированы assumptions и trade-offs; он не представлен как universal correctness primitive.

Проверено по Redis official documentation и current release notes. Отдельно уточнены `WAIT`/`WAITAOF` limits, Sentinel quorum vs majority, Cluster hash slots/redirects, safe token-based unlock и `DELEX` начиная с Redis 8.4.

## Batch 5a — Kafka и messaging reliability

Старая монолитная Kafka page заменена 10 проверенными страницами для Apache Kafka 4.3.1 и после финального review удалена из `docs/`. Current architecture описана как KRaft-only; уточнены sticky/adaptive unkeyed partitioning, `acks=all` относительно текущего ISR, default idempotence, classic/new consumer protocols, share groups, Kafka EOS boundaries и operations.

Добавлены Transactional Outbox и Inbox/deduplication с polling/CDC, Debezium, stable event ID и atomic database patterns. Материал проверен по Kafka 4.3 documentation, official release notes/KIPs и Debezium documentation.

## Batch 5b — Distributed systems

Создан связанный раздел из 13 страниц: consistency models, корректная область CAP/PACELC, replication, sharding/consistent hashing, quorums, consensus/leader election, clocks, distributed transactions, idempotency и failure models. Упрощение «CAP = любые две из трёх» также исправлено в старой database fundamentals page.

Страницы построены вокруг явных scope и failure assumptions; использованы первичные papers Raft/Paxos, Dynamo, Spanner, Lamport clocks, linearizability, PACELC и Sagas.

## Batch 5c — Backend patterns

Создан каталог из 15 страниц с единым decision-oriented форматом: problem, mechanism, guarantees, failure modes, trade-offs, when not to use и example. Покрыты idempotency/retries/jitter, circuit breaker/bulkhead, rate limiting/load shedding/backpressure, Saga/Outbox/CQRS, cache-aside/singleflight и fenced distributed locks.

Дублирование с database/messaging/distributed sections ограничено короткими прикладными summaries и cross-links; каждый pattern явно описывает, какую проблему он не решает.

## Batch 6a — System Design

Четыре старые словарные страницы (~160 KB) заменены 17 небольшими fundamentals, общим 15-шаговым design process и 10 case studies. Старые файлы удалены из `docs/` после переноса тем; они остаются восстановимыми из Git history.

Cases покрывают URL shortener, rate limiter, notifications, counters, file storage, chat, feed, autocomplete, favorites и classifieds. Каждый разбор включает requirements, paths, failure modes, alternatives и trade-offs вместо одной «правильной» схемы.

## Batch 6b — Algorithms

Создан раздел из 20 страниц: complexity, 17 reusable algorithm/data-structure patterns и Go examples. Каждая pattern page объясняет recognition, invariant/template, complexity, mistakes и practice tasks без dump готовых решений.

Go page содержит 10 annotated examples из спецификации: in-place deduplication, intervals, Unicode-aware sliding window, lower bound, Top K/heap, BFS/DFS, LRU и cancellable worker pool. Go toolchain на машине отсутствует, поэтому compilation validation остаётся недоступной; syntax и edge cases проверены вручную.

## Batch 7a — Linux

Создан Linux minimum из 14 страниц: process/thread/syscall, FD/signals, virtual memory/RSS/page cache, sockets/epoll, CPU/load average, cgroup v2, namespaces и ordered debugging workflow. Команды `ps`, `top`/`htop`, `ss`, `lsof`, `strace`, `perf`, `vmstat`, `iostat`, `free` и `dmesg` встроены в диагностический контекст, а не перечислены без цели.

Материал проверен по актуальным Linux man-pages и kernel documentation; отдельно разведены syscall vs context switch, RSS vs cgroup memory, CPU utilization vs load average и cgroup quota throttling.

## Batch 7b — Docker

Пустая Docker page полностью переписана в раздел из 9 страниц; legacy placeholder удалён из `docs/` и остаётся в Git history. Покрыты OCI-style images/layers, BuildKit cache/context/secrets, Dockerfile command semantics, networking, storage, cgroup resources, PID 1/signals, security и production Go multi-stage image.

Production example использует Go 1.27.1 builder, separate test/build stages, BuildKit caches, `CGO_ENABLED=0`, distroless non-root runtime и exec-form entrypoint; digest pinning оставлено обязательным deployment policy без выдуманного digest.

## Batch 7c — Kubernetes

Создан раздел из 12 страниц для Kubernetes 1.37: Pod/Deployment/Service/Ingress, ConfigMap/Secret, requests/limits, probes, HPA, graceful termination, networking и troubleshooting. Чётко разведены readiness/liveness/startup, requests vs limits, CPU throttling vs memory OOM и core contracts vs CNI/Ingress/provider implementations.

Go runtime связан с container-aware `GOMAXPROCS`, cgroup CPU quota, soft `GOMEMLIMIT`, memory headroom и bounded HTTP/gRPC/consumer shutdown. Материал проверен по официальной документации Kubernetes 1.37.

## Batch 7d — Observability, architecture, security и production

Добавлены Observability/OpenTelemetry, metrics/logs/traces, SLI/SLO/SLA, burn-rate alerting и production debugging. Architecture section сравнивает layered/hexagonal/clean/modular approaches через boundaries и trade-offs. Security охватывает authentication/authorization, sessions/tokens, OAuth/OIDC/JWT, password hashing, TLS, secrets, CORS/CSRF/SSRF/injection/path traversal и rate/resource controls.

Production section содержит incident response и 10 symptom runbooks. Каждая diagnostic page проверена на одинаковый порядок `Symptoms → Possible causes → What to measure → Diagnostics → Tools → Immediate mitigation → Root cause → Prevention`. Источники: OpenTelemetry/Prometheus/Google SRE, OWASP Top 10:2025/ASVS, RFC 8446/8725/9700 и профильные primary docs.

## Practice и interviews

Ads Service оформлен как reference roadmap отдельного учебного repository: Go/PostgreSQL/Redis/Kafka, REST/gRPC, Outbox/idempotency, tests, telemetry, profiling, Docker/Kubernetes и graceful lifecycle.

Interview section ссылается на основной контент вместо его копирования. Avito process описан только по публичным AvitoTech materials, проверенным 2026-09-10: публично подтверждены programming/platform, senior system design и final context, но variation по вакансии/уровню отмечена явно.

## Networking и final quality review

Protocol pages TCP/UDP/QUIC, DNS, HTTP/1.1–3, TLS и HTTPS переписаны по актуальным IETF RFC. Добавлены connection establishment/states, TIME_WAIT, keepalive/pools/ephemeral ports, DNS caching, TLS handshake, HTTP multiplexing/HOL, reverse proxy/load balancing и L4/L7.

Финальный проход удалил external Markdown images и hidden Kafka duplicate, исправил слабые Go concurrency/struct, database и networking fundamentals, добавил полезные cross-links и README для каждого content directory. Lightweight PowerShell check теперь проверяет local links/images, frontmatter fields, URL-friendly paths, Obsidian constructs, SUMMARY completeness/duplicates/orphans и directory indexes.

## Источник конфигурации

Синтаксис `.gitbook.yaml` проверен по [официальной документации GitBook](https://gitbook.com/docs/getting-started/git-sync/content-configuration): пути `structure` считаются относительно `root`.

## Mapping

Полная историческая таблица source → target и resolution log находятся в `VAULT_AUDIT.md`.

# Senior review: архитектура, распределённые системы и эксплуатация

Дата содержательного обзора: 2026-10-06. Все страницы перечисленных ниже областей прочитаны; самостоятельные статьи получили конкретные примеры и вопросы с раскрываемыми ориентирами ответов. Навигационные README сохранены тематическими, пути файлов не менялись. Схемы вручную написаны в Mermaid: AI-изображения и чужие raster assets не добавлялись.

## Что проверялось

- HTTP: If-Match/412, отличие 409 и 428, методы, redirects и явно заданное кэширование — RFC 9110/6585; Problem Details — RFC 9457.
- PostgreSQL: baseline 18, ограничения/ON CONFLICT, snapshot Read Committed, условный UPDATE, lock/sequence semantics. В новых примерах не предполагается отсутствие sequence gaps.
- Consensus: commit entry текущего term в Raft, зависимость strict reads от актуального лидерства и применённого префикса; election не fence произвольный внешний ресурс.
- Kafka 4.3: дополнительно открыт актуальный раздел Design, сверены Consumer Position, Message Delivery Semantics и Using Transactions. Ранее просмотренная 4.1 не использована как доказательство новых настроек 4.3; конкретные broker/client настройки проверяются в журнале данных/сообщений.
- Delivery: Outbox/Inbox не обещают exactly once внешнего эффекта; порядок parallel relay, consumer checkpoint и сумма вместе, безопасный replay новой версии агрегатов.
- Go: singleflight Do/DoChan/Forget; typed nil interface; общие ресурсы composition root; HTTP Shutdown не управляет hijacked connections; Ticker.Stop не закрывает C.
- Metrics: classic histogram с rate до aggregation; p99 нельзя усреднить; SLO request budget отличается от времени uptime; burn ratios; bounded labels.
- Runbooks: каждый новый incident содержит учебные показатели, минимум две различимые гипотезы/свидетельства и проверку mitigation. pprof/EXPLAIN вывод помечен иллюстративным.

## Первичные источники, открытые при обзоре

- [HTTP semantics](https://www.rfc-editor.org/rfc/rfc9110.html), [additional statuses](https://www.rfc-editor.org/rfc/rfc6585.html), [Problem Details](https://www.rfc-editor.org/rfc/rfc9457.html), [HTTP/2](https://www.rfc-editor.org/rfc/rfc9113.html).
- [PostgreSQL 18 isolation](https://www.postgresql.org/docs/18/transaction-iso.html), [locking](https://www.postgresql.org/docs/18/explicit-locking.html), [EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html), [statistics](https://www.postgresql.org/docs/18/monitoring-stats.html), [UPDATE](https://www.postgresql.org/docs/18/sql-update.html).
- [Raft paper](https://raft.github.io/raft.pdf), [etcd 3.6 API guarantees](https://etcd.io/docs/v3.6/learning/api_guarantees/).
- [S3 multipart](https://docs.aws.amazon.com/AmazonS3/latest/userguide/mpuoverview.html), [S3 overview](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html), [Elasticsearch pagination](https://www.elastic.co/docs/reference/elasticsearch/rest-apis/paginate-search-results).
- [singleflight API](https://pkg.go.dev/golang.org/x/sync/singleflight), [Go diagnostics](https://go.dev/doc/diagnostics), [Go module layout](https://go.dev/doc/modules/layout).
- [Kafka 4.3 design](https://kafka.apache.org/43/design/design/), [OTel sampling](https://opentelemetry.io/docs/concepts/sampling/), [Prometheus histograms](https://prometheus.io/docs/practices/histograms/), [Linux cgroup v2](https://docs.kernel.org/admin-guide/cgroup-v2.html).
- [Google SRE overload](https://sre.google/sre-book/handling-overload/), [cascading failures](https://sre.google/sre-book/addressing-cascading-failures/), [burn alerts](https://sre.google/workbook/alerting-on-slos/).
- [Автор Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture), [CQRS](https://martinfowler.com/bliki/CQRS.html), [Debezium Outbox](https://debezium.io/documentation/reference/stable/transformations/outbox-event-router.html), [Unicode normalization](https://www.unicode.org/reports/tr15/).
- [Автор Service Layer](https://martinfowler.com/eaaCatalog/serviceLayer.html), [автор Repository](https://martinfowler.com/eaaCatalog/repository.html).

Ссылки на дополнительные конкретные механизмы размещены в статьях. Не все исторические источники были повторно открыты: foundational papers сохраняют описание модели, но не доказывают параметры современной production deployment.

## Выполненные проверки и пределы

- Inventory/self-check: программно проверено наличие раздела вопросов на каждой самостоятельной странице, число схем и сохранение путей.
- Арифметика примеров: отдельно пересчитаны collision pairs Base62, поток сообщений/фото и несколько queue/retention оценок; числа описаны как допущения, не замеры Avito.
- check-docs запущен в совместном рабочем дереве: на момент первого запуска ошибки относились только к ещё создававшимся algorithm pages. Это не объявлялось финальным успешным результатом; окончательный общий запуск выполняется координатором после завершения всех edits.
- Go: `4` fenced snippets синтаксически разобраны gofmt (частичные statements обёрнуты тестовой функцией); это не compile/type-check и не runtime test.
- SQL, PromQL и фрагменты wiring в этих страницах — учебные фрагменты, не запускаемый проект. Внешние PostgreSQL/Kafka/Redis, настоящий load test, profiler и chaos test здесь не запускались.
- Рендер Mermaid проверяется координатором отдельно; данный журнал не приписывает агенту выполненный renderer test.
- Актуальность означает указанные стандарты/документы на дату обзора и явно названные baselines, а не проверку каждого возможного SDK/конфигурации и не гарантию полного совпадения с неизвестным интервью.

## Покрытие страниц

Всего 91 Markdown-страниц, 82 самостоятельных статей.

### backend-architecture

- `docs/backend-architecture/api-design.md`
- `docs/backend-architecture/clean-architecture.md`
- `docs/backend-architecture/dependency-injection.md`
- `docs/backend-architecture/hexagonal-architecture.md`
- `docs/backend-architecture/layered-architecture.md`
- `docs/backend-architecture/modular-monolith.md`
- `docs/backend-architecture/monolith-vs-microservices.md`
- `docs/backend-architecture/README.md`
- `docs/backend-architecture/repository-pattern.md`
- `docs/backend-architecture/service-layer.md`

### backend-patterns

- `docs/backend-patterns/backpressure.md`
- `docs/backend-patterns/bulkhead.md`
- `docs/backend-patterns/cache-aside.md`
- `docs/backend-patterns/circuit-breaker.md`
- `docs/backend-patterns/cqrs.md`
- `docs/backend-patterns/distributed-locks.md`
- `docs/backend-patterns/exponential-backoff-and-jitter.md`
- `docs/backend-patterns/idempotency.md`
- `docs/backend-patterns/load-shedding.md`
- `docs/backend-patterns/rate-limiting.md`
- `docs/backend-patterns/README.md`
- `docs/backend-patterns/retries.md`
- `docs/backend-patterns/saga.md`
- `docs/backend-patterns/singleflight.md`
- `docs/backend-patterns/transactional-outbox.md`

### distributed-systems

- `docs/distributed-systems/cap-and-pacelc.md`
- `docs/distributed-systems/clocks-and-ordering.md`
- `docs/distributed-systems/consensus.md`
- `docs/distributed-systems/consistency-models.md`
- `docs/distributed-systems/consistent-hashing.md`
- `docs/distributed-systems/distributed-transactions.md`
- `docs/distributed-systems/failure-models.md`
- `docs/distributed-systems/idempotency.md`
- `docs/distributed-systems/leader-election.md`
- `docs/distributed-systems/quorums.md`
- `docs/distributed-systems/README.md`
- `docs/distributed-systems/replication.md`
- `docs/distributed-systems/sharding.md`

### system-design

- `docs/system-design/cases/chat.md`
- `docs/system-design/cases/classifieds-ads.md`
- `docs/system-design/cases/favorites.md`
- `docs/system-design/cases/feed.md`
- `docs/system-design/cases/file-storage.md`
- `docs/system-design/cases/notification-service.md`
- `docs/system-design/cases/rate-limiter.md`
- `docs/system-design/cases/README.md`
- `docs/system-design/cases/search-autocomplete.md`
- `docs/system-design/cases/url-shortener.md`
- `docs/system-design/cases/view-counter.md`
- `docs/system-design/fundamentals/api-design.md`
- `docs/system-design/fundamentals/backpressure.md`
- `docs/system-design/fundamentals/caching.md`
- `docs/system-design/fundamentals/capacity-estimation.md`
- `docs/system-design/fundamentals/consistency.md`
- `docs/system-design/fundamentals/data-modeling.md`
- `docs/system-design/fundamentals/failure-handling.md`
- `docs/system-design/fundamentals/idempotency.md`
- `docs/system-design/fundamentals/load-balancing.md`
- `docs/system-design/fundamentals/non-functional-requirements.md`
- `docs/system-design/fundamentals/observability.md`
- `docs/system-design/fundamentals/rate-limiting.md`
- `docs/system-design/fundamentals/README.md`
- `docs/system-design/fundamentals/replication.md`
- `docs/system-design/fundamentals/requirements.md`
- `docs/system-design/fundamentals/retries.md`
- `docs/system-design/fundamentals/security.md`
- `docs/system-design/fundamentals/sharding.md`
- `docs/system-design/README.md`
- `docs/system-design/system-design-process.md`

### practice

- `docs/practice/go-backend-project.md`
- `docs/practice/README.md`

### observability

- `docs/observability/alerting.md`
- `docs/observability/logs.md`
- `docs/observability/metrics.md`
- `docs/observability/opentelemetry.md`
- `docs/observability/production-debugging.md`
- `docs/observability/README.md`
- `docs/observability/sli-slo-sla.md`
- `docs/observability/tracing.md`

### production

- `docs/production/connection-pool-exhaustion.md`
- `docs/production/database-overload.md`
- `docs/production/goroutine-leak.md`
- `docs/production/high-cpu.md`
- `docs/production/high-latency.md`
- `docs/production/high-memory.md`
- `docs/production/incident-response.md`
- `docs/production/kafka-lag.md`
- `docs/production/memory-leak.md`
- `docs/production/README.md`
- `docs/production/retry-storm.md`
- `docs/production/thundering-herd.md`

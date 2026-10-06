# Senior review: базы данных, сообщения, алгоритмы и интервью

Проверка и содержательные изменения: **6 октября 2026**, Europe/Moscow. Это журнал выполненной работы и её ограничений, не заявление о полном знании закрытого банка вопросов Avito.

## Покрытие

Прочитаны и дополнены все исходные страницы в `docs/databases/**`, `docs/messaging/**`, `docs/algorithms/**`, `docs/interviews/**`. После добавлений: **73 Markdown-страницы, 64 тематические leaf-статьи**. У всех 64 есть самостоятельное объяснение, разобранный пример/сценарий и минимум два вопроса; ответы скрыты в `<details>`. **39 Mermaid-схем** написаны вручную, чужие изображения и генерация картинок не использовались. Сохранены существующие пути и полезные исходные объяснения; новые темы не задают порядок чтения.

- PostgreSQL: архитектура, MVCC, изоляция, транзакции, locks, WAL, indexes, EXPLAIN, planner, joins, pagination, partitioning, pooling, replication, vacuum, SQL-задачи.
- Redis: структуры, caching, locks/fencing, expiration/eviction, hot/big keys, persistence, replication, Sentinel, Cluster.
- Kafka: архитектура, partitions/ISR, producer, consumer, groups, delivery semantics, transactions/LSO, KRaft, operations; inbox/outbox.
- Алгоритмы: arrays/slices, complexity, two pointers, window, prefix sums, hash tables, stack, queue/deque, heap, intervals, lists, trees, graphs, BFS/DFS, binary search, greedy, sorting, Go examples.
- Интервью: screening, programming, platform, system design, final, mocks и тематический указатель.
- Новые темы: `docs/algorithms/dynamic-programming.md`, `docs/algorithms/backtracking.md`, `docs/algorithms/examples/README.md` и его исполняемый Go-модуль. DP и backtracking закрывают самостоятельные фундаментальные методы, ранее только упоминавшиеся; это не новый roadmap.

## Версии и первичные источники

| Область | Проверенная база | Основание |
| --- | --- | --- |
| PostgreSQL | 18.6; PostgreSQL 19 на странице проекта ещё beta | [18.6 release notes](https://www.postgresql.org/docs/18/release-18-6.html), [release archive](https://www.postgresql.org/docs/release/) |
| Redis Open Source | 8.10.2, опубликован 17 сентября 2026 | [Архив redis.io](https://download.redis.io/releases/), [8.10 release notes](https://redis.io/docs/latest/operate/oss_and_stack/stack-with-enterprise/release-notes/redisce/redisos-8.10-release-notes/) |
| Kafka | 4.3.1 | [Downloads](https://kafka.apache.org/community/downloads/), [4.3.1 announcement](https://kafka.apache.org/blog/2026/06/25/apache-kafka-4.3.1-release-announcement/) |
| Go companion | Go 1.27 language; реально запускался compiler 1.27.1, dependency x/sync v0.23.0 | [Go spec](https://go.dev/ref/spec), [errgroup API](https://pkg.go.dev/golang.org/x/sync/errgroup) |
| Avito | Публичный playbook, просмотренный 6 октября | [Recruitment](https://github.com/avito-tech/playbook/blob/master/recruitment-and-office.md), [Developer profiles](https://github.com/avito-tech/playbook/blob/master/developer-profile.md) |

PG18.5 не выпускалась: 18.6 notes прямо описывают это. Redis release notes на момент просмотра перечисляют 8.10.0/8.10.1, а файл 8.10.2 подтверждён официальным архивом; не выдумывался список исправлений 8.10.2. Java producer/consumer settings отделены от API и defaults Go-библиотек. Версии выше — текущая проверенная baseline данного раздела, не требование к кластерам читателя.

Ключевые источники проверяемых механизмов:

- PostgreSQL18: [isolation](https://www.postgresql.org/docs/18/transaction-iso.html), [locking](https://www.postgresql.org/docs/18/explicit-locking.html), [HOT](https://www.postgresql.org/docs/18/storage-hot.html), [multicolumn indexes](https://www.postgresql.org/docs/18/indexes-multicolumn.html), [EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html), [planner statistics](https://www.postgresql.org/docs/18/planner-stats.html), [PREPARE](https://www.postgresql.org/docs/18/sql-prepare.html), [vacuum](https://www.postgresql.org/docs/18/routine-vacuuming.html), [vacuum settings](https://www.postgresql.org/docs/18/runtime-config-vacuum.html), [partitioning](https://www.postgresql.org/docs/18/ddl-partitioning.html), [streaming replication](https://www.postgresql.org/docs/18/warm-standby.html), [WAL](https://www.postgresql.org/docs/18/wal.html), [table expressions](https://www.postgresql.org/docs/18/queries-table-expressions.html), [windows](https://www.postgresql.org/docs/18/tutorial-window.html).
- [PgBouncer compatibility](https://www.pgbouncer.org/features.html): protocol-level prepared statements не равны SQL PREPARE, support зависит от configuration.
- Redis: [transactions](https://redis.io/docs/latest/develop/using-commands/transactions/), [DELEX](https://redis.io/docs/latest/commands/delex/), [locks](https://redis.io/docs/latest/develop/clients/patterns/distributed-locks/), [eviction](https://redis.io/docs/latest/develop/reference/eviction/), [EXPIRE](https://redis.io/docs/latest/commands/expire/), [SCAN](https://redis.io/docs/latest/commands/scan/), [persistence](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/), [WAIT](https://redis.io/docs/latest/commands/wait/), [WAITAOF](https://redis.io/docs/latest/commands/waitaof/), [Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/), [Cluster spec](https://redis.io/docs/latest/operate/oss_and_stack/reference/cluster-spec/).
- Kafka4.3: [design](https://kafka.apache.org/43/design/design/), [producer configuration](https://kafka.apache.org/43/configuration/producer-configs/), [consumer configuration](https://kafka.apache.org/43/configuration/consumer-configs/), [rebalance protocol](https://kafka.apache.org/43/operations/consumer-rebalance-protocol/), [consumer API](https://kafka.apache.org/43/javadoc/org/apache/kafka/clients/consumer/KafkaConsumer.html).
- [Debezium outbox router](https://debezium.io/documentation/reference/stable/transformations/outbox-event-router.html): граница CDC/route и дополнительная эксплуатационная стоимость.
- Алгоритмы: собственные числовые трассы и доказательства; библиотечные контракты сверены по [heap](https://pkg.go.dev/container/heap), [sort](https://pkg.go.dev/sort), [slices](https://pkg.go.dev/slices). [MIT 6.006](https://ocw.mit.edu/courses/6-006-introduction-to-algorithms-spring-2020/pages/lecture-notes/) дан как первичный указатель фундаментальных DP-материалов; картинки/текст лекций не копировались.

## Исправления существенных границ

- Kafka read_uncommitted возвращает и aborted records; исправлено ошибочное утверждение об их пропуске. transaction.timeout.ms — producer setting, broker ограничивает transaction.max.timeout.ms; abort не перематывает consumer position автоматически.
- Cache TTL ограничивает жизнь заполненной записи, а не безусловный возраст данных от изменения БД. Медленный reader после invalidation разобран временной схемой.
- Keyset и верхняя граница не дают immutable snapshot изменяемых строк; смешанные направления и NULL требуют отдельных условий.
- PostgreSQL Merge Join не объявлен универсальным алгоритмом произвольного range join. Уточнены HOT/summarizing-index исключения, SPI/40001 против deadlocks/40P01, visibility map, estimates против Limit и per-loop метрики.
- WAIT связан с одним клиентским соединением и не отменяет SET при timeout; ownership token отличается от fencing. Асинхронный INCR без модели сохранности не объявлен корректным fencing generator.
- Outbox SKIP LOCKED не объявлен гарантией per-aggregate ordering; publish outside/inside transaction и lease recovery имеют явные trade-offs.
- Avito playbook отделён от исторических публикаций и авторских mock-задач. Закрытые вопросы и абсолютное совпадение любой вакансии не заявляются.

## Реальные проверки

1. `pwsh -NoProfile -File scripts/check-docs.ps1` после интеграции навигации: **PASS, 316 Markdown, 315 SUMMARY entries** (состояние всего репозитория может ещё меняться параллельными агентами).
2. `git -c core.safecrlf=false diff --check`: PASS.
3. `docs/algorithms/examples`: `gofmt -w algorithms.go algorithms_test.go`, `go mod tidy`, `go test -v ./...` на Windows amd64, Go1.27.1: **17 тестов PASS**. Проверены все десять прежних Go-примеров плюс DP, backtracking, prefix-count, TwoSum, sorting; нижняя граница/счёт отрезков сравниваются с простым эталоном на наборах случаев. Тесты cancellation используют открытый пустой jobs channel, deadline теста2s и проверку возвращённой ошибки. LRU snapshot/eviction, heap.Fix, Unicode, empty и obstacle случаи проверяются отдельно.
4. Markdown Go-блоки синхронизированы с companion declarations после gofmt; утверждение прежней статьи «toolchain отсутствует, не компилировалось» заменено фактической записью. Worker pool требует ненулевые jobs и кооперативную отмену.
5. Инвентаризация своего scope: 73 pages, 64 leaves, у всех self-check и скрытые ответы, 39 Mermaid. Внешние источники не цитировались длинными заимствованными фрагментами.

## Ограничения

Docker, psql и redis-cli в PATH не обнаружены; PostgreSQL/Redis/Kafka commands **не запускались**. SQL примеры и двухсессионные расписания сверены вручную и с документацией; EXPLAIN-числа явно обозначены учебными, не измеренными. Внешние кластеры не создавались и production configuration не менялась. Race detector для companion не запускался; обычные тесты не считаются доказательством отсутствия всех races. Mermaid проверены по текстовой структуре и смыслу, финальный GitBook-render не выполнялся.

Открытие отдельных Redis Streams/Kafka Queues страниц через web-tool вернуло внутреннюю ошибку; основные гарантии Kafka consumer и delivery проверены через доступные configuration/API/design источники, эти временные ошибки не выданы за сломанные URL. Все детали каждой ссылки и весь набор client-specific flags не тестировались. Общие темы дополнены для читабельности, но читатель должен проверять конкретную server/client version перед эксплуатацией.

# Migration report

## Статус

Batch 1 завершён. 50 содержательных страниц перенесены в `docs/` с URL-friendly путями; три index pages пересобраны без Obsidian transclusions. После проверки полноты mapping и ссылок legacy-каталоги `Programming/` и `Templates/` удалены. Старые версии остаются восстановимыми из Git history.

## Решения

- GitBook root: `docs/`; навигация: `docs/SUMMARY.md`.
- Старые block IDs удалены после замены summary transclusions явными ссылками.
- Исходная дата сохранена как `created`; `updated` ставится только после технической проверки.
- Локальных assets в исходном Vault не было. Внешние изображения пока учтены как migration debt; они не копируются автоматически.
- Большая Kafka-заметка сохранена вне публичной навигации как `legacy-overview.md` до тематического rewrite.
- Пустая Docker-заметка сохранена вне публичной навигации как свидетельство rewrite decision.
- Obsidian templates не являются частью Backend Knowledge Base и удалены вместе с legacy tree после проверки.

## Перемещено

- `Programming/Go/**` → `docs/go/{language,data-structures,concurrency,runtime,performance}/**`.
- `Programming/База данных/**` → `docs/databases/**`.
- `Programming/Брокеры сообщений/Kafka.md` → `docs/messaging/kafka/legacy-overview.md` как непубличный source material.
- `Programming/Сети/**` → `docs/networking/{fundamentals,transport,application}/**`.
- `Programming/System Design/**` → `docs/system-design/fundamentals/**`.
- Пустая Docker-заметка → `docs/containers/docker/legacy-note.md` как непубличное migration record.

Точное постраничное отображение зафиксировано в [`VAULT_AUDIT.md`](VAULT_AUDIT.md).

## Удалено

- `Programming/` после успешной проверки 53 исходных Markdown-файлов против 50 содержательных target pages и трёх пересобранных index pages.
- `Templates/`: четыре файла с Obsidian Templater syntax не относились к публичной backend-базе.

## Проверки Batch 1

- 70 Markdown-файлов в `docs/`.
- 67 уникальных пунктов навигации в `docs/SUMMARY.md`.
- Нет missing local targets, Obsidian wiki-links и block IDs.
- Локальных изображений в исходном репозитории не было; внешний image debt записан в backlog и audit.

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

## Источник конфигурации

Синтаксис `.gitbook.yaml` проверен по [официальной документации GitBook](https://gitbook.com/docs/getting-started/git-sync/content-configuration): пути `structure` считаются относительно `root`.

## Mapping

Полная таблица source → target находится в `VAULT_AUDIT.md`; последующие технические объединения и удаления будут добавляться после каждого batch.

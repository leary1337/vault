# Vault audit

Аудит начат 2026-09-10 перед удалением legacy paths. Он охватывает Markdown в `Programming/`, Obsidian templates, root files, ссылки и assets.

## Сводка

- 58 Markdown-файлов до миграции: 53 в `Programming/`, 4 Obsidian templates и корневой README.
- 0 локальных изображений.
- Wiki-links `[[...]]` не найдены.
- Найдены Markdown-transclusions на Obsidian block IDs в index pages Go и Networking.
- Найдены block IDs в содержательных страницах.
- Внешние изображения размещены преимущественно на Imgur; это migration debt.
- Все исходные заметки имели Obsidian-oriented frontmatter с русским нестандартным ключом даты.

## Реестр

| Source path | Target path | Status | Problems | Action | Priority |
|---|---|---|---|---|---|
| `README.md` | `README.md` | UPDATE | Не описывал проект | Переписан для GitHub и GitBook workflow | P0 |
| `Programming/Go/!Краткое содержание.md` | `docs/go/README.md` | MERGE | Block transclusions, непубличные IDs | Заменён index page с явными ссылками | P0 |
| `Programming/Go/Основы языка Go.md` | `docs/go/language/basics.md` | REWRITE | Неверные performance claims; string назван валидным UTF-8; субъективные обобщения | Мигрирован, затем переписать в Batch 2 | P0 |
| `Programming/Go/Функции и методы/Функции.md` | `docs/go/language/functions.md` | UPDATE | Базовый материал, мало ограничений и ссылок | Мигрирован; дополнить гарантиями | P1 |
| `Programming/Go/Функции и методы/Замыкания.md` | `docs/go/language/closures.md` | UPDATE | Нет capture/escape/concurrency нюансов | Мигрирован; дополнить | P1 |
| `Programming/Go/Функции и методы/Методы.md` | `docs/go/language/methods.md` | UPDATE | Нет method sets и addressability | Мигрирован; связать с interfaces | P0 |
| `Programming/Go/Ошибки и паники/Обработка ошибок.md` | `docs/go/language/errors.md` | UPDATE | Нет Join, boundaries, retryability и logging ownership | Мигрирован; актуализировать | P0 |
| `Programming/Go/Ошибки и паники/Паники.md` | `docs/go/language/defer-panic-recover.md` | UPDATE | Недостаточно точно описана граница recover | Мигрирован; актуализировать | P0 |
| `Programming/Go/Структуры данных/interface.md` | `docs/go/language/interfaces.md` | REWRITE | Смешаны conversion/assertion; runtime internals поданы слишком категорично | Сохранить полезную семантику, переписать internals | P0 |
| `Programming/Go/Структуры данных/slice.md` | `docs/go/data-structures/slice.md` | UPDATE | Growth details рискуют выглядеть контрактом; нет clear/full slice/slices package | Мигрирован; актуализировать | P0 |
| `Programming/Go/Структуры данных/map.md` | `docs/go/data-structures/map.md` | REWRITE | Legacy hmap/buckets/overflow/evacuation описаны как current | Переписать под current stable Swiss Tables | P0 |
| `Programming/Go/Структуры данных/struct.md` | `docs/go/data-structures/struct.md` | UPDATE | Чрезмерно общие alignment claims; external GIF | Мигрирован; уточнить guarantees | P1 |
| `Programming/Go/Concurrency/Основы конкурентности в Go.md` | `docs/go/concurrency/fundamentals.md` | UPDATE | External diagrams; не хватает memory model | Мигрирован; дополнить | P0 |
| `Programming/Go/Concurrency/Goroutine.md` | `docs/go/concurrency/goroutines.md` | UPDATE | Runtime details требуют проверки; не хватает ownership/cancellation | Мигрирован; актуализировать | P0 |
| `Programming/Go/Concurrency/Каналы.md` | `docs/go/concurrency/channels.md` | REWRITE | Есть неверный обязательный deadlock example; external diagrams | Переписать семантику и таблицу состояний | P0 |
| `Programming/Go/Concurrency/Примитивы синхронизации.md` | `docs/go/concurrency/sync-primitives.md` | UPDATE | Не хватает current API и happens-before | Мигрирован; актуализировать | P0 |
| `Programming/Go/Concurrency/Паттерны многопоточности.md` | `docs/go/concurrency/patterns.md` | UPDATE | Очень большая страница; weak failure-mode structure | Сохранить примеры, разделить по механизму | P1 |
| `Programming/Go/Внутреннее устройство Go/Компиляция и сборка.md` | `docs/go/runtime/compilation.md` | UPDATE | Implementation-sensitive | Мигрирован; сверить current toolchain | P1 |
| `Programming/Go/Внутреннее устройство Go/Runtime.md` | `docs/go/runtime/runtime-overview.md` | UPDATE | Краткий обзор без границы contract/implementation | Мигрирован; уточнить | P1 |
| `Programming/Go/Внутреннее устройство Go/Планировщик.md` | `docs/go/runtime/scheduler.md` | REWRITE | Magic constants и детали scheduler могли устареть | Переписать с version caveats | P0 |
| `Programming/Go/Внутреннее устройство Go/Управление памятью.md` | `docs/go/runtime/memory-management.md` | REWRITE | Много implementation diagrams и нестабильных деталей | Проверить runtime source; убрать заучивание constants | P1 |
| `Programming/Go/Внутреннее устройство Go/Garbage Collector.md` | `docs/go/runtime/garbage-collector.md` | REWRITE | Реализация GC устарела относительно current stable | Переписать с GOGC/GOMEMLIMIT и current GC | P0 |
| `Programming/Go/Профилирование/Профилирование кода.md` | `docs/go/performance/pprof.md` | UPDATE | Не хватает production workflow и current profiles | Мигрирован; расширить | P1 |
| `Programming/База данных/!Краткое содержание.md` | `docs/databases/README.md` | MERGE | Outline вместо index page; упрощённый CAP | Заменён index page | P0 |
| `Programming/База данных/Общие сведения.md` | `docs/databases/fundamentals.md` | UPDATE | CAP сформулирован как «любые 2 из 3»; обобщения о NoSQL | Мигрирован; исправить | P0 |
| `Programming/База данных/Блокировки.md` | `docs/databases/postgresql/locks.md` | REWRITE | SQL Server-style S/X/IS/IX/U terminology выдана за общую; неверно про SELECT | Полностью переписать как PostgreSQL-specific | P0 |
| `Programming/Брокеры сообщений/Kafka.md` | `docs/messaging/kafka/legacy-overview.md` | REWRITE | Смешаны Kafka/RabbitMQ/Redis; много external images; version-sensitive producer/KRaft facts | Исключён из публичной навигации; использовать как source material | P0 |
| `Programming/Контейнеризация и виртуализация/Docker.md` | `docs/containers/docker/legacy-note.md` | REWRITE | Пустая заметка | Создать Docker-раздел с нуля | P1 |
| `Programming/Сети/!Краткое содержание.md` | `docs/networking/README.md` | MERGE | Block transclusions | Заменён index hierarchy | P0 |
| `Programming/Сети/Основы организации компьютерных сетей.md` | `docs/networking/fundamentals/networking-basics.md` | UPDATE | Требуется source review | Мигрирован | P1 |
| `Programming/Сети/Стандартизация сетей.md` | `docs/networking/fundamentals/standardization.md` | UPDATE | Слишком кратко | Мигрирован; дополнить по необходимости | P2 |
| `Programming/Сети/Терминология.md` | `docs/networking/fundamentals/terminology.md` | UPDATE | External images без alt text | Мигрирован; заменить критичные схемы | P1 |
| `Programming/Сети/IP-адреса.md` | `docs/networking/fundamentals/ip-addressing.md` | UPDATE | Требуется проверка терминологии и CIDR examples | Мигрирован | P1 |
| `Programming/Сети/Модель ISO OSI.md` | `docs/networking/fundamentals/osi.md` | UPDATE | External image; модель рискует подаваться слишком буквально | Мигрирован; уточнить | P1 |
| `Programming/Сети/Модель TCP IP.md` | `docs/networking/fundamentals/tcp-ip-model.md` | UPDATE | External images | Мигрирован | P1 |
| `Programming/Сети/Организация сетей TCP IP.md` | `docs/networking/fundamentals/tcp-ip-networking.md` | UPDATE | Был broken pseudo-link SMTP | Мигрирован; broken link исправлен | P1 |
| `Programming/Сети/Интерфейсы/Сокет.md` | `docs/networking/fundamentals/sockets.md` | UPDATE | External GIF; нет backend lifecycle | Мигрирован; дополнить listen/accept/pools | P1 |
| `Programming/Сети/Протоколы/internet-layer/ARP.md` | `docs/networking/fundamentals/arp.md` | UPDATE | External GIF | Мигрирован; проверить | P2 |
| `Programming/Сети/Протоколы/internet-layer/ICMP.md` | `docs/networking/fundamentals/icmp.md` | UPDATE | External GIFs | Мигрирован; проверить | P2 |
| `Programming/Сети/Протоколы/internet-layer/IP.md` | `docs/networking/fundamentals/ip.md` | UPDATE | External image | Мигрирован; проверить | P1 |
| `Programming/Сети/Протоколы/transport-layer/TCP.md` | `docs/networking/transport/tcp.md` | UPDATE | Много external images; мало states/TIME_WAIT | Мигрирован; расширить | P0 |
| `Programming/Сети/Протоколы/transport-layer/UDP.md` | `docs/networking/transport/udp.md` | UPDATE | Требуется source review | Мигрирован | P1 |
| `Programming/Сети/Протоколы/transport-layer/QUIC.md` | `docs/networking/transport/quic.md` | UPDATE | Version-sensitive; external references/images | Мигрирован; проверить RFC | P1 |
| `Programming/Сети/Протоколы/application-layer/DNS.md` | `docs/networking/application/dns.md` | UPDATE | External image; мало caching/failure modes | Мигрирован | P1 |
| `Programming/Сети/Протоколы/application-layer/DHCP.md` | `docs/networking/application/dhcp.md` | UPDATE | External images | Мигрирован | P2 |
| `Programming/Сети/Протоколы/application-layer/HTTP 1.1.md` | `docs/networking/application/http-1-1.md` | UPDATE | External images; не хватает connection reuse | Мигрирован | P0 |
| `Programming/Сети/Протоколы/application-layer/HTTP 2.md` | `docs/networking/application/http-2.md` | UPDATE | Version-sensitive; мало flow control | Мигрирован | P1 |
| `Programming/Сети/Протоколы/application-layer/HTTP 3.md` | `docs/networking/application/http-3.md` | UPDATE | Version-sensitive | Мигрирован; проверить RFC | P1 |
| `Programming/Сети/Протоколы/application-layer/TLS SSL.md` | `docs/networking/application/tls.md` | UPDATE | Смешаны TLS/SSL; внешние copyrighted diagrams | Мигрирован; переписать под current TLS | P0 |
| `Programming/Сети/Протоколы/application-layer/HTTPS.md` | `docs/networking/application/https.md` | UPDATE | Требуется отделить HTTP semantics от TLS | Мигрирован | P1 |
| `Programming/System Design/Основные термины и компоненты.md` | `docs/system-design/fundamentals/core-concepts.md` | UPDATE | Огромный glossary; десятки external images; дубли | Мигрирован; разделить по темам | P1 |
| `Programming/System Design/Хранение данных.md` | `docs/system-design/fundamentals/data-storage.md` | UPDATE | Огромная смешанная страница; external images | Мигрирован; разделить | P1 |
| `Programming/System Design/Распределенное хранение данных.md` | `docs/system-design/fundamentals/distributed-storage.md` | REWRITE | Упрощённый CAP; external diagrams; mixed guarantees | Исправить CAP/PACELC и разделить | P0 |
| `Programming/System Design/Паттерны и приему проектирования.md` | `docs/system-design/fundamentals/design-patterns.md` | UPDATE | Опечатка в source name; glossary format; external images | Мигрирован; разделить | P1 |
| `Templates/Daily Template.md` | — | REMOVE | Obsidian Templater syntax | Не переносить в public docs | P3 |
| `Templates/Default Template.md` | — | REMOVE | Obsidian Templater syntax | Не переносить в public docs | P3 |
| `Templates/Planner Template.md` | — | REMOVE | Obsidian Templater syntax | Не переносить в public docs | P3 |
| `Templates/Reference Template.md` | — | REMOVE | Obsidian Templater syntax | Не переносить в public docs | P3 |

## Assets и ссылки

Локальных assets нет, поэтому при filesystem migration ничего не теряется. Внешние изображения сохранены в мигрированных source material, но считаются техническим долгом: ключевые схемы нужно заменить Mermaid или самодостаточным текстом во время содержательного rewrite. Публичная навигация не содержит legacy Kafka/Docker pages.

## Resolution log

- 2026-09-10 — Batch 1: все 53 страницы `Programming/` сопоставлены с 50 content pages и тремя новыми indexes; legacy paths удалены после link validation.
- 2026-09-10 — Batch 2: все исходные P0-страницы Go из audit (`basics`, `map`, `slice`, `interfaces`, errors/panic, goroutines/channels/sync) переписаны; добавлены отсутствующие P0-страницы.
- 2026-09-10 — Batch 3: runtime/scheduler/memory/GC/pprof обновлены для Go 1.27; добавлены backend, gRPC и testing sections.
- 2026-09-10 — Batch 4a: PostgreSQL расширен до architecture, MVCC, transactions, isolation, locks, query performance, WAL, maintenance и replication; старая generic locks page полностью заменена.
- 2026-09-10 — Batch 4b: добавлен Redis 8.10 section с caching, TTL/eviction, persistence, replication, Sentinel, Cluster, locks и hot-key operations.
- 2026-09-10 — Batch 5a: legacy Kafka note заменена в public navigation на Kafka 4.3 KRaft-only guide; добавлены Outbox и Inbox.

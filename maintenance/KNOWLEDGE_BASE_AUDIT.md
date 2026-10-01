# Аудит технической базы знаний

Дата: 2026-10-01. Исходное состояние: `6ba87a2`, рабочее дерево чистое. Аудит составлен до содержательных изменений; результаты проверки будут дописаны ниже.

## 1. Текущее состояние

В `docs/` 311 Markdown-файлов, в SUMMARY — 310 уникальных страниц. Тематические разделы, относительные ссылки, frontmatter и `.gitbook.yaml` уже пригодны для справочника. Исходный `pwsh scripts/check-docs.ps1` проходит. AGENTS.md в рабочем дереве не найден.

## 2. Что задаёт учебный маршрут

Главная предлагает последовательное изучение и рекомендуемый порядок. CONTRIBUTING требует README с reading order. Индексы Go, databases, messaging, networking, algorithms, distributed systems, containers, architecture, security и observability содержат цепочки чтения. Practice — поэтапный Ads Service roadmap; interviews содержит тренировочные маршруты и skill matrix. Порядок диагностики инцидента или обработки запроса сам по себе не является порядком изучения: полезные runbooks сохраняются.

## 3. Что сохранить

Тематическое дерево и существующие URL, технические статьи, примеры, таблицы, связи между темами, GitBook config. System Design cases, алгоритмические задачи и интервью допустимы как независимые справочные материалы. Не требуется насильно перестраивать дерево под новый список категорий.

## 4. Где нужна техническая перепроверка

Минимальный Go-проход: language/loop variables, generics, interfaces, map/slice, memory model, runtime/scheduler/GC, HTTP/time/JSON, testing/profiling, compiler/tooling/modules. Особый риск — перенос default behavior нового runtime на модули со старым `go` directive. Ссылки на движущуюся ветку исходников не фиксируют проверенную реализацию. Изменённые технические утверждения и источники будут записаны в журнале ниже.

Полная независимая проверка PostgreSQL, Redis, Kafka, Kubernetes, Linux, security и всех 310 страниц не подтверждена прежними отметками DONE. Исторические отчёты отражают заявления прежней миграции, а не доказательство текущего review.

## 5. Устаревшее и сомнительное

Legacy map через hmap/buckets описывает Go до Swiss Tables; её нельзя возвращать как актуальную. Старые правила loop variables и timers требуют версионных границ. Go 1.27, generic methods и JSON v2 подтверждаются доступными официальными release notes; автоматически откатывать их к старой версии нельзя. Требуют проверки: timer lifecycle, container-aware GOMAXPROCS для старых модулей, формулировки о сохранении named slice type в примере Index, утверждение о version pinning через go.sum.

## 6. История и утраченные схемы

Состояние до массовой миграции: `cc2e017` (2024-08-12), миграция `93c27f9`, основные Go rewrites `85d53f7`/`f0e1fc2`, финальный проход `6657704`. Использованы git log --all, log --stat, log по файлам, show и сравнения версий.

В срезе `cc2e017` изображения были внешними ссылками на Imgur (channels, scheduler, GC, memory, interface, map, struct, System Design, networking). Более ранний проход по `Cache/` обнаружил 55 локальных assets (47 PNG, 8 GIF), удалённых коммитом `e4097e1` ещё 2024-07-27. Они доступны в `e4097e1^`; первоначальное предположение об отсутствии локальных изображений во всей истории было неверным. Полный инвентарь и классификация: [HISTORICAL_ASSETS.md](HISTORICAL_ASSETS.md).

Все 55 изображений просмотрены на контактных листах; GIF оценены по первым кадрам, без полной покадровой верификации. Есть полезные схемы DORA/TCP/IP и aliasing в тексте старых статей, но также SSL handshake старого типа, некорректная таблица concurrency и снимки roadmap. Лицензия/авторство растровых иллюстраций не установлены. Они не возвращаются в публикацию без проверки прав и содержания. Восстановлен смысл старого примера array/subslice; DORA возвращена как новая проверяемая Mermaid-схема. Таблица channels уже была сохранена в текущей версии: не дублировалась.

## 7. Пересечения страниц

Race detector и benchmarks в testing/performance; graceful shutdown в backend/concurrency; TLS в security/networking; Outbox в messaging/backend-patterns; replication/sharding/idempotency в distributed systems/System Design/patterns. Разные контексты оправдывают часть пересечений. Сохраняются краткие обзоры со ссылкой на подробную статью; массовое объединение без сравнения не выполняется.

## 8. План безопасных изменений

1. Исправить главные страницы и CONTRIBUTING; превратить маршруты в тематические индексы.
2. Переработать Ads Service в справочный архитектурный пример; убрать обучающий порядок из interviews, сохранив содержание и пути.
3. Проверить ключевые Go claims по spec, memory model, release notes и versioned source. Исправить конкретные ошибки, восстановить полезные объяснения и Mermaid.
4. Заменить blanket DONE в текущем backlog честным статусом проверки, сохранив исторические отчёты.
5. Улучшить check-docs там, где есть пробелы: frontmatter/date, reference links/assets, anchors и нормализация SUMMARY; выполнить проверки и diff review.

## 9. Что сознательно не делать

Не переписывать хорошие статьи ради стиля, не переименовывать файлы ради вкуса, не удалять большие разделы, не менять GitBook config, не создавать учебный план, не генерировать картинки, не копировать чужие изображения без лицензии. Не менять updated при правке только навигации. Не публиковать, не push и не создавать коммиты без необходимости.

## 10. Риски и ручной review владельца

Права на старые внешние и локальные изображения; актуальный процесс интервью конкретной вакансии; environment-specific runbooks и настройки production; полный review разделов вне проверенного Go-прохода. Go toolchain установлена только во временный каталог для проверки, PATH и глобальные настройки не изменялись. Автоматическая проверка структуры не доказывает техническую достоверность статьи.

## Журнал выполненной проверки

База проверки — standard Go 1.27.1, выбранная как конкретная воспроизводимая версия, а не обещание «latest». ZIP с go.dev/dl проверен по опубликованной SHA-256 `a3911b5e0e1b1053f25ed0675f4c1c6aad1e2bfcf253df2b9be4caabd2edd95d`. Versioned runtime/compiler source прочитан из этого архива. Гарантии языка проверены по [spec](https://go.dev/ref/spec), изменения — по release notes 1.22–1.27.

| Страница / тема | Проверено, источник | Версия / тип утверждений | Итог и ограничения |
|---|---|---|---|
| `go/data-structures/slice.md` | [Append/copy/full slicing](https://go.dev/ref/spec#Appending_and_copying_slices), старый `cc2e017:Programming/Go/Структуры данных/slice.md` | Гарантии языка; growth — implementation detail; slices/clear — Go 1.21+ | Исправлена гарантия reuse; возвращён пример общего array, добавлена Mermaid; новый пример запущен |
| `go/data-structures/map.md` | Spec map/range; [Swiss Tables](https://go.dev/blog/swisstable); [versioned source](https://github.com/golang/go/blob/go1.27.1/src/internal/runtime/maps/map.go) | Swiss Tables с 1.24; описание реализации 1.27.1 | Семантика nil/comparability/iteration и H1/H2/table growth подтверждены; ссылка закреплена на release; benchmark не проводился |
| `go/generics/type-parameters.md` | [Type inference](https://go.dev/ref/spec#Type_inference), функции/присваивание | Язык, generic functions с 1.18, расширение контекста inference в 1.27 | Index возвращает int, а не named slice; исправлено объяснение; декларация и вызов из статьи скомпилированы, результат проверен тестом |
| `go/generics/README.md`, `generic-types.md` (без rewrite) | [1.24 aliases](https://go.dev/doc/go1.24), [1.27 methods](https://go.dev/doc/go1.27#language), spec Method declarations | Язык; methods с собственными parameters с 1.27; interface methods их не имеют | Сохранены корректные новые возможности; generic declarations из статьи скомпилированы и вызваны тестом; у индекса updated сохранён, потому что правка навигационная |
| `go/language/closures.md` | Spec function literals/for; [loop variables](https://go.dev/blog/loopvar-preview) | Language version 1.22+, граница go.mod/build constraints | Сохранены авторские counter/adder; добавлена граница :=/assignment и race caveat; один пример выполнен с go 1.21 и go 1.27 |
| `go/language/basics.md`, `interfaces.md` (без rewrite) | Spec zero values/comparability/method sets/assertions; [1.26 new(expr)](https://go.dev/doc/go1.26#language) | Гарантии языка; layout/allocations не гарантированы | Ключевые claims подтверждены; полная compilation sweep старых snippets не выполнена, updated не менялся |
| `go/concurrency/memory-model.md`, `channels.md`, `sync-primitives.md` | [Memory Model](https://go.dev/ref/mem), spec Channel/Select, [1.25 WaitGroup.Go](https://go.dev/doc/go1.25#sync) | Happens-before/DRF-SC — guarantees; deadlock diagnostic — implementation | Ключевые отношения и таблица channels проверены; в channels изменены только связи, updated сохранён; race detector не запускался |
| `go/runtime/scheduler.md` | [runtime.GOMAXPROCS](https://pkg.go.dev/runtime@go1.27.1#GOMAXPROCS); `runtime/proc.go`, `debug.go`, `runtime2.go` в 1.27.1 | G-M-P/state transitions — implementation; defaults с 1.25, compatibility для go <=1.24 | Добавлены GODEBUG, округление quota, lower bound, отличие чтения от ручной установки; Mermaid упрощена; Linux cgroup experiment не выполнялся |
| `go/runtime/runtime-overview.md` | Versioned runtime source и runtime API | Implementation vs guarantees | Уточнён GOMAXPROCS(n <= 0); остальные ключевые механизмы сопоставлены с source |
| `go/runtime/garbage-collector.md` | [GC guide](https://go.dev/doc/gc-guide), [1.26](https://go.dev/doc/go1.26#runtime), `mgc.go`/`stack.go` 1.27.1 | Green Tea default с 1.26; GC и stack relocation — implementation | Heap non-moving отделён от перемещения stacks; старый GC guide не используется как единственный источник новой Green Tea реализации |
| `go/runtime/netpoller.md` | `net/net.go`, `runtime/netpoll.go`, `netpoll_epoll.go`, `netpoll_kqueue.go`, `netpoll_windows.go` 1.27.1 | Platform implementation | Разведены readiness (Linux/BSD) и overlapped I/O/IOCP (Windows); не проверялось нагрузкой на каждой OS |
| `go/runtime/compilation.md` | [Modules reference](https://go.dev/ref/mod), [Toolchains](https://go.dev/doc/toolchain), cmd/go/compile/link | Go/toolchain directives с 1.21; compiler decisions — implementation | go.sum не lockfile; пояснены MVS, workspace и language/toolchain version; полный reproducible-build experiment не выполнялся |
| `go/backend/http-client.md`, `net-http.md` | [http API](https://pkg.go.dev/net/http@go1.27.1), `transport.go`; [1.22 routing](https://go.dev/doc/go1.22) | API vs recommendation; ServeMux rules с 1.22 | Пул принадлежит Transport; Client с nil Transport общий. Server не обязан использовать ServeMux. Reuse проверен на двух Clients |
| `go/backend/time.md` | [time API](https://pkg.go.dev/time@go1.27.1), [1.23 timers](https://go.dev/wiki/Go123Timer), [1.27 runtime](https://go.dev/doc/go1.27#runtime), 1.25 synctest notes | 1.23–1.26 compatibility, удаление asynctimerchan в 1.27 | Исправлены GC/Stop/Reset/Ticker lifecycle; synchronous channel и незакрытие Ticker.C проверены тестом |
| `go/backend/json.md`, `go/testing/http-testing.md` (без rewrite) | [1.27 library changes](https://go.dev/doc/go1.27), versioned `httptest/server.go` | API, JSON v2 и NewTestServer в 1.27 | Version-sensitive claims подтверждены; contract diff конкретного сервиса не выполнялся |
| `go/performance/benchmarks.md`, `escape-analysis.md` | [B.Loop](https://pkg.go.dev/testing@go1.27.1#B.Loop), `testing/benchmark.go`, compiler escape source | B.Loop с 1.24; anti-elision/escape heuristics 1.27.1 — implementation | Уточнены пределы anti-elision, нерелевантный blog index заменён исходником; результаты performance не выдумывались |
| `go/performance/pprof.md`, `runtime-trace.md`, `pgo.md` | [1.27 leak profile](https://go.dev/doc/go1.27#runtime), [1.25 FlightRecorder](https://go.dev/doc/go1.25), [PGO guide](https://go.dev/doc/pgo), diagnostics | Versioned API и рекомендации | Ключевые возможности подтверждены; удалена только дублирующая PGO ссылка, updated сохранён; profiling на реальном сервисе не выполнялся |
| `networking/application/dhcp.md` | [RFC 2131](https://datatracker.ietf.org/doc/html/rfc2131), [2132](https://datatracker.ietf.org/doc/html/rfc2132), [9915](https://www.rfc-editor.org/info/rfc9915/) | DHCPv4 protocol guarantees; DHCPv6 отдельный | Возвращена DORA в Mermaid; уточнены NAK/DECLINE/INFORM, lease/renewal, client ID и relay; hardware capture не выполнялся |
| `interviews/avito/README.md`, `scoring.md` | AvitoTech [2025](https://habr.com/ru/companies/avito/articles/919020/), [2023, раздел «Собеседования»](https://habr.com/ru/companies/avito/articles/774696/) | Историческое описание, не текущая гарантия | Публикация о frontend действительно содержит описание секций; title источника уточнён. Актуальность конкретной вакансии не установлена |
| Practice/interviews и остальные индексы | Сравнение diff, ссылок и прежних текстов | Редактура структуры/навигации | Убраны маршруты, этапы, P0 gaps и reading chains; старые updated сохранены. Полная независимая проверка технических claims Ads Service и всех индексов не заявляется |

## Восстановленный материал и изображения

- Array/subslice mutation из старой slice-статьи возвращена в минимальном запускаемом примере; добавлен full slice expression, чтобы показать границу aliasing и append.
- DORA из старых DHCP illustrations восстановлена в новой Mermaid-схеме по RFC, без копирования изображения.
- Mermaid lifecycle goroutine дополняет сохранённое описание G-M-P; это новая схема, а не извлечённый старый asset.
- 55 старых локальных изображений сохранены в Git history и инвентаризированы. В docs растровые assets не возвращались: права и часть содержания требуют owner review. Старые подробности legacy hmap и SSL не возвращались как актуальные.

## Автоматические проверки и пределы

- Исходный и обновлённый `pwsh scripts/check-docs.ps1`: 311 Markdown-файлов, 310 уникальных SUMMARY entries, без ошибок. Проверяются существование локальных targets/assets, Markdown anchors, reference links, обязательные поля frontmatter, календарная дата, duplicate keys, paths, orphan pages и индексы каталогов. Это проверка поддерживаемой схемы frontmatter, не полноценный YAML/Markdown parser.
- `pwsh scripts/test-check-docs.ps1`: 14 изолированных fixtures прошли, включая отрицательные случаи. Реальные docs не изменяются тестом.
- `gofmt`: 24 Go fragments изменённых статей синтаксически разобраны и отформатированы. Это не подтверждает доступность всех placeholder identifiers.
- `go run .`: slice example; closure example с go 1.27 и go 1.21 — ожидаемые outputs совпали. Дополнительно Go 1.27.1 с go 1.21 directive подтвердил synchronous timer channel.
- `go test -v .` во временном модуле: generic aliases/methods, Index из статьи, timer/ticker contract, shared default HTTP Transport — 4 tests PASS. Это targeted verification, не полный прогон всех примеров базы.
- Проверены HTTP responses 67 внешних URL из изменённых страниц: 63 HTTP 200, 2 HTTP 308 (OWASP), 2 HTTP 403 (Redis). Redirect/access block не объявляются broken links; семантическая релевантность источников проверена только для тем в журнале. Нерелевантная ссылка escape analysis удалена.
- `git diff --check`: без ошибок; итоговый check-docs повторно прошёл. GitBook sync/renderer не запускался; config сохранён, схемы проверены по смыслу и синтаксису вручную.

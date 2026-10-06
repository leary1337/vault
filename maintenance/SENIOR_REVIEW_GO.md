# Проверка раздела Go для Senior

Дата: 2026-10-06. Область: все 72 ранее существовавшие страницы `docs/go/**`: 62 предметные статьи и 10 индексов. Все страницы прочитаны полностью; пути и полезные исходные объяснения сохранены. Дополнительно создана docs/go/tooling.md с modules/toolchain/workspace/vendor/GOPRIVATE/buildtags/CGO и проверкой зависимостей: итог 73 страницы, 63 предметные статьи и 10 индексов. Индекс Go и crosslinks обновлены; SUMMARY обновляет родительский агент.

## Изменения

В каждой предметной статье появились понятная первая модель, отдельный конкретный пример или разбор механизма, два вопроса и скрываемые ориентиры для ответа. Важные заимствованные термины объяснены при первом употреблении в тексте. Более сложные темы содержат границы гарантий, расчёты и ограничения диагностики. Индексы остались тематическими, без обязательной очередности чтения.

Исправлены отмена чтения пустого незакрытого input в `mapStage`/`merge`, ошибочное описание любого receiver type, поверхностного копирования value receiver и параметров функций. Разделены исторические codeblocks, смешивавшие объявления методов/функций и исполняемые statements. Добавлены практические разборы JSON trailing values, денежного округления без overflow, map values, mutable snapshot, transaction vs atomic, HTTP response/body lifecycle, gRPC stream half-close и конкурентного Send/Recv.

В разделе теперь 13 Mermaid-схем, включая ранее существовавшие. Новые схемы вручную описывают механизм: typed nil, Swiss Tables lookup, владение channel, pipeline cancellation, happens-before, backpressure, shutdown, HTTP lifecycle, gRPC streaming, GC reachability и связь G/M/P. Растровая генерация не использовалась.

## Версии и источники

Спецификация и официальные release notes на дату проверки подтверждают Go 1.27, generic methods и стабильные JSON v2 packages. Исполняемые проверки сделаны установленной ранее из официального архива Go 1.27.1 windows/amd64. Это зафиксированная baseline, а не утверждение о последнем доступном patch.

- [Go specification](https://go.dev/ref/spec): receivers, value semantics, generics, aliases, interfaces, scope.
- [Go memory model](https://go.dev/ref/mem): публикация и синхронизация, DRF-SC.
- [Go 1.27 release notes](https://go.dev/doc/go1.27): generic methods, JSON v2, timer channels, stdversion, goroutineleak.
- [Go release history](https://go.dev/doc/devel/release): границы версий.
- [`sync`](https://pkg.go.dev/sync), [`context`](https://pkg.go.dev/context): WaitGroup.Go, Cond, Once, cancel causes, WithoutCancel/AfterFunc.
- [`net/http`](https://pkg.go.dev/net/http): body, Shutdown/Close, context, deadlines и routing.
- [`testing`](https://pkg.go.dev/testing), [`runtime/trace`](https://pkg.go.dev/runtime/trace): B.Loop, тестовый lifecycle, task/region и flight recorder.
- [Go GC guide](https://go.dev/doc/gc-guide): достижимость, heap goal, roots, memory limit. Современный Green Tea дополнительно описан ранее закреплёнными release/source links в статье; guide не используется как единственное доказательство новой реализации.
- [`encoding/json/v2`](https://pkg.go.dev/encoding/json/v2): migration boundary с legacy JSON.
- [grpc-go concurrency rules](https://github.com/grpc/grpc-go/blob/master/Documentation/concurrency.md): один send и один receive могут идти одновременно; одинаковые операции сериализуют.
- [`grpc.NewClient`](https://pkg.go.dev/google.golang.org/grpc#NewClient): API с v1.63, lazy connection, credentials.
- [gRPC Go basics](https://grpc.io/docs/languages/go/basics/): generated API и streaming lifecycle.
- [Protobuf field presence](https://protobuf.dev/programming-guides/field_presence/): отсутствие vs zero; generated API variants.
- [Testcontainers PostgreSQL](https://golang.testcontainers.org/modules/postgres/): Run, wait strategies, ConnectionString. Версию dependency нужно закрепить в использующем пример проекте.

## Выполненные проверки

1. Синтаксический разбор и gofmt всех 145 Go codeblocks на baseline Go 1.27.1. Фрагменты разбирались отдельно как declarations или statements в служебной оболочке. Это проверка синтаксиса, не разрешения всех импортов и внешних имён.
2. В изолированном временном модуле точные новые определения из статей скомпилированы и проверены 10 тестами, каждый по 10 раз: cancel empty-open pipeline input, cancel blocked pipeline send, empty merge, square result, Price boundaries включая MaxInt64, JSON single value/unknown/trailing/malformed, generic type/method/alias results, HTTP route, isolated filesystem round-trip, atomic counter с ожиданием workers. Все прошли.
3. Все восемь полных Go programs извлечены прямо из статей и скомпилированы: семь выполнены (slog, goroutine join, HB publication, slice aliasing, loop closures, Person receiver, shared slice value receiver), результаты совпали с указанными; локальный HTTP server скомпилирован без запуска listener. `go vet` тестового модуля прошёл. Race-run попытался запуститься, но окружение отказало: `-race requires cgo`. Результат не считается успешной проверкой отсутствия гонок.
4. `pwsh scripts/check-docs.ps1` прошёл: 311 Markdown pages / 310 entries на момент проверки. `git diff --check` прошёл.

Проверки и служебные scripts находятся во временной папке `vault-kb-review/senior-go`, глобальные PATH и установленная toolchain не изменялись. Проверено существование illustrative dependency golang.org/x/sync@v0.19.0 через go list -m -json (GoVersion1.24.0), пользовательская конфигурация Go не изменялась. Unit tests не добавлены в docs как фиктивный production package.

## Ограничения

Не заявляется выполнение всех сетевых/SQL/gRPC/Testcontainers сценариев: часть examples явно требует generated `pb`, driver, реальных dependencies или конфигурации. Не проводились load tests, Linux cgroup experiments, измерения GC на production hardware или GitBook rendering. Иллюстративные профили/цифры обозначены примерами; обещаний фиксированного ускорения нет. Источники реализации закреплены на версии, а не объявлены контрактом языка. Самопроверка помогает обсуждать материал, но не гарантирует запоминание после одного чтения или исчерпывающее покрытие вопросов конкретной компании.

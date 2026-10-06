---
title: Testcontainers for Go
description: Управление disposable dependencies в integration tests.
tags:
  - go
  - testing
  - containers
updated: 2026-10-06
---

# Testcontainers for Go

Testcontainers запускает настоящую зависимость в одноразовом контейнере. Тест получает близкое к эксплуатации поведение без общей постоянной БД.

Testcontainers запускает real dependency image из Go test. Это third-party library, не standard library. Используйте module-specific `Run` API и pinned image tag, а не `latest`.

```go
ctr, err := postgres.Run(ctx,
	"postgres:17-alpine",
	postgres.WithDatabase("app"),
	postgres.WithUsername("app"),
	postgres.WithPassword("test-only"),
	postgres.BasicWaitStrategies(),
)
if err != nil {
	t.Fatal(err)
}
testcontainers.CleanupContainer(t, ctr)
```

После readiness (готовность принимать новую работу) примените production migrations. Container start дорогой: один suite container + isolated schemas/snapshots может ускорить tests, но не допускайте state leakage. В CI учитывайте Docker availability, image registry failures, architecture и logs/artifacts.

Не используйте deprecated `RunContainer`; API/version сверяйте при upgrade dependency.

## Ждать готовность, затем проверять протокол

После фрагмента запуска выше:

```go
dsn, err := ctr.ConnectionString(ctx, "sslmode=disable")
if err != nil {
	t.Fatal(err)
}
// sql.Open с вашим установленным PostgreSQL driver.
db, err := sql.Open(driverName, dsn)
if err != nil {
	t.Fatal(err)
}
t.Cleanup(func() { _ = db.Close() })
if err := db.PingContext(ctx); err != nil {
	t.Fatal(err)
}
```

Это фрагмент test: `driverName` должен соответствовать импортированному драйверу, нужен `database/sql`. Пароль test-only и отключённый TLS относятся к изолированной fixture (подготовленные тестовые данные и зависимости). Container running не значит PostgreSQL ready; wait strategy и Ping проверяют разные ступени.

`postgres:17-alpine` здесь выбранная major для совместимости теста, а не заявление о последней версии PostgreSQL. Для воспроизводимости закрепите конкретный patch/digest и версию Go module; проверяйте upgrades как отдельное изменение. Docker недоступен — integration suite должен сообщить ограничение, а не молча выдать зелёную проверку.

## Источники

- [Testcontainers for Go quickstart](https://golang.testcontainers.org/quickstart/)
- [PostgreSQL module](https://golang.testcontainers.org/modules/postgres/)

## Проверь себя

1. Почему image latest плох для CI?
2. Достаточно ли факта running?

<details>
<summary>Ориентиры для ответа</summary>

1. Он может незаметно сменить поведение между двумя одинаковыми commits.
2. Нет: сервис может ещё инициализироваться; нужны readiness и protocol check.

</details>

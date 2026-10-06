---
title: "Testcontainers for Go"
description: "Testcontainers — сторонняя библиотека, которая запускает настоящую зависимость в одноразовом контейнере из Go-теста."
tags:
  - go
  - testing
  - containers
updated: 2026-10-06
---

# Testcontainers for Go

Testcontainers — сторонняя библиотека, которая запускает настоящую зависимость в одноразовом контейнере из Go-теста. Это позволяет проверить БД без постоянного общего экземпляра.

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

Используйте актуальный `Run` API выбранного модуля, а не устаревший `RunContainer`. Фиксируйте библиотеку и образ; `latest` может незаметно изменить два одинаковых запуска CI.

## От запуска до работы БД

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

`driverName` должен совпасть с импортированным драйвером; нужен `database/sql`. Пароль и отключённый TLS — только для изолированных тестовых данных. Статус контейнера running ещё не означает готовность PostgreSQL: ожидание и Ping проверяют разные стадии. Затем примените рабочие миграции.

`postgres:17-alpine` здесь выбран для совместимости примера, а не назван последней версией. Для воспроизводимости нужен patch или digest. Обновления проверяйте отдельно.

## Стоимость и CI

Один контейнер на группу с отдельными схемами может ускорить тесты, если данные не протекают между случаями. Учтите Docker, доступ к реестру, архитектуру и логи. Недоступная инфраструктура должна быть явно отражена: пропущенный интеграционный тест нельзя выдавать за успешную проверку.

## Источники

- [Testcontainers for Go quickstart](https://golang.testcontainers.org/quickstart/)
- [PostgreSQL module](https://golang.testcontainers.org/modules/postgres/)

## Проверь себя

1. Почему `latest` неудобен для CI?
2. Достаточно ли состояния running?

<details>
<summary>Ответы</summary>

1. Содержимое может измениться без изменения теста.
2. Нет: сервис ещё может запускаться; нужна проверка готовности и протокола.

</details>

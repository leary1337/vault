---
title: Integration tests
description: Проверка реальных protocol и storage boundaries без flaky shared state.
tags:
  - go
  - testing
  - integration
updated: 2026-10-06
---

# Integration tests

Integration test проверяет реальное взаимодействие компонентов. Он ценен там, где ошибка скрыта в протоколе или устройстве зависимости.

Integration test проверяет взаимодействие с реальной implementation boundary (граница ответственности между слоями): PostgreSQL, Redis, Kafka, filesystem, HTTP/gRPC server. Он нужен там, где fake не моделирует wire/schema/transaction semantics.

## Изоляция

- Используйте отдельную database/schema/topic/namespace на test run.
- Применяйте те же migrations, что production.
- Фиксируйте dependency image/version.
- Ждите readiness (готовность принимать новую работу) condition, а не sleep.
- Cleanup должен выполняться через `t.Cleanup`, даже после failure.
- Не полагайтесь на порядок tests и shared leftover state.

Parallelization ограничивайте capacity CI host и dependency. Failure report должен содержать seed, dependency logs/version и request correlation, но не secrets.

Отделяйте быстрый default suite от более дорогого integration suite build tag/CI job, однако запускайте оба как обязательные checks для затронутых boundaries.

## Недорогой integration test файловой границы

```go
func TestFileRoundTrip(t *testing.T) {
	path := filepath.Join(t.TempDir(), "state.txt")
	if err := os.WriteFile(path, []byte("ready"), 0600); err != nil {
		t.Fatal(err)
	}
	got, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	if string(got) != "ready" {
		t.Fatalf("got %q", got)
	}
}
```

Нужны `os`, `path/filepath`, `testing`. Это тест реальной файловой границы, но он не доказывает crash durability: ReadFile после WriteFile не моделирует внезапное отключение питания. Для такого контракта нужны отдельные сценарии fsync/rename и соответствующая ОС/FS.

То же ограничение у сетевой проверки: один успешный запрос не доказывает правильный retry после потерянного ответа. Подбирайте сценарий под конкретный failure mode.

## Источники

- [`testing` package](https://pkg.go.dev/testing)
- [Testcontainers for Go](https://golang.testcontainers.org/)

## Проверь себя

1. Почему успешный round trip не доказывает durability?
2. Как избежать flaky readiness?

<details>
<summary>Ориентиры для ответа</summary>

1. Данные могли быть только в cache; crash/power-loss не моделировался.
2. Ждать конкретный health/protocol condition с deadline, а не фиксированный sleep.

</details>

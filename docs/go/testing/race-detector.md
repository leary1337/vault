---
title: Race detector в тестах
description: Включение -race и построение тестов, исполняющих конкурентные пути.
tags:
  - go
  - testing
  - concurrency
updated: 2026-10-06
---

# Race detector в тестах

Конкурентный тест должен действительно выполнить конфликтующие пути и дождаться работников. Запуск флага -race без такого сценария мало помогает.

```bash
go test -race ./...
go test -race -run TestConcurrent -count=50 ./pkg
```

`-race` обнаруживает только executed conflicting accesses. Тест должен синхронно дождаться goroutines, иначе он может завершиться до race path. Не исправляйте report sleep-ом: создайте ownership/happens-before.

Инструментация увеличивает CPU/memory и меняет timing, поэтому держите отдельный обязательный CI job и representative integration scenarios. Подробнее: [Race detector](../performance/race-detector.md) и [Data races](../concurrency/data-races.md).

## Дождаться двух работников

```go
func TestConcurrentCount(t *testing.T) {
	var count atomic.Int64
	var wg sync.WaitGroup
	for range 2 {
		wg.Go(func() {
			for range 1000 {
				count.Add(1)
			}
		})
	}
	wg.Wait()
	if got := count.Load(); got != 2000 {
		t.Fatalf("got %d", got)
	}
}
```

Нужны `sync`, `sync/atomic`, `testing`, Go 1.25+. Ожидается 2000. Test не завершается раньше workers; обращения счётчика согласованы. Если заменить atomic на обычный `count++`, WaitGroup не устранит race между workers.

На некоторых платформах `-race` требует cgo и C toolchain. Отсутствие этой инфраструктуры нельзя записывать как успешный race-run: обычный test и race test — разные проверки.

## Источники

- [Data Race Detector](https://go.dev/doc/articles/race_detector)

## Проверь себя

1. Почему Wait после двух n++ недостаточно?
2. Должен ли CI скрывать невозможность включить -race?

<details>
<summary>Ориентиры для ответа</summary>

1. Он упорядочивает завершение с чтением теста, но не записи workers друг с другом.
2. Нет; нужны подходящая платформа/toolchain и отдельный результат проверки.

</details>

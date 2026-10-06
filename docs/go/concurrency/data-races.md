---
title: Data races
description: Причины, диагностика и устранение data races в Go.
tags:
  - go
  - concurrency
  - testing
updated: 2026-10-06
---

# Data races

Гонка данных возникает, когда два выполнения обращаются к одному месту памяти без согласованного порядка и хотя бы одно пишет. Результат «у меня работает» не является гарантией.

Data race — concurrent conflicting access к одной memory location без happens-before, где хотя бы один access является write и accesses не atomic.

```go
var n int
go func() { n++ }()
fmt.Println(n) // race, даже если «обычно успевает»
```

Исправление должно задавать ownership (ответственность за изменение данных и завершение работы) или synchronization: mutex, channel handoff, atomic operation либо immutable (неизменяемый после создания) copy. Добавление sleep не создаёт happens-before.

## Race detector

```bash
go test -race ./...
go test -race -run TestName -count=20 ./path/to/pkg
```

Detector динамический: он находит только races на выполненных путях. Увеличивайте покрытие concurrent scenarios и запускайте representative integration/load tests с `-race`, учитывая overhead. Отсутствие отчёта не является доказательством отсутствия race.

## Частые источники

- Общая map с concurrent writer.
- Захваченный mutable state в goroutines.
- Slice copies с общим backing array.
- Переиспользование buffer после передачи другому owner.
- Поля struct, часть которых atomic, а часть читается обычно.

## Исправление счётчика и логическая гонка

```go
var n atomic.Int64
var wg sync.WaitGroup
wg.Go(func() { n.Add(1) })
wg.Wait()
fmt.Println(n.Load()) // 1
```

Это фрагмент внутри `main` для Go 1.25+, нужны `sync`, `sync/atomic`, `fmt`. `Wait` дожидается работы, atomic обеспечивает согласованный доступ.

Отсутствие data race не исключает логическую гонку. Две транзакции могут обе прочитать «объявление свободно», а затем продать его двум покупателям; все локальные переменные защищены. Здесь нужны ограничения БД, блокировка или условное обновление версии. На собеседовании отделяйте безопасность доступа к памяти от корректности бизнес-операции.

## Источники

- [The Go Memory Model](https://go.dev/ref/mem)
- [Data Race Detector](https://go.dev/doc/articles/race_detector)

## Проверь себя

1. Чем data race отличается от двух безопасных операций в неверном порядке?
2. Почему WaitGroup не заменяет atomic при двух одновременных n++?

<details>
<summary>Ориентиры для ответа</summary>

1. Первое нарушает синхронизацию памяти; второе может быть логической ошибкой без data race.
2. Wait ждёт завершения, но не упорядочивает две записи работников между собой.

</details>

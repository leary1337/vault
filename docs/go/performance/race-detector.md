---
title: Race detector
description: Динамический поиск data races и ограничения режима -race.
tags:
  - go
  - performance
  - testing
updated: 2026-10-06
---

# Race detector

Race detector отмечает реально выполненные обращения без нужного порядка. Отчёт помогает найти две конфликтующие строки и места запуска их goroutines.

```bash
go test -race ./...
go test -race -count=20 ./path/to/pkg
go run -race ./cmd/service
```

Detector инструментирует memory accesses и synchronization. Он имеет существенный CPU/memory overhead и находит только races в выполненных paths. Запускайте representative tests; для production-like проверки используйте безопасную ограниченную среду.

Report показывает конфликтующие accesses и goroutine creation stacks. Исправляйте ownership/happens-before, а не подавляйте timing через sleep. Детальная семантика: [Data races](../concurrency/data-races.md).

## Прочитать отчёт как причинную цепочку

Иллюстративные фрагменты:

```text
WARNING: DATA RACE
Write at ... by goroutine 8: cache.go:42
Previous read at ... by goroutine 7: cache.go:19
Goroutine 8 created at: handler.go:55
```

Посмотрите, одна ли это map/структура, какие locks должны защищать read и write и когда объект передан другому владельцу. Обе стороны должны следовать одному протоколу. Lock только writer без lock у reader не устраняет race.

Race detector не ищет дедлоки, неправильную идемпотентность и гонки в независимых SQL-транзакциях. Он также меняет время выполнения; успешный прогон без report полезен лишь для реально покрытых конкурентных путей.

## Источники

- [Data Race Detector](https://go.dev/doc/articles/race_detector)
- [The Go Memory Model](https://go.dev/ref/mem)

## Проверь себя

1. Достаточно ли поставить mutex только writer?
2. Доказывает ли -race отсутствие deadlock?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, обычные readers того же изменяемого состояния тоже должны синхронизироваться.
2. Нет, он анализирует другой класс ошибок.

</details>

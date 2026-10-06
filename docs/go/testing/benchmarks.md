---
title: Benchmarks в тестах
description: B.Loop, allocations и статистическое сравнение Go benchmarks.
tags:
  - go
  - testing
  - performance
updated: 2026-10-06
---

# Benchmarks в тестах

Benchmark — тест стоимости одной операции, а не правильности её результата. Сначала проверьте корректность обычным test, затем измеряйте.

Benchmark живёт в `_test.go`, принимает `*testing.B` и в Go 1.24+ предпочтительно использует `b.Loop`. Измеряйте одну гипотезу, запускайте `-benchmem -count=N` и сравнивайте через `benchstat`.

Setup до первого `b.Loop` не измеряется. Не смешивайте `b.N` и `b.Loop`; не подменяйте end-to-end load test microbenchmark. Полный workflow: [Benchmarks](../performance/benchmarks.md).

## Пример в *_test.go

```go
func BenchmarkJoin(b *testing.B) {
	words := []string{"go", "backend", "service"}
	for b.Loop() {
		_ = strings.Join(words, "/")
	}
}
```

Нужны `strings`, `testing`, Go 1.24+. В запуске `go test -run='^$' -bench=Join -benchmem` ожидаются измерения времени и выделений. При изменении размера words добавьте несколько sub-benchmarks: стоимость на трёх коротких словах не отражает мегабайтный payload.

Fixture создаётся до Loop и не входит в measured time. Если цель — стоимость создания fixture (подготовленные тестовые данные и зависимости), перенесите эту операцию внутрь, прямо объяснив, что измеряете.

## Источники

- [`testing.B`](https://pkg.go.dev/testing#B)
- [`benchstat`](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat)

## Проверь себя

1. Почему setup вынесен из Loop?
2. Что benchmark не заменяет?

<details>
<summary>Ориентиры для ответа</summary>

1. Он не относится к стоимости самой проверяемой операции; если относится, его измеряют внутри.
2. Проверку correctness и нагрузочное измерение end-to-end latency.

</details>

---
title: Benchmarks
description: Воспроизводимые Go benchmarks, B.Loop и сравнение через benchstat.
tags:
  - go
  - performance
  - testing
updated: 2026-10-06
---

# Benchmarks

Benchmark многократно выполняет операцию и оценивает её стоимость. Он полезен для сравнения одной гипотезы на одинаковых входах.

Новый benchmark в Go 1.24+ предпочтительно пишет loop через `B.Loop`:

```go
func BenchmarkEncode(b *testing.B) {
	input := makeFixture()
	for b.Loop() {
		encode(input)
	}
}
```

Setup до первого `Loop` и cleanup после него не входят в measured interval. В проверенной toolchain Go 1.27.1 compiler сохраняет arguments/results вызовов и присвоенные переменные внутри синтаксического `for b.Loop() { ... }` живыми; условие должно быть записано именно как `b.Loop()`. Это защита от удаления измеряемой работы, а не обещание отключить все оптимизации или сохранить работу внутри любой helper function. Не смешивайте `B.Loop` и loop по `b.N`.

```bash
go test -run='^$' -bench=BenchmarkEncode -benchmem -count=10 ./pkg > before.txt
go test -run='^$' -bench=BenchmarkEncode -benchmem -count=10 ./pkg > after.txt
benchstat before.txt after.txt
```

## Качество измерения

- Фиксируйте Go version, OS/arch, CPU power mode и workload.
- Изолируйте background load; используйте несколько samples.
- Проверяйте correctness вне hot loop.
- Для parallel workload используйте `RunParallel`, но интерпретируйте contention (конкуренция за один ресурс, например lock) и scheduler effects отдельно.
- Не переносите microbenchmark result на end-to-end service без profile/load test.

## Самодостаточная измеряемая операция

В файл `encode_test.go` пакета `encode`, нужны `strconv` и `testing`:

```go
func BenchmarkFormatID(b *testing.B) {
	for b.Loop() {
		_ = strconv.FormatInt(123456789, 10)
	}
}
```

`go test -run='^$' -bench=FormatID -benchmem -count=5` выдаст `ns/op`, `B/op`, `allocs/op`. Здесь нет обещанного фиксированного результата: он зависит от compiler и hardware. Изменение на несколько ns/op без устойчивого различия между samples ещё не доказательство улучшения.

Для `RunParallel` величина ns/op описывает пропускную способность всех workers; это не p99 отдельного запроса. Блокировки, сеть и нагрузочный профиль сервиса проверяйте отдельно.

## Источники

- [`testing.B`](https://pkg.go.dev/testing#B)
- [`benchstat`](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat)

## Проверь себя

1. Почему один запуск не доказывает ускорение?
2. Что означает allocs/op?

<details>
<summary>Ориентиры для ответа</summary>

1. Возможны шум и изменения окружения; нужны несколько samples и одинаковые условия.
2. Среднее число выделений памяти на операцию, а не число всех живых объектов.

</details>

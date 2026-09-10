---
title: Benchmarks
description: Воспроизводимые Go benchmarks, B.Loop и сравнение через benchstat.
tags:
  - go
  - performance
  - testing
updated: 2026-09-10
---

# Benchmarks

Новый benchmark в Go 1.24+ предпочтительно пишет loop через `B.Loop`:

```go
func BenchmarkEncode(b *testing.B) {
    input := makeFixture()
    for b.Loop() {
        encode(input)
    }
}
```

Setup до первого `Loop` и cleanup после него не входят в measured interval; compiler сохраняет результаты calls внутри loop живыми. Не смешивайте `B.Loop` и loop по `b.N`.

```bash
go test -run='^$' -bench=BenchmarkEncode -benchmem -count=10 ./pkg > before.txt
go test -run='^$' -bench=BenchmarkEncode -benchmem -count=10 ./pkg > after.txt
benchstat before.txt after.txt
```

## Качество измерения

- Фиксируйте Go version, OS/arch, CPU power mode и workload.
- Изолируйте background load; используйте несколько samples.
- Проверяйте correctness вне hot loop.
- Для parallel workload используйте `RunParallel`, но интерпретируйте contention и scheduler effects отдельно.
- Не переносите microbenchmark result на end-to-end service без profile/load test.

## Источники

- [`testing.B`](https://pkg.go.dev/testing#B)
- [`benchstat`](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat)

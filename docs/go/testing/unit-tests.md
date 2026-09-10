---
title: Unit tests
description: Быстрые детерминированные тесты поведения Go-кода.
tags:
  - go
  - testing
updated: 2026-09-10
---

# Unit tests

Unit test проверяет небольшой behavior без реальной сети, БД и wall-clock ожиданий. Тестируйте public outcome и устойчивые invariants, а не последовательность внутренних private calls.

```go
func TestPrice_Discount(t *testing.T) {
    got, err := Price(1_000, 15)
    if err != nil {
        t.Fatalf("Price returned error: %v", err)
    }
    if want := int64(850); got != want {
        t.Fatalf("Price() = %d, want %d", got, want)
    }
}
```

Используйте `t.Helper()` в assertion helpers, `t.Cleanup()` для ресурсов и `t.TempDir()` для isolated filesystem. `t.Fatal` завершает текущую test goroutine через `Goexit`; не вызывайте его из произвольной worker goroutine.

Детерминизм требует контроля clock, randomness, environment и goroutine lifecycle. Не лечите гонку `time.Sleep`: используйте synchronization, fake clock или `testing/synctest` для поддерживаемой async-модели.

## Источники

- [`testing` package](https://pkg.go.dev/testing)
- [`testing/synctest`](https://pkg.go.dev/testing/synctest)

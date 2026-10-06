---
title: Unit tests
description: Быстрые детерминированные тесты поведения Go-кода.
tags:
  - go
  - testing
updated: 2026-10-06
---

# Unit tests

Unit test проверяет небольшой контракт быстро и без внешних сервисов. Он объясняет, какое поведение нельзя случайно сломать при изменении кода.

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

Детерминизм требует контроля clock, randomness, environment и goroutine lifecycle (жизненный цикл от запуска до завершения). Не лечите гонку `time.Sleep`: используйте synchronization, fake clock или `testing/synctest` для поддерживаемой async-модели.

## Реализация для примера цены

```go
func Price(amount int64, discount int64) (int64, error) {
	if amount < 0 || discount < 0 || discount > 100 {
		return 0, errors.New("invalid price or discount")
	}
	// Деление до умножения избегает overflow amount*100.
	keep := 100 - discount
	return amount/100*keep + amount%100*keep/100, nil
}
```

Нужен `errors`. В этом договоре цена хранится в целых минимальных единицах, результат округляется вниз. Для 1000 и 15 получается 850; для 1 и 50 — 0. Отдельные тесты нужны на 0/100% скидки, отрицательный вход и максимальную сумму. Не используйте float64 для денег без ясного правила точности и округления.

Поведение `t.Fatal` завершает текущую test goroutine, поэтому worker должен вернуть error тесту через канал/group. Иначе failure не гарантирует корректной остановки владельца теста.

## Источники

- [`testing` package](https://pkg.go.dev/testing)
- [`testing/synctest`](https://pkg.go.dev/testing/synctest)

## Проверь себя

1. Какой контракт округления у Price?
2. Почему helper test должен вызывать t.Helper?

<details>
<summary>Ориентиры для ответа</summary>

1. Вниз до целой минимальной единицы; его явно фиксируют и проверяют.
2. Чтобы сообщение об ошибке указывало на место использования проверки, а не внутренности helper.

</details>

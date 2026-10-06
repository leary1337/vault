---
title: Time и timers
description: Deadlines, monotonic time, ticker lifecycle и clock abstraction.
tags:
  - go
  - time
updated: 2026-10-06
---

# Time и timers

Часы календаря могут переводиться, а измерение прошедшего времени должно оставаться устойчивым. Go сохраняет монотонную компоненту для локальных измерений.

`time.Time` может содержать wall clock и monotonic reading. Duration arithmetic/comparison между values, полученными из `time.Now`, использует monotonic component, защищая elapsed measurement от wall-clock adjustments. Serialization теряет monotonic component.

Используйте UTC для storage/wire и явную location для presentation. Не вычисляйте календарный «день» как `24*time.Hour` в зонах с DST.

## Timer и Ticker: границы версий

`time.After` подходит, когда достаточно одного события; явный `Timer` нужен для управления `Stop`/`Reset`. Не выбирайте Timer только из-за старого предупреждения об удержании памяти.

В Go 1.23 появились сборка GC недостижимых незавершённых timers/tickers и synchronous timer channels. В Go 1.23–1.26 новые правила по умолчанию включены для главного модуля с `go 1.23` или выше; `GODEBUG=asynctimerchan=1` возвращает прежнее поведение. В Go 1.27 этот переключатель удалён: timer channels всегда synchronous, независимо от `go` directive. После `Stop`/`Reset` channel-based Timer новая реализация не выдаёт stale value от предыдущей настройки. Для `AfterFunc` правила другие: он запускает функцию, а не посылает значение в channel.

`Ticker.Stop` полезен для остановки дальнейших событий, но в новой реализации не обязателен ради GC. Он не закрывает `Ticker.C`: цикл `for range ticker.C` от этого не завершится. Lifecycle goroutine требует отдельного сигнала cancellation.

Для request timeouts обычно удобен context; вызывайте возвращённый `CancelFunc`, когда операция закончена.

В тестах time-dependent logic принимайте clock/timer boundary (граница ответственности между слоями) или используйте `testing/synctest` (стабильный API с Go 1.25, эксперимент в Go 1.24). Произвольные sleeps вместо synchronization делают tests медленными и flaky.

## См. также

- [Context](../concurrency/context.md)
- [Goroutine leaks](../concurrency/goroutine-leaks.md)

## Время, равенство и остановка ticker

```go
started := time.Now()
elapsed := time.Since(started) // локальное измерение monotonic clock
_ = elapsed

for {
	select {
	case <-ticker.C:
		// периодическая работа
	case <-ctx.Done():
		ticker.Stop()
		return
	}
}
```

Это фрагмент функции с заранее созданными `ticker` и `ctx`. `Ticker` может пропускать ticks, если получатель медленный: это сигнал времени, а не гарантированная очередь задач. `AfterFunc.Stop` не ждёт уже начавшийся callback; если нужно дождаться, добавьте отдельную синхронизацию.

Для смысла «один момент времени» используйте `Time.Equal`, а не `==`: raw comparison учитывает location и монотонные данные. Для map key заранее нормализуйте время, например `t.UTC().Round(0)`, если именно такая точность и UTC соответствуют контракту.

## Источники

- [`time` package](https://pkg.go.dev/time)
- [`testing/synctest`](https://pkg.go.dev/testing/synctest)
- [Go 1.23 timer channel changes](https://go.dev/wiki/Go123Timer)
- [Go 1.27: removal of asynctimerchan](https://go.dev/doc/go1.27#runtime)

## Проверь себя

1. Закроет ли ticker.Stop канал C?
2. Почему time.Time == может отличаться от Equal?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, цикл range не завершится; нужна отдельная отмена.
2. == сравнивает всё представление, Equal — момент с правилами monotonic/wall time.

</details>

---
title: Примитивы синхронизации
description: Mutex, RWMutex, WaitGroup, Once, Cond, Map и Pool в Go 1.27.
tags:
  - go
  - concurrency
  - sync
level:
  - middle
  - senior
updated: 2026-09-10
created: 2024-07-25
---

# Примитивы синхронизации

Типы `sync` нельзя копировать после начала использования. Обычно primitive принадлежит struct по значению, а сам struct передаётся pointer.

## `Mutex`

`Unlock` synchronized-before более позднего successful `Lock` того же mutex. Защищайте invariant, а не отдельное поле, и держите critical section короткой.

```go
type Counter struct {
    mu sync.Mutex
    n  int64
}

func (c *Counter) Inc() {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.n++
}
```

Mutex не связан с goroutine ownership: unlock может выполнить другая goroutine, но такой design редко понятен. `TryLock` нужен редко; failure не создаёт synchronization.

## `RWMutex`

`RWMutex` допускает несколько readers или одного writer. Он не гарантирует, что будет быстрее `Mutex`: bookkeeping и cache contention могут перевесить выгоду. Выбирайте после benchmark с реальным read/write ratio и critical-section cost.

Нельзя upgrade `RLock` в `Lock` или рекурсивно брать write lock. Writer expectation блокирует новые readers, чтобы writer мог продвинуться.

## `WaitGroup`

В Go 1.25+ предпочтителен `WaitGroup.Go`:

```go
var wg sync.WaitGroup
wg.Go(taskA)
wg.Go(taskB)
wg.Wait()
```

Function, переданная `Go`, не должна panic. Для error propagation/cancellation используйте `errgroup`, а не side-channel без ясного ownership.

Legacy pattern остаётся допустимым: `Add(1)` должен выполняться до запуска goroutine, затем `defer Done()`. Положительный `Add` при нулевом counter должен happen-before `Wait`.

## `Once`, `OnceValue`, `OnceValues`

`Once.Do` выполняет function ровно один раз; concurrent callers ждут её завершения. Panic считается выполнением: повторного вызова не будет. `OnceValue` и `OnceValues` возвращают memoized results и повторяют panic с тем же value для каждого caller.

```go
loadConfig := sync.OnceValues(func() (*Config, error) {
    return readConfig()
})
```

Если нужно retry initialization после transient error, `OnceValues` не подходит без дополнительного state machine.

## `Cond`

`Cond` используется, когда goroutines ждут изменения predicate под lock. Всегда проверяйте predicate в loop: wake-up не означает, что condition всё ещё true.

```go
c.L.Lock()
for !ready {
    c.Wait()
}
c.L.Unlock()
```

`Broadcast` похож на close channel для одноразового события; channel часто проще. `Cond` полезен для повторяющихся state transitions под общим lock.

## `sync.Map`

`sync.Map` специализирована: workload с write-once/read-many keys или операции по disjoint key sets. Для обычной typed map с compound invariants чаще лучше `map[K]V` + mutex. `Range` не является consistent snapshot.

## `sync.Pool`

Pool уменьшает allocation pressure для временных взаимозаменяемых объектов. Runtime может удалить любой item в любой момент; это не cache и не storage. Перед `Put` очистите чувствительные данные и не используйте object после передачи ownership pool.

## Как выбирать

- Mutex: общий mutable invariant.
- Atomic: одна независимая machine-word-like state transition.
- Channel: передача ownership/событий и coordination.
- RWMutex: доказанный read-heavy bottleneck.
- Cond: ожидание повторяющегося predicate под lock.

## Источники

- [`sync` package](https://pkg.go.dev/sync)
- [The Go Memory Model: Locks and Once](https://go.dev/ref/mem#hdr-Locks)
- [Go 1.25 Release Notes: `WaitGroup.Go`](https://go.dev/doc/go1.25#sync)

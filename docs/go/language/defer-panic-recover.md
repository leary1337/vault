---
title: Defer, panic и recover
description: Stack unwinding, границы восстановления и безопасное применение panic в Go.
tags:
  - go
  - errors
level:
  - middle
updated: 2026-09-10
created: 2024-07-24
---

# Defer, panic и recover

## `defer`

Вызов `defer f(args)` вычисляет function value и аргументы сразу, а сам вызов выполняется перед возвратом окружающей функции. Deferred calls выполняются в LIFO order. Они срабатывают при обычном return и при stack unwinding из-за panic.

```go
func read(path string) ([]byte, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer f.Close()
    return io.ReadAll(f)
}
```

Ошибку cleanup иногда нельзя терять; при записи файла её следует объединить или вернуть через named result с осторожной явной логикой.

## `panic`

`panic(v)` останавливает обычное выполнение текущей goroutine, запускает deferred calls в её stack frames и поднимается вверх. Если panic не восстановлена, runtime завершает программу и печатает stack trace.

Panic уместна для нарушенного внутреннего invariant или невозможной инициализации процесса. Ожидаемые внешние ошибки — invalid input, timeout, unavailable dependency — должны возвращаться как `error`.

## `recover`

`recover` останавливает активную panic только при прямом вызове из deferred function в той же goroutine.

```go
func runSafely(fn func()) (err error) {
    defer func() {
        if value := recover(); value != nil {
            err = fmt.Errorf("handler panic: %v", value)
        }
    }()
    fn()
    return nil
}
```

Recovery boundary не «исправляет» повреждённое состояние. Она должна:

- находиться вокруг независимой единицы работы, например request handler или worker job;
- записать stack (`debug.Stack`) во внутренний observability channel;
- отменить/закрыть затронутую работу;
- вернуть безопасный внешний ответ;
- не продолжать использовать state, чьи invariants могли быть нарушены.

## Panic в другой goroutine

`recover` родительской goroutine не перехватывает panic дочерней. Каждая goroutine, на boundary которой разрешено восстановление, должна устанавливать собственный deferred recovery.

```go
go func() {
    defer reportPanic()
    handle(job)
}()
```

Запуск goroutine без ownership также создаёт риск leak и потери ошибки. Предпочитайте structured lifecycle: context, error channel/errgroup и явное ожидание.

## Типичные ошибки

- Использовать panic как обычный error flow.
- Ставить один глобальный `recover` и скрывать programmer bugs.
- Вызывать `recover` не напрямую из deferred function.
- Терять cleanup error в безусловном `defer resource.Close()`.
- Считать, что recovery в `main` ловит panic всех goroutines.

## Вопросы для самопроверки

1. Когда вычисляются аргументы deferred call?
2. Почему `recover` не работает из другой goroutine?
3. Что должна сделать production recovery boundary?
4. Какие ошибки не следует превращать в panic?

## Источники

- [Go specification: Defer statements](https://go.dev/ref/spec#Defer_statements)
- [Go specification: Handling panics](https://go.dev/ref/spec#Handling_panics)
- [Go blog: Defer, Panic, and Recover](https://go.dev/blog/defer-panic-and-recover)

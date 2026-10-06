---
title: Defer, panic и recover
description: Stack unwinding, границы восстановления и безопасное применение panic в Go.
tags:
  - go
  - errors
level:
  - middle
updated: 2026-10-06
created: 2024-07-24
---

# Defer, panic и recover

defer откладывает уборку до выхода из функции. panic прерывает обычный путь, а recover позволяет восстановиться только на правильно поставленной границе.

## `defer`

Вызов `defer f(args)` вычисляет function value и аргументы сразу, а сам вызов выполняется перед возвратом окружающей функции. Deferred calls выполняются в LIFO order. Они срабатывают при обычном return и при stack (стек вызовов goroutine) unwinding из-за panic.

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

Panic уместна для нарушенного внутреннего invariant (условие, которое должно сохраняться при любом допустимом изменении) или невозможной инициализации процесса. Ожидаемые внешние ошибки — invalid input, timeout, unavailable dependency — должны возвращаться как `error`.

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

Recovery boundary (граница ответственности между слоями) не «исправляет» повреждённое состояние. Она должна:

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

Запуск goroutine без ownership (ответственность за изменение данных и завершение работы) также создаёт риск leak и потери ошибки. Предпочитайте structured lifecycle (жизненный цикл от запуска до завершения): context, error channel/errgroup и явное ожидание.

## Типичные ошибки

- Использовать panic как обычный error flow.
- Ставить один глобальный `recover` и скрывать programmer bugs.
- Вызывать `recover` не напрямую из deferred function.
- Терять cleanup error в безусловном `defer resource.Close()`.
- Считать, что recovery в `main` ловит panic всех goroutines.

## Порядок видно на коротком примере

Фрагмент внутри `main`, нужен импорт `fmt`:

```go
n := 1
defer fmt.Println("argument", n)
defer func() { fmt.Println("closure", n) }()
n = 2
// при выходе: closure 2, затем argument 1
```

Аргумент первого defer вычислен заранее; замыкание читает переменную позже. `os.Exit` не запускает defer. Defer внутри длинного цикла выполняется при выходе всей функции и может накопить открытые файлы: вынесите одну итерацию в отдельную функцию.

## Источники

- [Go specification: Defer statements](https://go.dev/ref/spec#Defer_statements)
- [Go specification: Handling panics](https://go.dev/ref/spec#Handling_panics)
- [Go blog: Defer, Panic, and Recover](https://go.dev/blog/defer-panic-and-recover)

## Проверь себя

1. Почему аргумент и замыкание печатают разные n?
2. Сработает ли defer после os.Exit?

<details>
<summary>Ориентиры для ответа</summary>

1. Обычный аргумент фиксируется при defer, замыкание читает n при вызове.
2. Нет. Завершение процесса обходится без выполнения отложенных вызовов.

</details>

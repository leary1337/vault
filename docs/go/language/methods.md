---
title: "Методы"
description: "Метод — функция, связанная с определённым типом через получателя (receiver)."
tags:
  - go
created: 2024-07-24
updated: 2026-10-06
---

# Методы

Метод — функция, связанная с определённым типом через **получателя** (receiver). Получатель записан перед именем метода. Например, у `Person` может быть метод приветствия:

```go
package main

import "fmt"

type Person struct {
	Name string
	Age  int
}

func (p Person) Greet() {
	fmt.Printf("Hello, my name is %s and I am %d years old.\n", p.Name, p.Age)
}

func main() {
	person := Person{Name: "John", Age: 30}
	person.Greet() // Вызов метода Greet
}
```

`p Person` получает значение того объекта, на котором вызван `Greet`. Метод можно объявить для собственного определённого типа `T` из того же пакета или для `*T`; базовый `T` не может быть указателем или интерфейсом. Поэтому метод у `type UserID int64` допустим, а добавление метода к встроенному `int` или чужому `time.Time` — нет.

## Значение и указатель как получатели

Получатель-значение копируется так же, как обычный аргумент. Изменение числового поля копии не меняет оригинал:

```go
func (p Person) CelebrateBirthday() {
	p.Age++
	fmt.Println("Inside method with value receiver:", p.Age)
}

func main() {
	p := Person{Name: "Alice", Age: 40}
	p.CelebrateBirthday()
	fmt.Println("After method call with value receiver:", p.Age)
}
```

Вывод:

```
Inside method with value receiver: 41
After method call with value receiver: 40
```

Получатель-указатель даёт доступ к исходному объекту:

```go
func (p *Person) CelebrateBirthday() {
	p.Age++
	fmt.Println("Inside method with pointer receiver:", p.Age)
}

func main() {
	p := Person{Name: "Bob", Age: 40}
	p.CelebrateBirthday()
	fmt.Println("After method call with pointer receiver:", p.Age)
}
```

Вывод:

```
Inside method with pointer receiver: 41
After method call with pointer receiver: 41
```

## Копия получателя и общие данные

Копирование структуры не означает копирования всех данных под её полями. Срез внутри копии всё ещё может ссылаться на прежний массив:

```go
package main

import "fmt"

type Batch struct {
	Count int
	IDs   []int
}

func (b Batch) Change() {
	b.Count = 99
	b.IDs[0] = 99
}

func main() {
	b := Batch{Count: 1, IDs: []int{1}}
	b.Change()
	fmt.Println(b.Count, b.IDs) // 1 [99]
}
```

Поэтому `IDs` меняется снаружи, а `Count` — нет. Метод изменил общий массив, но числовое поле изменил только в собственной копии.

## Набор методов и интерфейс

У `T` есть методы с получателем `T`; у `*T` — с `T` и `*T`. Для переменной, адрес которой можно взять, `p.PointerMethod()` может означать `(&p).PointerMethod()`. При присваивании интерфейсу компилятор такой адаптации не делает. Элемент карты не адресуем: непосредственно вызвать его метод с получателем-указателем нельзя.

Указатель выбирают, когда метод меняет объект, объект велик или его нельзя копировать после начала использования, как `sync.Mutex`. Значение удобно для небольшого объекта с понятным смыслом копии. Скорость нужно измерять, а не предполагать по виду получателя.

## Сохранённый метод

`f := p.Greet` сохраняет получатель при создании `f`. Выражение `Person.Greet` даёт функцию, у которой `Person` передаётся первым явным аргументом. Это различие важно, если объект меняется между созданием функции и вызовом.

## Источники

- [Go specification: declarations and scope](https://go.dev/ref/spec#Declarations_and_scope)
- [Go specification: method declarations](https://go.dev/ref/spec#Method_declarations)
- [Go specification: calls](https://go.dev/ref/spec#Calls)

## Проверь себя

1. Почему `Batch.Change` меняет `IDs`, но не `Count`?
2. Реализует ли `T` интерфейс с методом, объявленным только для `*T`?

<details>
<summary>Ответы</summary>

1. Число копируется, а описание среза ведёт к общему массиву.
2. Нет. Автоматическое взятие адреса при обычном вызове не действует при присваивании интерфейсу.

</details>

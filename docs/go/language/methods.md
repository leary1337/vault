---
title: "Методы"
description: Method declarations, receivers, method sets и embedding в Go.
tags:
  - go
created: 2024-07-24
updated: 2026-10-06
---

# Методы

Метод — функция, у которой перед именем указан получатель. Он связывает действие с типом, но не превращает копирование значения в глубокое копирование.

### Описание

**Методы в Go (Golang)** — это [функции](functions.md), которые имеют *получателя (receiver)*. Метод объявляют для определённого типа `T` из того же пакета или для `*T`; базовый `T` не может быть указателем или интерфейсом. Например, можно добавить метод к `type UserID int64`, но нельзя напрямую к встроенному `int` или чужому `time.Time`. Методы позволяют связывать определенные функции с типами данных, что улучшает организацию кода и его читаемость.
#### Определение метода

Методы определяются так же, как и функции, но с добавлением получателя перед именем метода. Получатель указывается в скобках, и это позволяет методу «знать», к какому типу он относится.
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

В примере выше мы создаем структуру Person с полями Name и Age, а также метод Greet, который выводит приветственное сообщение. Метод Greet привязан к типу Person через получателя p Person.
#### Значение и указатель как получатели

Методы могут использовать как значение, так и указатель в качестве получателя. Это важно для управления изменениями состояния объекта.

**Методы со значением как получателем**:
	При передаче значения метод получает копию самого получателя. Изменение числового поля копии не меняет оригинал. Но копирование структуры **не копирует глубоко** массивы под slice, данные map и объекты под указателями: изменение этих общих данных видно оригиналу.

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

**Методы с указателем как получателем**:
	При использовании указателя метод *может изменять* состояние объекта, поскольку работает с оригинальными данными.

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

Полная программа: скаляр копируется, а slice продолжает ссылаться на общий массив.

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

## Набор методов и интерфейс

`T` имеет методы с получателем `T`; `*T` — с получателями `T` и `*T`. Для адресуемой переменной `p` вызов `p.PointerMethod()` может автоматически стать `(&p).PointerMethod()`. Присваивание интерфейсу такую адаптацию не делает. Элемент map не адресуем: вызвать на нём метод с pointer receiver напрямую нельзя.

Указатель выбирают для изменения состояния, большого объекта и типов, которые нельзя копировать после использования (`sync.Mutex`). Value receiver подходит для небольшого значения с ясной семантикой копирования. Не выбирайте указатель исключительно по правилу «так быстрее»: размещение и оптимизации проверяют измерением.

Method value `f := p.Greet` сохраняет получатель при создании `f`. Method expression `Person.Greet` — функция с явным первым аргументом `Person`.

### Краткое содержание

**Методы в Go** — это функции, привязанные к определенным типам данных через получателя. *Получателем может быть либо значение, либо указатель*, что влияет на то, как метод взаимодействует с данными. Методы помогают структурировать код и придают логичность его организации.

## Источники

- [Go specification: declarations and scope](https://go.dev/ref/spec#Declarations_and_scope)
- [Go specification: method declarations](https://go.dev/ref/spec#Method_declarations)
- [Go specification: calls](https://go.dev/ref/spec#Calls)

## Проверь себя

1. Почему Batch.Change меняет IDs, но не Count?
2. Реализует ли T интерфейс с методом, объявленным только для *T?

<details>
<summary>Ориентиры для ответа</summary>

1. Count скопирован, а slice в копии указывает на тот же массив.
2. Нет. Автоматическое взятие адреса при вызове метода не действует при присваивании интерфейсу.

</details>

---
title: "Интерфейсы в Go"
tags:
  - go
created: 2024-07-28
---

# Интерфейсы в Go

### Описание

**Интерфейс в Go** - набор сигнатур методов, которые надо реализовать, чтобы удовлетворить контракту.

```go
type Stringer interface {
	String() string
}

type Shape interface {
	Area() float64
	Perimeter() float64
}
```

- Одному интерфейсу могут соответствовать много типов
- Тип может реализовать несколько интерфейсов
#### Утиная типизация 🦆

В Go используется **утиная типизация (duck typing)**: не нужно явно указывать, что тип реализует интерфейс. Достаточно просто реализовать необходимые методы, и тип будет удовлетворять интерфейсу.
#### Типы

Переменная *типа интерфейс* может содержать значение типа, реализующего этот интерфейс

```go
var s Stringer  // статический тип
s = time.Time{} // динамический тип
```

- Значение типа интерфейс состоит из динамического типа и значения
- Мы можем их смотреть при помощи `%v` и `%T` или с помощью `reflect`
#### Пример использования интерфейсов

```go
type Duck interface {  
    Talk() string  
    Walk()  
}  
  
type Dog struct {  
    name string  
}  
  
func (d Dog) Talk() string {  
    return fmt.Sprintf("Dog %s", d.name)  
}  

// Pointer receiver!
func (d *Dog) Walk() {  
    fmt.Println("Walk...")  
}
  
func quack(d Duck) {  
    fmt.Println(d.Talk())  
}  
  
func main() {
	// cannot use Dog{…} (value of type Dog) as Duck value in argument to quack:
	// Dog does not implement Duck (method Walk has pointer receiver)
    quack(Dog{name: "Charlie"})
	
	quack(&Dog{name: "Charlie"}) // Dog Charlie
}
```

- **Value Receiver**: если методы интерфейса имеют value receiver, то и структура, и указатель на структуру могут удовлетворять этому интерфейсу, поскольку Go автоматически делает копию структуры, если метод вызывает значение.

- **Pointer Receiver**: если метод(-ы) интерфейса имеют pointer receiver, *то только указатель на структуру может удовлетворять интерфейсу*. Это связано с тем, что Go не может автоматически преобразовать структуру в указатель, когда вызывается метод с pointer receiver.
#### Композиция

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Closer interface {
    Close() error
}

type ReadCloser interface {
    Reader
    Closer
}
```

В Go принят идиоматический подход при котором определяем маленькие интерфейсы, а затем уже работаем с композицией этих интерфейсов.

"Чем больше интерфейс - тем слабее абстракция"
#### Пустой интерфейс 👀

![](https://i.imgur.com/uaWJfyq.png)

```go
var s interface{}
var s any
```

- Любой тип реализует пустой интерфейс
- Не нужно им злоупотреблять!
#### Внутреннее устройство

![](https://i.imgur.com/pwFHE3I.png)

```go
type iface struct {  
    tab  *itab          // Информация об интерфейсе
    data unsafe.Pointer // Хранимые данные
}

// itab содержит тип интерфейса и информацию о хранином типе
type itab struct {
    inter *interfacetype // Метаданные интерфейса (статический тип)
    _type *_type         // Go-шный тип хранимого интерфейсом значения (динамический тип)
	hash  uint32         // copy of _type.hash. Used for type switches.
    _     [4]byte        // Выравнивание структуры в памяти
    fun   [1]uintptr     // Список методов динамического типа, удовлетворяющих интерфейсу  
}

type InterfaceType struct {  
    Type  
    PkgPath Name      // import path  
    Methods []Imethod // sorted by hash  
}
```

Вызов метода интерфейса в Go происходит следующим образом:

1) **Статический тип:** В интерфейсе описаны методы, которые должны быть реализованы типом. Когда вызывается метод через интерфейс, сначала вызывается метод статического типа интерфейса. Это определяет, какой метод должен быть вызван на основании сигнатуры, объявленной в интерфейсе.

2) **Runtime:** Во время выполнения (`runtime`) происходит динамическое связывание метода. Интерфейс содержит информацию о том, какой конкретный тип (динамический тип) реализует методы, указанные в интерфейсе. Эта информация хранится в скрытой таблице (vtable), которая ассоциирует методы интерфейса с методами конкретного типа.

Проще говоря, вызов метода интерфейса в Go сначала определяет метод по его сигнатуре (статический тип), а затем в runtime выбирает правильную реализацию (динамический тип) и вызывает её.

**На этапе компиляции:**
- Генерируются метаданные для каждого статического типа, включая его список методов.
- Генерируются метаданные для каждого интерфейса, включая его список методов.

И при компиляции и в runtime в зависимости от выражения:
- Сравниваются methodset (набор методов) типа и интерфейса.
- Создается и кэшируется itab.

**Создание интерфейса:**
1) Аллокация места для хранения адреса ресивера.
2) Получение `itab`.
3) Проверка кэша.
4) Нахождение реализации методов.
5) Создание `iface`: `runtime.convT2I`
```go
s := Speaker(Human{Greeting: "Hello!"})
```

Динамический диспатчинг:
- Для `runtime` это вызов n-го метода `s.Method_0()`.
- Превращается в вызов вида `s.itab.fun[0](s.data)`.

```go
s.SayHello()
```
Метод `s.SayHello()` будет динамически связан с реализацией метода `SayHello` для типа `Human`, определенного в момент присваивания значения интерфейсной переменной `s`.
#### Практическое использование интерфейсов

*Zero value* интерфейса = `nil`

```go
type IHTTPClient interface {  
    Do(req *http.Request) (*http.Response, error)  
}  
  
func main() {  
    var c IHTTPClient  
    fmt.Println("value of client is", c)    // value of client is <nil>
    fmt.Printf("type of client is %T\n", c) // type of client is <nil>
    fmt.Println("(c == nil) is", c == nil)  // (c == nil) is true
}
```

**Опасный `nil`:**
```go
type MyErr struct{}  
  
func (m MyErr) Error() string {  
    return "my err string"  
}  
  
func main() {  
    fmt.Println(returnError() == nil)          // true
    fmt.Println(returnErrorPtr() == nil)       // true
    fmt.Println(returnCustomError() == nil)    // false
    fmt.Println(returnCustomErrorPtr() == nil) // false
    fmt.Println(returnMyError() == nil)        // true
}  
  
func returnError() error {  
    var err error
    return err // Error = nil
}  
  
func returnErrorPtr() *error {  
    var err *error
    return err // *Error = nil
}  
  
func returnCustomError() error {  
    var customErr MyErr // struct MyErr = nil
    return customErr    // Error(MyErr=nil) != nil
}  
  
func returnCustomErrorPtr() error {  
    var customErr *MyErr // pointer to customErr = nil, 
    return customErr     // Error(*MyErr=nil) != nil 
}  
  
func returnMyError() *MyErr {  
    return nil // *MyErr = nil
}
```

**Важные моменты:**
1. **`returnError()`**: В данном случае, `returnError() == nil` вернет `true`, так как переменная `err` равна `nil` и никакого типа в ней нет.

2. **`returnErrorPtr()`**: Вернет `true`, так как указатель на `error` равен `nil`.

3. **`returnCustomError()`**: Здесь создается переменная `customErr` типа `MyErr`, которая имеет метод `Error()`, реализующий интерфейс `error`. Даже если переменная `customErr` содержит значение по умолчанию, оно не равно `nil`. Поэтому `returnCustomError() == nil` вернет `false`.

4. **`returnCustomErrorPtr()`**: Возвращает указатель на структуру `MyErr`. В этом случае, даже если указатель `customErr` равен `nil`, проверка `returnCustomErrorPtr() == nil` вернет `false`.

5. **`returnMyError()`**: Явно возвращает `nil` для типа `*MyErr`. Проверка `returnMyError() == nil` вернет `true`.

Этот пример подчеркивает важность правильного понимания проверки интерфейсов на `nil`, особенно в контексте того, когда тип в интерфейсе присутствует, но само значение может быть `nil`.
#### Проверка типов (Type Assertion)

Позволяет проверять и извлекать динамический тип из интерфейса.

Выражение `x.(T)` проверяет, что интерфейс `x` не равен `nil` и что конкретная часть `x` имеет тип `T`.

1. **Если `T` не интерфейс**, то проверяется, что динамический тип `x` соответствует `T`. То есть, `x` должен быть экземпляром конкретного типа `T`.

2. **Если `T` интерфейс**, то проверяется, что динамический тип `x` реализует интерфейс `T`. В этом случае, `x` должен быть экземпляром типа, который реализует интерфейс `T`.

```go
var i interface{} = "hello"  
  
s := i.(string)  
fmt.Println(s)       // hello  
  
s, ok := i.(string)  
fmt.Println(s, ok)   // hello true  
  
r, ok := i.(fmt.Stringer)  
fmt.Println(r, ok)   // <nil> false  
  
f, ok := i.(float64)  
fmt.Println(f, ok)   // 0 false  
  
f := i.(float64)     // panic: interface conversion: interface {} is string, not float64  
fmt.Println(f)       // because ok = false
```
#### Switch по типам (Type Switch)

**Type Switch** позволяет безопасно и удобно работать с различными реализациями интерфейса, обрабатывать разные типы данных по-разному. В данном примере функция проверяет, к какому криптографическому алгоритму относится предоставленный открытый ключ, и выполняет соответствующую обработку:

```go
func checkSignature(/* ... */, publicKey crypto.PublicKey) (err error) {
    // ...
    switch pub := publicKey.(type) {
    case *rsa.PublicKey:
        // Обработка RSA ключа
    case *ecdsa.PublicKey:
        // Обработка ECDSA ключа
    case ed25519.PublicKey:
        // Обработка Ed25519 ключа
    default:
        return ErrUnsupportedAlgorithm
    }
}
```
#### Приведение типов (Cast):

Приведение типов в Go возможно только если конкретный тип, находящийся под интерфейсом, реализует все методы целевого интерфейса.


```go
type BaseStorage interface {
    Close()
}

type SyncStorage interface {
    Close()
    Sync()
}

func main() {
    var s BaseStorage
    _ = SyncStorage(s)
}
```

`SyncStorage` требует наличие методов `Close()` и `Sync()`. Если конкретный тип, содержащийся в `s`, реализует эти методы, приведение будет успешным, иначе будет **паника** (если не используется вариант с проверкой, как в Type Assertion).
### Краткое содержание

**Интерфейс в Go** - набор сигнатур методов, которые надо реализовать, чтобы удовлетворить контракту. В Go используется **утиная типизация (duck typing)**: не нужно явно указывать, что тип реализует интерфейс. Достаточно просто реализовать необходимые методы, и тип будет удовлетворять интерфейсу.

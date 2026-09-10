---
title: Strings, bytes и runes
description: Байтовая семантика строк Go и корректная работа с UTF-8.
tags:
  - go
  - strings
  - unicode
level:
  - middle
updated: 2026-09-10
---

# Strings, bytes и runes

## Что гарантировано

`string` — immutable sequence of bytes. Строка может содержать произвольные байты, включая невалидный UTF-8. Индексация возвращает byte, `len` — число байтов.

```go
s := "Привет"
fmt.Println(len(s))    // 12 bytes in UTF-8
fmt.Printf("%x\n", s[0])

invalid := string([]byte{0xff, 0xfe})
fmt.Println(utf8.ValidString(invalid)) // false
```

`byte` — alias для `uint8`; `rune` — alias для `int32` и обычно хранит Unicode code point. Ни rune, ни byte сами по себе не являются «символом, видимым пользователю»: grapheme cluster может состоять из нескольких code points.

## `range` по string

`range` декодирует UTF-8. Index — byte offset начала rune. Для невалидной последовательности iteration выдаёт `utf8.RuneError` шириной один byte.

```go
for byteOffset, r := range "Go界" {
    fmt.Printf("%d: %U\n", byteOffset, r)
}
```

Для количества decoded runes используйте `utf8.RuneCountInString`, но сначала решите, что нужно продукту: bytes, code points или grapheme clusters.

## Conversions и allocations

`[]byte(s)` создаёт изменяемую байтовую копию, `string(b)` — immutable string value. Спецификация задаёт результат conversion, но не обещает конкретное число allocations: compiler может оптимизировать временные conversions, если observable semantics сохраняется. Не используйте unsafe zero-copy conversion без измеримой причины и строгого контроля lifetime/immutability.

```go
payload := []byte("hello")
payload[0] = 'H'
text := string(payload)
```

Для text processing удобен пакет `strings`, для mutable byte buffers и binary protocols — `bytes`; для UTF-8 validation/decoding — `unicode/utf8`.

## Типичные ошибки

- `len(s)` как число пользовательских символов.
- Slice строки по случайным byte offsets: результат может стать invalid UTF-8.
- Conversion всей строки в `[]rune`, когда нужен streaming scan: это создаёт дополнительное представление данных.
- Case folding и normalization «вручную»: Unicode сложнее сопоставления одной rune одной букве.

## Production-нюансы

Валидируйте UTF-8 на trust boundary, если downstream требует текст. Для лимита размера сначала ограничивайте bytes до allocation/read, затем отдельно применяйте продуктовые ограничения по code points или grapheme clusters. Не логируйте неочищенные control characters из внешнего ввода.

## Вопросы для самопроверки

1. Что возвращает `s[i]`?
2. Почему `len("界")` не равен одному?
3. Что делает `range` при invalid UTF-8?
4. Когда conversion между string и `[]byte` может быть заметной по памяти?

## Источники

- [Go specification: String types](https://go.dev/ref/spec#String_types)
- [Go blog: Strings, bytes, runes and characters](https://go.dev/blog/strings)
- [`unicode/utf8`](https://pkg.go.dev/unicode/utf8)

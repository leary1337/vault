---
title: "Fuzzing"
description: "Fuzzing автоматически создаёт неожиданные входы и ищет нарушения свойства программы."
tags:
  - go
  - testing
  - security
updated: 2026-10-06
---

# Fuzzing

Fuzzing автоматически создаёт неожиданные входы и ищет нарушения свойства программы. В Go он поддерживается с 1.18 и использует покрытие для выбора новых вариантов. Хорошие цели — парсеры, декодировщики и границы внешних данных.

```go
func FuzzParseID(f *testing.F) {
	f.Add("42")
	f.Add("")
	f.Fuzz(func(t *testing.T, input string) {
		id, err := ParseID(input)
		if err == nil && id < 0 {
			t.Fatalf("negative id %d for %q", id, input)
		}
	})
}
```

```bash
go test -fuzz=FuzzParseID -fuzztime=30s ./pkg
```

## Самодостаточный пример

```go
func FuzzHexRoundTrip(f *testing.F) {
	f.Add([]byte("Go"))
	f.Add([]byte{})
	f.Fuzz(func(t *testing.T, input []byte) {
		encoded := hex.EncodeToString(input)
		decoded, err := hex.DecodeString(encoded)
		if err != nil || !bytes.Equal(decoded, input) {
			t.Fatalf("round trip failed: %v", err)
		}
	})
}
```

В `_test.go` нужны `bytes`, `encoding/hex`, `testing`. Обычный `go test` запускает сохранённые входы. `go test -fuzz=FuzzHexRoundTrip -fuzztime=10s` ищет новые.

После кодирования и декодирования байты должны совпасть. Если операция намеренно нормализует данные, такое свойство неверно; можно проверить `normalize(normalize(x))=normalize(x)`.

## Воспроизводимость и пределы

Цель должна быть быстрой, детерминированной и изолированной: входы исполняются параллельно и в неизвестном порядке. Ограничивайте память, рекурсию и расширение данных, иначе тестовая система исчерпает ресурсы вместо поиска полезной ошибки.

Уменьшенный ошибочный вход сохраняется в корпусе и должен воспроизводиться обычным тестом. Это позволяет исправление не забыть в дальнейшем.

## Источники

- [Go Fuzzing](https://go.dev/doc/security/fuzz/)
- [Fuzzing tutorial](https://go.dev/doc/tutorial/fuzz)

## Проверь себя

1. Чем обычный запуск отличается от поиска fuzzing?
2. Почему нужно ограничивать расширение входа?

<details>
<summary>Ответы</summary>

1. Первый исполняет сохранённые случаи, второй создаёт и меняет новые.
2. Иначе сама тестовая система может исчерпать память.

</details>

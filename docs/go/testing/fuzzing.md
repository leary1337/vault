---
title: Fuzzing
description: Coverage-guided fuzz tests для parsers, codecs и trust boundaries.
tags:
  - go
  - testing
  - security
updated: 2026-10-06
---

# Fuzzing

Fuzzing автоматически подбирает неожиданные входы. Лучше проверять свойство результата, а не список заранее известных строк.

Go toolchain поддерживает coverage-guided fuzzing с Go 1.18. Хорошие targets: parsers, decoders, validation, round-trip и security boundaries.

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

Target должен быть быстрым, deterministic и isolated: engine выполняет cases параллельно и в неопределённом порядке. Ограничивайте allocations/recursion/input expansion, иначе fuzzing найдёт только resource exhaustion harness-а. Минимизированный failing input добавляется в corpus и должен воспроизводиться обычным `go test`.

## Самодостаточное свойство кодека

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

В `_test.go` нужны `bytes`, `encoding/hex`, `testing`. Обычный `go test` выполнит seeds, `go test -fuzz=FuzzHexRoundTrip -fuzztime=10s` будет искать новые входы. Если ваша нормализация намеренно меняет вход, round-trip equality не подходит: сформулируйте корректное свойство вроде идемпотентности `normalize(normalize(x))=normalize(x)`.

## Источники

- [Go Fuzzing](https://go.dev/doc/security/fuzz/)
- [Fuzzing tutorial](https://go.dev/doc/tutorial/fuzz)

## Проверь себя

1. Чем seed-run отличается от fuzz-run?
2. Почему нельзя бесконтрольно расширять вход?

<details>
<summary>Ориентиры для ответа</summary>

1. Обычный test выполняет сохранённые входы; fuzz engine создаёт и мутирует новые.
2. Harness сам может исчерпать память и скрыть полезные ошибки target.

</details>

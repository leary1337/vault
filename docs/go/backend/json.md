---
title: JSON в Go
description: Безопасное JSON-кодирование, decoding limits и versioning API.
tags:
  - go
  - json
updated: 2026-09-10
---

# JSON в Go

Определяйте transport DTO отдельно от domain model, если API versioning/security требует независимости. Exported fields и struct tags формируют wire contract.

```go
type CreateRequest struct {
    Name string `json:"name"`
}

body := http.MaxBytesReader(w, r.Body, 1<<20)
dec := json.NewDecoder(body)
dec.DisallowUnknownFields()
```

После первого value убедитесь, что нет второго trailing JSON value. `DisallowUnknownFields` — policy: он полезен для strict commands, но может мешать forward compatibility у tolerant readers.

Числа, `time.Time`, `omitempty`, nil/empty slices и custom marshalers имеют wire consequences — закрепляйте contract tests. Не декодируйте untrusted payload в `map[string]any`, если schema известна; JSON numbers там по умолчанию становятся `float64`, если не вызвать `UseNumber`.

Go 1.27 добавил production `encoding/json/v2` с более строгими/configurable semantics, а legacy `encoding/json` сохраняет compatibility. Migration требует contract diff и не должна быть механической заменой import.

## Источники

- [`encoding/json`](https://pkg.go.dev/encoding/json)
- [`encoding/json/v2`](https://pkg.go.dev/encoding/json/v2)
- [Go 1.27 Release Notes](https://go.dev/doc/go1.27)

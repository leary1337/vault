---
title: Table-driven tests
description: Компактная проверка классов входов и edge cases через subtests.
tags:
  - go
  - testing
updated: 2026-09-10
---

# Table-driven tests

Table-driven form полезна, когда cases имеют одинаковый arrange/act/assert flow.

```go
func TestParseID(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int64
        wantErr bool
    }{
        {name: "valid", input: "42", want: 42},
        {name: "empty", input: "", wantErr: true},
        {name: "negative", input: "-1", wantErr: true},
    }

    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            got, err := ParseID(tc.input)
            if (err != nil) != tc.wantErr {
                t.Fatalf("error = %v, wantErr %v", err, tc.wantErr)
            }
            if !tc.wantErr && got != tc.want {
                t.Fatalf("got %d, want %d", got, tc.want)
            }
        })
    }
}
```

Имена subtests должны объяснять класс поведения. Не превращайте table в DSL с десятками optional fields. `t.Parallel` применяйте только если fixtures/state изолированы; loop capture semantics зависят от module language version, поэтому код должен быть понятен и без ловушек совместимости.

## Источники

- [`testing.T.Run`](https://pkg.go.dev/testing#T.Run)
- [Go Wiki: TableDrivenTests](https://go.dev/wiki/TableDrivenTests)

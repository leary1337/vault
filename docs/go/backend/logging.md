---
title: Structured logging в Go
description: slog, ownership логирования, PII и управление cardinality/volume.
tags:
  - go
  - logging
  - observability
updated: 2026-10-06
---

# Structured logging в Go

Структурированный лог хранит событие и отдельные поля, чтобы их можно было искать и группировать. Он должен объяснять исход операции без утечки секретов.

`log/slog` записывает message + typed attributes. Logger передавайте как dependency; context version нужна для handler, которому важны context data/cancellation.

```go
logger.InfoContext(ctx, "request completed",
	"method", r.Method,
	"route", routeTemplate,
	"status", status,
	"duration_ms", duration.Milliseconds(),
)
```

Используйте route template, а не raw path/user ID как metric label; в logs high-cardinality (число различных значений поля или набора labels) values допустимы только при privacy/cost policy. Секреты, tokens, passwords и raw payloads не логируются. PII (персональные данные) требует redaction, retention (удержание достижимых данных в памяти) и access control.

Error обычно логируется один раз на boundary (граница ответственности между слоями) с operation, request/trace ID и outcome. Нижние слои wrapping-ят и возвращают error. Sampling применяйте к повторяющимся non-audit events; security/audit logs имеют отдельные гарантии доставки и integrity.

## Полный минимальный slog

```go
package main

import (
	"log/slog"
	"os"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	logger.With("service", "ads").Info("ad created", "ad_id", 42)
}
```

Вывод — одна JSON-запись с `level=INFO`, `msg=ad created`, `service=ads`, `ad_id=42` и временем. Порядок полей не является бизнес-контрактом.

Логирование дорогостоящего атрибута вычисляет аргумент даже при выключенном уровне. Для тяжёлой подготовки проверьте `logger.Enabled(ctx, slog.LevelDebug)` или используйте `LogValuer`. `InfoContext` само по себе не добавляет trace ID: его извлекает настроенный Handler. Выбирайте стабильные ключи и измеряйте скорость/объём логов.

## Источники

- [`log/slog`](https://pkg.go.dev/log/slog)
- [Go blog: Structured Logging with slog](https://go.dev/blog/slog)

## Проверь себя

1. Добавляет ли InfoContext trace_id автоматически?
2. Почему не нужно логировать одну ошибку на всех слоях?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, это должен делать настроенный handler или приложение.
2. Получаются дубли; нижние слои возвращают контекст, владелец исхода логирует один раз.

</details>

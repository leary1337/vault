---
title: Logs
description: Structured logging, correlation, безопасность, sampling и стоимость.
tags: [observability, logging, security]
updated: 2026-10-06
---

# Logs

Лог хранит отдельное событие; поля позволяют найти и сопоставить события без разбора свободного текста.

Log — запись о дискретном событии. Он полезен, когда содержит стабильную структуру и отвечает, что произошло, где, с каким outcome и каким diagnostic context. Свободный текст остаётся сообщением для человека, но не заменяет поля.

## Схема события

Минимальный набор: timestamp, severity, service, version, environment, operation, outcome и error category. По необходимости добавляют duration, dependency, retry attempt, request/correlation ID, `trace_id`/`span_id` и business entity ID с учётом privacy.

Идентификаторы помогают найти связанные записи, но не доказывают причинность. Trace (связь этапов одной операции) context лучше отражает parent-child путь. Audit log отделяют от debug/application logs: у него другие полнота, доступ, retention (срок хранения) и защита от изменения.

## Уровни и ответственность

- `DEBUG` — подробность для ограниченной диагностики;
- `INFO` — значимое нормальное изменение состояния;
- `WARN` — деградация или восстановимый anomaly;
- `ERROR` — операция не достигла обещанного результата и требует анализа.

Ошибка должна логироваться один раз на boundary, где добавлен контекст или принято решение. Если repository, service и HTTP handler логируют один и тот же error, объём утраивается и misleading alert counting становится вероятным. Внутренние функции обычно возвращают wrapped error; входной boundary пишет итоговый log.

## Контекст и безопасность

Не записывайте пароли, токены, cookies, authorization headers, private keys и connection strings. PII (персональные данные) собирайте только при доказанной необходимости, с redaction, access control и retention/deletion policy. Пользовательский ввод не должен менять структуру записи; кодируйте его как поле и защищайтесь от log injection.

Incoming correlation (совпадение/связь наблюдений, ещё не доказанная причина) IDs недоверенны: проверяйте формат/длину или создавайте собственный ID. Не используйте request/trace ID как idempotency key.

## Выборка и стоимость

Debug/info events можно детерминированно sample по trace/request ID, чтобы сохранять связные цепочки. Не sample audit/security events и редкие critical failures без отдельной гарантии. Head sampling дешёв, но не знает outcome; tail policy может оставить errors/slow traces, но требует буфера и ресурсов.

Управляйте объёмом до ingestion: уровни, фильтры, aggregation повторов, ограничения payload (полезное содержимое запроса или события), retention tiers. Стоимость растёт из-за количества событий, размера записи, индексации полей и срока хранения.

## Источники

- [OpenTelemetry log data model](https://opentelemetry.io/docs/specs/otel/logs/data-model/)
- [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)

## Разбор с числами

```json
{"level":"ERROR","service":"ads","operation":"update_price","outcome":"db_timeout","duration_ms":450,"trace_id":"example-trace","attempts":2}
```

Это иллюстративная запись, не production dump. `operation` и `outcome` ограничены схемой; trace ID нужен для поиска. Пароли, Authorization, cookies и полный request body не сохраняем. Ошибка логируется на границе, принимающей итоговое решение: три одинаковые ERROR от repository/service/handler не означают три пострадавших запроса.

Учебная оценка: 5 000 requests/s × 1 KiB log/request ≈ 442 GB/сутки. Debug на каждой SQL-строке увеличит объём в несколько раз. Ограничиваем размер/частоту до отправки в backend, иначе сбой logging может занять RAM сервиса. Audit не подменяем sampled application log: там нужна полнота бизнес/security событий.

## Проверь себя

1. Почему error стоит логировать один раз?
2. Можно ли sample audit?

<details>
<summary>Ориентиры для ответа</summary>

1. Чтобы сохранить итоговый контекст и не удвоить счёт инцидента.
2. Только при отдельном контракте полноты; обычный debug sampling его нарушит.

</details>

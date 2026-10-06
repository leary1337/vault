---
title: API design
description: Контракты HTTP/gRPC, evolution, idempotency, pagination и errors.
tags: [architecture, api, http, grpc]
updated: 2026-10-06
---

# API design

Контракт API описывает смысл ответа, ошибки и повторов: одинаковый JSON ещё не означает одинаковое поведение.

API — долгоживущий контракт поведения, а не сериализация внутренних structs. Проектируйте resource/capability, consistency (согласованность наблюдаемых значений и порядка) и failure semantics до выбора JSON или protobuf.

## Контракт

Определите authentication/authorization, validation, idempotency, concurrency, pagination, timeouts, status/error model и compatibility. Documented example без формальной semantics не отвечает, повторять ли request и что означает успех.

Для HTTP используйте методы и status codes по semantics, stable error code отдельно от человекочитаемого message, `ETag`/version для optimistic concurrency и cursor pagination для изменяемых больших наборов. Для gRPC задайте deadlines, canonical status, field presence и evolution protobuf tags.

## Развитие контракта

Additive optional fields обычно совместимы, но новое enum value может сломать exhaustive clients. Не переиспользуйте удалённый protobuf field number/name. Изменение default, ordering, authorization или side effect может быть breaking без изменения schema.

Version вводят при несовместимом contract (договорённость о поведении и гарантиях), а не для каждого release. Поддерживайте deprecation window, usage telemetry (диагностические данные: метрики, логи и traces) и migration guide. Consumer-driven/contract tests проверяют критичные assumptions, но не заменяют спецификацию.

## Надёжность

- mutation получает idempotency key или natural deduplication (устранение повторов по ID) contract;
- server ограничивает body/page/batch, concurrency и rate;
- client deadline (крайний срок завершения) меньше upstream request budget и оставляет время на cleanup;
- retry разрешён только для классифицированной transient (временный, потенциально устранимый повтором) ошибки и retry-safe operation;
- asynchronous acceptance отличает `accepted` от фактически завершённого outcome.

См. [HTTP server](../go/backend/http-server.md), [gRPC](../go/grpc/README.md) и [API fundamentals](../system-design/fundamentals/api-design.md).

## Источники

- [HTTP Semantics, RFC 9110](https://www.rfc-editor.org/rfc/rfc9110)
- [Protocol Buffers programming practices](https://protobuf.dev/programming-guides/dos-donts/)

## Механизм на примере

Пример обновления: GET возвращает `ETag: "ad-42-v7"`; PATCH отправляет `If-Match: "ad-42-v7"`. Сервер выполняет условный UPDATE по версии и владельцу. Если версия изменилась, не перетирает данные и отвечает `412 Precondition Failed`. `409 Conflict` подходит для конфликта бизнес-состояния, например попытки редактирования проданного объявления. Для обязательного, но отсутствующего предусловия можно документировать `428 Precondition Required`.

Для ошибок используем RFC 9457 `application/problem+json`: стабильный `type`, статус и безопасные детали, а не SQL-текст. Cursor содержит `(updated_at,id)` и привязан к фильтру; порядок времени без ID неоднозначен. Добавление поля совместимо только если старые клиенты терпят неизвестные поля; изменение единицы цены с рублей на копейки ломает поведение даже при том же типе integer.

Источники: [HTTP 9110](https://www.rfc-editor.org/rfc/rfc9110.html), [Problem Details 9457](https://www.rfc-editor.org/rfc/rfc9457.html), [428 и 429](https://www.rfc-editor.org/rfc/rfc6585.html).

## Проверь себя

1. Почему stale If-Match возвращает 412?
2. Почему additive field может сломать клиента?

<details>
<summary>Ориентиры для ответа</summary>

1. Не выполнено HTTP-предусловие, это отличается от бизнес-конфликта.
2. Он может отвергать неизвестные поля или новые значения enum.

</details>

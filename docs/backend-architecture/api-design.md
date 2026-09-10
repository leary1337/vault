---
title: API design
description: Контракты HTTP/gRPC, evolution, idempotency, pagination и errors.
tags: [architecture, api, http, grpc]
updated: 2026-09-10
---

# API design

API — долгоживущий контракт поведения, а не сериализация внутренних structs. Проектируйте resource/capability, consistency и failure semantics до выбора JSON или protobuf.

## Контракт

Определите authentication/authorization, validation, idempotency, concurrency, pagination, timeouts, status/error model и compatibility. Documented example без формальной semantics не отвечает, повторять ли request и что означает успех.

Для HTTP используйте методы и status codes по semantics, stable error code отдельно от человекочитаемого message, `ETag`/version для optimistic concurrency и cursor pagination для изменяемых больших наборов. Для gRPC задайте deadlines, canonical status, field presence и evolution protobuf tags.

## Evolution

Additive optional fields обычно совместимы, но новое enum value может сломать exhaustive clients. Не переиспользуйте удалённый protobuf field number/name. Изменение default, ordering, authorization или side effect может быть breaking без изменения schema.

Version вводят при несовместимом contract, а не для каждого release. Поддерживайте deprecation window, usage telemetry и migration guide. Consumer-driven/contract tests проверяют критичные assumptions, но не заменяют спецификацию.

## Reliability

- mutation получает idempotency key или natural deduplication contract;
- server ограничивает body/page/batch, concurrency и rate;
- client deadline меньше upstream request budget и оставляет время на cleanup;
- retry разрешён только для классифицированной transient ошибки и retry-safe operation;
- asynchronous acceptance отличает `accepted` от фактически завершённого outcome.

См. [HTTP server](../go/backend/http-server.md), [gRPC](../go/grpc/README.md) и [API fundamentals](../system-design/fundamentals/api-design.md).

## Источники

- [HTTP Semantics, RFC 9110](https://www.rfc-editor.org/rfc/rfc9110)
- [Protocol Buffers programming practices](https://protobuf.dev/programming-guides/dos-donts/)

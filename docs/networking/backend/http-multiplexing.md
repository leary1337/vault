---
title: HTTP multiplexing и head-of-line blocking
description: Persistent connections, HTTP/1.1, HTTP/2, HTTP/3 и flow-control boundaries.
tags: [networking, http, quic]
updated: 2026-09-10
---

# HTTP multiplexing и head-of-line blocking

HTTP semantics общие для HTTP/1.1, HTTP/2 и HTTP/3; framing и transport различаются. Версия одного hop не обязана совпадать: client→proxy может быть HTTP/3, proxy→service — HTTP/1.1.

## HTTP/1.1

Persistent connection повторно используется, но protocol не имеет встроенного multiplexing. Pipelining сохраняет response order и редко используется; медленный ранний response блокирует последующие на connection. Clients часто открывают несколько connections, увеличивая handshakes и конкуренцию congestion control.

## HTTP/2

Binary frames многих streams interleave-ятся на одной TCP connection. Это уменьшает connection count и application-level HOL между responses, но все bytes всё ещё идут через ordered TCP: потерянный segment задерживает доставку данных всех streams до retransmission. Connection- и stream-level flow control означают, что непрочитанное body или плохая window policy может блокировать progress.

Одна connection также становится shared failure/saturation domain. Pool может поддерживать несколько HTTP/2 connections при high concurrency, server limit или раздельных traffic classes; «HTTP/2 значит всегда одна connection» неверно.

## HTTP/3

HTTP/3 использует QUIC streams поверх UDP. Loss на одном QUIC stream не блокирует delivery других streams на transport layer, хотя congestion control остаётся общим. QPACK имеет собственные blocking considerations для header compression. HTTP/3 не устраняет application queue, dependency lock или oversized response.

## Выбор и измерение

Сравнивайте handshake/resumption, request concurrency, per-stream/connection flow-control stalls, packet loss, connection reuse и fallback. Для internal RPC часто важнее bounded messages, deadlines и backpressure, чем номер HTTP version.

## Источники

- [HTTP Semantics, RFC 9110](https://www.rfc-editor.org/rfc/rfc9110)
- [HTTP/1.1, RFC 9112](https://www.rfc-editor.org/rfc/rfc9112)
- [HTTP/2, RFC 9113](https://www.rfc-editor.org/rfc/rfc9113)
- [HTTP/3, RFC 9114](https://www.rfc-editor.org/rfc/rfc9114)


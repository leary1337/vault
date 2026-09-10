---
title: HTTP/2
description: Binary framing, multiplexed streams, HPACK и flow control поверх TCP.
tags: [networking, http2]
updated: 2026-09-10
---

# HTTP/2

HTTP/2 сохраняет HTTP semantics, но использует binary frames и multiplexed streams на connection. Для HTTPS protocol обычно выбирается через TLS ALPN `h2`; cleartext deployment имеет отдельные discovery/upgrade constraints.

## Frames и streams

Каждый request/response занимает stream; frames разных streams interleave-ятся. Stream имеет state и identifier. Connection-level frames управляют settings, flow control и shutdown; `GOAWAY` сообщает, какие новые streams peer больше не обработает, что важно для safe retry.

HPACK сжимает fields через static/dynamic tables. Limits на header list/table необходимы против memory/CPU abuse. Binary framing не меняет header/body security semantics.

## Flow control

Receiver выдаёт credit на stream и connection. Если application не читает body или не обновляет windows, sender останавливается. Flow control HTTP/2 не заменяет TCP congestion control и application backpressure.

Multiplexing убирает HTTP/1.1 response-order blocking, но TCP выдаёт единый ordered byte stream: потеря segment задерживает bytes всех HTTP/2 streams. Это transport-level head-of-line blocking.

## Production

Проверяйте max concurrent streams, connection count/age, resets, `GOAWAY`, flow-control stalls, ping/idle policy и graceful drain. Одна connection может стать shared blast radius; client pool иногда использует несколько. Не включайте proxy retries для streamed/non-idempotent request без protocol-aware replay safety.

## Источник

- [HTTP/2, RFC 9113](https://www.rfc-editor.org/rfc/rfc9113)

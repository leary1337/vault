---
title: HTTP/3
description: HTTP semantics over QUIC, independent streams, QPACK и deployment trade-offs.
tags: [networking, http3, quic]
updated: 2026-09-10
---

# HTTP/3

HTTP/3 отображает те же HTTP semantics на QUIC. Connection устанавливается поверх UDP с интегрированным TLS 1.3; ALPN token `h3` подтверждает protocol. Endpoint обычно обнаруживается через Alt-Svc или HTTPS DNS records согласно client support.

## Streams

Каждая request/response pair использует bidirectional QUIC stream; control и QPACK используют специальные unidirectional streams. Loss в одном stream не препятствует delivery других уже полученных streams, хотя congestion control connection-а общий.

QPACK заменяет HPACK, потому что QUIC не даёт общего порядка между streams. Dynamic table references могут блокировать decoding до получения instruction; configuration балансирует compression и blocking risk.

## Establishment и migration

QUIC сокращает transport+crypto setup и поддерживает resumption; 0-RTT replayable и требует replay-safe operations. Connection IDs позволяют переживать некоторые path/address changes, но NAT/firewall/UDP policy и load balancer routing остаются failure modes.

## Operations

Поддерживайте graceful fallback на HTTP/2/1.1, измеряйте discovery, negotiated protocol, handshake/fallback, loss/RTT, stream resets и QPACK/flow-control blocking. Сравнивайте end-to-end latency/CPU и packet loss на реальном traffic; HTTP/3 не лечит slow handler/database.

Подробнее о различиях: [HTTP multiplexing](../backend/http-multiplexing.md) и [QUIC](../transport/quic.md).

## Источники

- [HTTP/3, RFC 9114](https://www.rfc-editor.org/rfc/rfc9114)
- [QPACK, RFC 9204](https://www.rfc-editor.org/rfc/rfc9204)

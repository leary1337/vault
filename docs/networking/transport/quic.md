---
title: QUIC
description: Secure multiplexed transport over UDP, streams, loss recovery и migration.
tags: [networking, quic, transport]
updated: 2026-09-10
---

# QUIC

IETF QUIC — secure connection-oriented transport поверх UDP. Он интегрирует TLS 1.3, reliable streams, stream/connection flow control, loss recovery и congestion control. HTTP/3 отображает HTTP semantics на QUIC.

## Streams и loss

Bytes внутри одного stream доставляются упорядоченно; разные streams независимы по delivery. Потеря packet с данными stream A не должна блокировать выдачу уже полученных данных stream B, хотя congestion controller и connection resources общие. Unreliable application messages требуют QUIC DATAGRAM extension, а не обычного stream.

QUIC packets защищены cryptographically, connection IDs позволяют пережить некоторые изменения network path/NAT rebinding. Migration не гарантирует отсутствие interruption и может быть отключена policy.

## Establishment

Initial handshake совмещает transport и TLS 1.3 setup, обычно позволяя 1-RTT establishment. Resumption может сократить стоимость. 0-RTT data уязвимы к replay и разрешаются только для replay-safe application semantics.

## Operations

UDP может блокироваться или ограничиваться middlebox-ами, поэтому clients обычно имеют discovery/fallback. Наблюдайте negotiated version, handshake/fallback, RTT/loss, stream resets, flow-control blocking и connection migration. Не сравнивайте QUIC с TCP только по ping: важны loss, reuse, CPU и request mix.

Connection/stream IDs и encrypted headers усложняют традиционный network inspection; endpoint telemetry становится важнее. Load balancer должен корректно маршрутизировать QUIC connection IDs и поддерживать выбранную retry/token policy.

## Источники

- [QUIC transport, RFC 9000](https://www.rfc-editor.org/rfc/rfc9000)
- [QUIC loss detection and congestion control, RFC 9002](https://www.rfc-editor.org/rfc/rfc9002)
- [QUIC DATAGRAM, RFC 9221](https://www.rfc-editor.org/rfc/rfc9221)

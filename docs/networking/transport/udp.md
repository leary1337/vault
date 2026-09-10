---
title: UDP
description: Datagram transport без delivery/order guarantees и требования к application protocol.
tags: [networking, udp, transport]
updated: 2026-09-10
---

# UDP

UDP передаёт datagrams и сохраняет их границы. Protocol не устанавливает connection и не гарантирует delivery, duplicate suppression, ordering, retransmission, flow control или congestion control.

## Semantics

Один send соответствует одной datagram, но слишком большой payload может быть fragmented на IP layer или отброшен. Receiver buffer overflow тоже теряет datagrams. UDP checksum защищает от части corruption; для IPv4 значение zero historically означает отсутствие checksum, для IPv6 checksum обязателен с оговорёнными исключениями.

Отсутствие handshake уменьшает начальную задержку, но application/derived transport обязан сам решить authentication, reliability, congestion и amplification. «UDP быстрее TCP» без workload/protocol бессодержательно: QUIC поверх UDP реализует большую часть transport machinery в userspace.

## Где применяется

DNS традиционно использует UDP для подходящих запросов и TCP при truncation/размере/операциях; современные encrypted transports добавляют другие варианты. Streaming/real-time protocols могут предпочесть timely data повторной доставке. QUIC использует UDP как substrate, но предоставляет connections, reliable streams и congestion control.

## Backend risks

- spoofed source и reflection/amplification требуют validation/rate limits;
- NAT mappings и firewall idle timeouts создают hidden state;
- размер держите ниже path MTU или используйте protocol-level segmentation;
- retry с одинаковым timeout синхронизирует clients;
- отсутствие response неоднозначно: request или response мог потеряться.

## Источники

- [UDP, RFC 768](https://www.rfc-editor.org/rfc/rfc768)
- [UDP usage guidelines, RFC 8085](https://www.rfc-editor.org/rfc/rfc8085)

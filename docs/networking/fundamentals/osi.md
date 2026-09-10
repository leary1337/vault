---
title: Модель ISO OSI
description: Семь уровней OSI как reference model и диагностический словарь.
tags: [networking, osi, fundamentals]
created: 2024-07-22
updated: 2026-09-10
---

# Модель ISO OSI

OSI Basic Reference Model разделяет communication functions на семь conceptual layers. Это не точное описание каждой современной implementation и не утверждение, что Internet protocols обязаны укладываться один-к-одному; модель полезна как vocabulary и для определения boundary отказа.

| Уровень | Роль | Примеры concepts |
|---|---|---|
| 7 Application | protocol operations приложения | HTTP, DNS, SMTP |
| 6 Presentation | representation/encoding/security transforms | serialization, historical placement encryption |
| 5 Session | dialog/session coordination | checkpoints, session state concepts |
| 4 Transport | process-to-process transport | TCP, UDP, QUIC (пересекает boundaries) |
| 3 Network | addressing и forwarding между networks | IPv4/IPv6, ICMP |
| 2 Data Link | frames и delivery на link | Ethernet, Wi-Fi MAC |
| 1 Physical | передача symbols/bits в medium | copper, fiber, radio PHY |

TLS обычно обсуждают между application и transport, а QUIC объединяет transport и cryptographic handshake, поэтому спор о «точном номере слоя» часто менее полезен, чем вопрос: какой endpoint завершает protocol и кто владеет key/state.

## Диагностика

Layered walk помогает не смешивать причины:

1. link/interface up, errors/drops;
2. IP address/route/MTU;
3. transport handshake/state/ports;
4. TLS/application protocol/status.

При этом наблюдаемый timeout на application layer может быть вызван queueing на любом нижнем или верхнем component. Модель организует проверку, но не доказывает cause.

## Источник

- [ISO/IEC 7498-1: OSI Basic Reference Model](https://www.iso.org/standard/20269.html)

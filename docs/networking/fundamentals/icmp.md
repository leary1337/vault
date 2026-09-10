---
title: ICMP
description: IP error/control messages, ping, traceroute, PMTU и диагностические ограничения.
tags: [networking, icmp]
created: 2024-07-23
updated: 2026-09-10
---

# ICMP

ICMP переносит control/error information для IP. ICMPv4 и ICMPv6 — разные protocols; ICMPv6 также участвует в Neighbor Discovery и essential IPv6 functions.

## Основные сообщения

- Destination Unreachable: route/host/protocol/port или policy/fragmentation condition;
- Time Exceeded: TTL/Hop Limit исчерпан или fragment reassembly timeout;
- Packet Too Big / Fragmentation Needed: Path MTU Discovery;
- Parameter Problem;
- Echo Request/Reply для `ping`.

ICMP error содержит часть offending packet, чтобы sender сопоставил flow. Errors не генерируются для всех ситуаций (например, другое ICMP error/broadcast rules), а middlebox может rate-limit/drop их.

## Диагностика

`ping` подтверждает только обработку Echo по конкретному path/time; отказ ping не доказывает отказ TCP/HTTPS, а успех не доказывает application readiness. `traceroute` изменяет TTL/Hop Limit и наблюдает Time Exceeded; implementations используют UDP, ICMP или TCP probes. Hops могут не отвечать, отвечать с другого interface или балансировать paths.

ICMP round-trip каждого hop не измеряет forwarding latency точно: control-plane responses имеют другую priority. Используйте его вместе с application traces, TCP metrics и packet capture.

Блокирование всех ICMP ломает PMTU/IPv6 и создаёт таймауты больших transfers. Фильтруйте по type/rate/policy, а не blanket deny.

## Источники

- [ICMPv4, RFC 792](https://www.rfc-editor.org/rfc/rfc792)
- [ICMPv6, RFC 4443](https://www.rfc-editor.org/rfc/rfc4443)

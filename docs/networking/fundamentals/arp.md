---
title: ARP
description: IPv4 neighbor resolution, cache states, gratuitous ARP и trust risks.
tags: [networking, arp]
created: 2024-07-23
updated: 2026-09-10
---

# ARP

ARP сопоставляет IPv4 protocol address с link-layer address на local link, обычно IPv4→Ethernet MAC. Для remote destination host разрешает MAC next-hop router-а, а не конечного server-а. IPv6 использует Neighbor Discovery через ICMPv6, не ARP.

## Resolution

Sender определяет, что next hop on-link, и отправляет broadcast ARP Request «кто имеет target IP». Owner отвечает ARP Reply, обычно unicast. Kernel сохраняет neighbor entry и меняет state по reachability/aging policy; конкретные timers implementation-specific.

```text
application destination -> route -> next-hop IPv4 -> neighbor cache -> link address
```

Gratuitous ARP объявляет собственное mapping без обычного запроса: применяется при address conflict detection/update neighbor caches/failover, но доставка и acceptance зависят от network devices/policy.

## Failure и security

Failed resolution выглядит как connect timeout/unreachable ещё до TCP. Проверяйте route/interface/VLAN, neighbor state, packet capture и duplicate IP. Команды: `ip neigh` (Linux), `arp -a` как legacy view.

Classic ARP не аутентифицирует mapping; poisoning может перенаправить traffic. Segment isolation, switch controls и cryptographic upper layers (TLS) уменьшают impact; статические entries плохо масштабируются и тоже требуют lifecycle.

## Источники

- [ARP, RFC 826](https://www.rfc-editor.org/rfc/rfc826)
- [IPv6 Neighbor Discovery, RFC 4861](https://www.rfc-editor.org/rfc/rfc4861)

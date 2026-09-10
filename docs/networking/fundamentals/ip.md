---
title: Internet Protocol
description: Best-effort datagrams, forwarding, TTL/Hop Limit, MTU и fragmentation.
tags: [networking, ip]
created: 2024-07-23
updated: 2026-09-10
---

# Internet Protocol

IP переносит datagrams между network interfaces через routers. Service best-effort: protocol не гарантирует delivery, ordering, duplicate suppression или congestion control. Эти свойства при необходимости добавляет transport/application.

## Forwarding

Host выбирает route по destination prefix (обычно longest-prefix match) и next hop/interface. Каждый router уменьшает IPv4 TTL или IPv6 Hop Limit; при zero packet отбрасывается и обычно формируется ICMP Time Exceeded. TTL — hop bound, не время в секундах для application.

IPv4 header содержит source/destination, protocol, TTL, length, fragmentation и checksum header-а. IPv6 имеет fixed base header + extension headers и не имеет header checksum; next-header chain указывает transport/extensions.

## MTU и fragmentation

IPv4 router может fragment packet, если DF не установлен, но современный transport старается избегать fragmentation. В IPv6 routers не fragment; source использует Fragment header. Path MTU Discovery опирается на ICMP feedback; фильтрация нужного ICMP создаёт black-hole behavior.

Для TCP segmentation/offload complicates packet capture: application write, TCP segment и captured frame не обязаны совпадать. Для UDP application должен ограничить datagram/использовать protocol segmentation.

## Security и identity

Source IP может быть spoofed (особенно connectionless traffic) или адресом proxy/NAT. Не используйте его как authentication. Filtering/routing policies работают только в своей trust boundary; forwarding headers очищает trusted edge.

Продолжение: [IP addressing](ip-addressing.md), [ICMP](icmp.md), [TCP](../transport/tcp.md) и [UDP](../transport/udp.md).

## Источники

- [IPv4, RFC 791](https://www.rfc-editor.org/rfc/rfc791)
- [IPv6, RFC 8200](https://www.rfc-editor.org/rfc/rfc8200)

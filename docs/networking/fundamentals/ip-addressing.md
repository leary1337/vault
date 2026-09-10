---
title: IP-адресация
description: IPv4/IPv6 addresses, prefixes, subnets, scopes и special-purpose ranges.
tags: [networking, ip, addressing]
created: 2024-07-23
updated: 2026-09-10
---

# IP-адресация

IP address идентифицирует network interface/endpoint в routing scope, а prefix определяет network portion. Он не является стабильной identity пользователя или workload: NAT, DHCP, proxies, anycast и migration меняют mapping.

## IPv4 и CIDR

IPv4 address имеет 32 bits. CIDR notation `192.0.2.17/24` означает первые 24 network bits; network prefix — `192.0.2.0/24`. Classful A/B/C addressing историческая и не используется для современного routing/allocation reasoning.

Subnet обычно имеет network и, для common IPv4 prefixes, directed broadcast addresses; usability первого/последнего зависит от prefix/context (`/31` point-to-point — специальный случай). Prefix length важнее dotted mask.

Special scopes включают private RFC 1918 (`10/8`, `172.16/12`, `192.168/16`), loopback `127/8`, link-local `169.254/16`, documentation ranges вроде `192.0.2/24` и unspecified `0.0.0.0`. Значение `0.0.0.0` зависит от API/context; это не обычный адрес «текущего host».

## IPv6

IPv6 address имеет 128 bits и hex notation с `::` compression. Prefix `/64` распространён для LAN/SLAAC, но routing/allocation зависит от environment. `::1` — loopback, `::` — unspecified, `fe80::/10` — link-local, `fc00::/7` — unique local. IPv6 не имеет broadcast; использует multicast.

Scope/interface zone важен для link-local address (`fe80::1%eth0`). Dual-stack client выбирает address family по resolver/OS policy; IPv4 success не доказывает IPv6 path и наоборот.

## NAT и ports

NAT переводит addresses и часто ports, сохраняя state mapping. Он помог IPv4 conservation, но не является security boundary сам по себе. Outbound concurrency ограничивается ephemeral ports и NAT table; connection reuse снижает churn.

## Источники

- [CIDR, RFC 4632](https://www.rfc-editor.org/rfc/rfc4632)
- [IPv4 special-purpose registry](https://www.iana.org/assignments/iana-ipv4-special-registry/)
- [IPv6 addressing architecture, RFC 4291](https://www.rfc-editor.org/rfc/rfc4291)

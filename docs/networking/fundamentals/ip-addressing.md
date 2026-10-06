---
title: IP-адресация
description: IPv4/IPv6 addresses, prefixes, subnets, scopes и special-purpose ranges.
tags: [networking, ip, addressing]
created: 2024-07-23
updated: 2026-10-06
---

# IP-адресация

IP-адрес нужен для доставки в определённой сетевой области. Префикс задаёт группу адресов для маршрутизации; это не ID человека и не доказательство доверия.

## Термины в этой статье

- **scope** — заявленный объём доступа, который всё ещё требует проверки политикой сервера.
- **identity** — подтверждённая личность пользователя или службы.
- **NAT** — преобразование адресов, часто вместе с портами, при прохождении через сетевой узел.
- **CIDR** — запись адреса с длиной сетевого префикса, например /24.

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

## Разбор на примере

Адрес `192.0.2.130/26`: `/26` оставляет 6 бит для адресов, значит блок из 64. Границы последнего октета — 0, 64, 128, 192; наш блок `192.0.2.128–191`, обычный network address `.128`, broadcast `.191`, host range `.129–190`. У `/31` на point-to-point другая семантика, формулу «минус два» нельзя применять всегда.

В таблице есть `0.0.0.0/0`, `10.0.0.0/8` и `10.2.0.0/16`. Для `10.2.3.4` выбирается `/16` — самый длинный совпавший префикс, а не первая строка. Policy routing/VRF добавляют контекст к этому базовому правилу.

Для dual-stack проверьте отдельно A/AAAA и путь IPv6. Private адрес — область использования, не гарантия недоступности атакующему внутри сети. IPv6 link-local требует указания interface zone при неоднозначности.

## Источники

- [CIDR, RFC 4632](https://www.rfc-editor.org/rfc/rfc4632)
- [IPv4 special-purpose registry](https://www.iana.org/assignments/iana-ipv4-special-registry/)
- [IPv6 addressing architecture, RFC 4291](https://www.rfc-editor.org/rfc/rfc4291)

## Проверь себя

1. Какая подсеть у 192.0.2.130/26?
2. Почему IP нельзя использовать как identity пользователя?

<details>
<summary>Ответы</summary>

1. 192.0.2.128/26, обычный broadcast .191; адресов 64.

2. NAT/proxy разделяются между людьми, адреса меняются и могут подделываться в некоторых контекстах.

</details>

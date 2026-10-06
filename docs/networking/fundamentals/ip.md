---
title: Internet Protocol
description: Best-effort datagrams, forwarding, TTL/Hop Limit, MTU и fragmentation.
tags: [networking, ip]
created: 2024-07-23
updated: 2026-10-06
---

# Internet Protocol

IP переносит пакеты между сетями без обещания доставки. Каждый router выбирает следующий участок пути; если нужны подтверждения и повторение, их обеспечивает транспорт или приложение.

## Термины в этой статье

- **congestion control** — ограничение отправки с учётом перегрузки сети.
- **TTL** — срок действия записи; для DNS — допустимое время её хранения в кэше.
- **MTU** — наибольший размер IP-пакета, который проходит через конкретный сетевой интерфейс без фрагментации.
- **identity** — подтверждённая личность пользователя или службы.
- **PMTU** — наименьшее ограничение размера пакета среди звеньев выбранного пути.

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

## Разбор на примере

Путь содержит Ethernet MTU 1500 и VPN-участок с MTU 1400. Маленький health-check проходит, а большой ответ зависает: возможно, пакет превышает PMTU и необходимое ICMP-сообщение блокируется. Исправление — подтвердить механизм capture/MTU/ICMP, а не увеличивать HTTP timeout.

```bash
ip route get 198.51.100.20
ip link show
tracepath 198.51.100.20
```

Это диагностические команды Linux, результаты зависят от пути. TTL/Hop Limit уменьшается на каждом IP-hop и предотвращает бесконечный цикл; число 64 — не «64 секунды». IPv6 router не фрагментирует пакеты за sender, source должен учитывать Path MTU.

IP-пакет, TCP-сегмент и кадр capture могут отличаться из-за tunneling и offload. Очень большой пакет в capture на host не доказывает, что по проводу прошёл кадр такого размера.

## Источники

- [IPv4, RFC 791](https://www.rfc-editor.org/rfc/rfc791)
- [IPv6, RFC 8200](https://www.rfc-editor.org/rfc/rfc8200)

## Проверь себя

1. Почему маленький ping может проходить, а большой HTTPS response зависать?
2. Кто фрагментирует IPv6 packet?

<details>
<summary>Ответы</summary>

1. Он не проверяет тот же размер/PMTU; возможен black hole из-за фильтрации ICMP.

2. Source с Fragment header; промежуточные routers этого не делают.

</details>

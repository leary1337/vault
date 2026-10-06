---
title: ARP
description: IPv4 neighbor resolution, cache states, gratuitous ARP и trust risks.
tags: [networking, arp]
created: 2024-07-23
updated: 2026-10-06
---

# ARP

ARP находит канальный адрес соседа в локальной IPv4-сети. Сначала выбирают маршрут, затем разрешают адрес ближайшего узла; запрос не ищет MAC через весь Интернет.

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

## Разбор на примере

Клиент `192.0.2.10/24` обращается к `198.51.100.20`. Route направляет через `192.0.2.1`: ARP спрашивает именно «кто имеет 192.0.2.1». В Ethernet dst MAC — шлюз, в IP dst — удалённый сервер. На следующем участке router создаёт новую канальную оболочку.

Если `ip neigh` показывает `INCOMPLETE`/`FAILED`, SYN может вообще не уйти дальше локального link. Проверяйте VLAN, interface, адрес шлюза и ответ ARP до поиска TLS-проблем. Не назначайте статический MAC первым исправлением: failover может менять владельца IP.

ARP reply не является криптографическим удостоверением. TLS помогает защитить прикладной канал от чтения/подмены, но не спасает от полного отказа пути при poisoning. Для IPv6 этот разбор заменяется Neighbor Discovery, а не «ARP для 128-битного адреса».

## Источники

- [ARP, RFC 826](https://www.rfc-editor.org/rfc/rfc826)
- [IPv6 Neighbor Discovery, RFC 4861](https://www.rfc-editor.org/rfc/rfc4861)

## Проверь себя

1. Чей MAC ищется при обращении в другую IPv4-подсеть?
2. Почему gratuitous ARP полезен при failover?

<details>
<summary>Ответы</summary>

1. Выбранного next hop, обычно default gateway.

2. Может обновить mapping IP на нового владельца локального link; принятие зависит от политики сети.

</details>

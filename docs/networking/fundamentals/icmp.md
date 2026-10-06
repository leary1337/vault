---
title: ICMP
description: IP error/control messages, ping, traceroute, PMTU и диагностические ограничения.
tags: [networking, icmp]
created: 2024-07-23
updated: 2026-10-06
---

# ICMP

ICMP сообщает о части ошибок IP и помогает диагностировать путь. Успех или отказ ping — только один сигнал; это не проверка работоспособности всего приложения.

## Термины в этой статье

- **MTU** — наибольший размер IP-пакета, который проходит через конкретный сетевой интерфейс без фрагментации.
- **latency** — время ожидания результата конкретной операции.
- **endpoint** — конкретный адрес службы или сторона соединения.
- **PMTU** — наименьшее ограничение размера пакета среди звеньев выбранного пути.
- **handshake** — начальный обмен, в котором стороны устанавливают параметры соединения.

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

## Разбор на примере

`ping` отвечает, но HTTPS даёт `connection refused`: узел доступен для Echo, а нужный TCP listener отсутствует или соединение активно отвергается. И наоборот, firewall может запретить Echo при работающем TCP/443.

Звёздочка у промежуточного hop traceroute не означает потерю транзитного трафика. Router может продолжать forwarding и не отправлять control-plane ответы, ограничивать их скорость или использовать другой обратный путь. Сопоставьте последний endpoint, TCP retransmits и application latency.

Определение максимального размера пакета по пути (PMTU) использует сообщение Fragmentation Needed для IPv4 с DF и Packet Too Big для IPv6. Полный запрет ICMP создаёт особенно неприятный симптом: handshake проходит, передача крупных данных останавливается. Ограничивать нужно типы и скорость по политике, сохраняя необходимые функции.

## Источники

- [ICMPv4, RFC 792](https://www.rfc-editor.org/rfc/rfc792)
- [ICMPv6, RFC 4443](https://www.rfc-editor.org/rfc/rfc4443)

## Проверь себя

1. Доказывает ли отсутствие Echo Reply недоступность TCP/443?
2. Как запрет ICMP может сломать большие transfers?

<details>
<summary>Ответы</summary>

1. Нет: protocol/type policy может различаться.

2. Sender не узнаёт о меньшем PMTU, пакеты теряются без корректного уменьшения размера.

</details>

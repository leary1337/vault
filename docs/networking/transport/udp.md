---
title: UDP
description: Datagram transport без delivery/order guarantees и требования к application protocol.
tags: [networking, udp, transport]
updated: 2026-10-06
---

# UDP

UDP передаёт отдельные сообщения — дейтаграммы. Их границы сохраняются, но сообщения могут потеряться, повториться или прийти в другом порядке. Всё, что требуется сверх этого, добавляет приложение.

## Термины в этой статье

- **flow control** — управление скоростью отправки, чтобы получатель успевал принимать данные.
- **congestion control** — ограничение отправки с учётом перегрузки сети.
- **payload** — полезные данные сообщения, без служебных заголовков.
- **handshake** — начальный обмен, в котором стороны устанавливают параметры соединения.
- **NAT** — преобразование адресов, часто вместе с портами, при прохождении через сетевой узел.
- **MTU** — наибольший размер IP-пакета, который проходит через конкретный сетевой интерфейс без фрагментации.
- **PMTU** — наименьшее ограничение размера пакета среди звеньев выбранного пути.

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

## Разбор на примере

Клиент послал запрос с ID `42`, сервер выполнил действие, ответ потерялся. Клиент снова посылает ID `42`. Если это изменение состояния, серверу нужно помнить результат или иметь естественно идемпотентную операцию. Для чтения можно повторить запрос с ограничением попыток, задержкой и общим deadline.

При MTU 1500 байт обычные заголовки IPv4 без options и UDP занимают 20 + 8 байт: остаётся 1472 байта payload для этого пути. Это не универсальный безопасный размер: туннель, IPv6 и более узкий участок меняют бюджет. Потеря одного IP-фрагмента теряет всю дейтаграмму. Поэтому большие сообщения лучше разбивать на уровне протокола с учётом PMTU.

Сокетный `connect` для UDP может закрепить адрес peer и упростить API, но не выполняет сетевой handshake. Успешный `send` означает принятие локальным стеком, не получение peer.

## Источники

- [UDP, RFC 768](https://www.rfc-editor.org/rfc/rfc768)
- [UDP usage guidelines, RFC 8085](https://www.rfc-editor.org/rfc/rfc8085)

## Проверь себя

1. Что означает успешный UDP send?
2. Почему отсутствие handshake не делает UDP всегда быстрее TCP?

<details>
<summary>Ответы</summary>

1. Локальный стек принял сообщение; подтверждения доставки от UDP нет.

2. Нужные надёжность, безопасность и управление перегрузкой приходится реализовывать выше; результат зависит от нагрузки.

</details>

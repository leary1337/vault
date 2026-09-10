---
title: TCP
description: Надёжный ordered byte stream, flow/congestion control и connection lifecycle.
tags: [networking, tcp, transport]
updated: 2026-09-10
---

# TCP

TCP предоставляет приложению full-duplex ordered byte stream между endpoints. Он не сохраняет границы application messages: один `Write` может читаться частями или вместе с другими writes. Framing обязан задать протокол выше.

## Установление и передача

Three-way handshake SYN → SYN-ACK → ACK синхронизирует initial sequence numbers и согласует options. Данные нумеруются по bytes; checksum обнаруживает corruption, ACK и retransmission восстанавливают потерю, receiver window реализует flow control, congestion control ограничивает нагрузку на сеть.

«Reliable» не означает бесконечную гарантию доставки. При partition, crash или timeout sender может не знать, применил ли peer уже отправленные bytes. Application protocol нуждается в deadline, idempotency и подтверждении нужного business outcome.

TCP сохраняет порядок, поэтому потерянный segment задерживает выдачу последующих bytes этому connection — transport head-of-line blocking. Несколько application streams HTTP/2 не устраняют это свойство TCP.

## Закрытие

Каждое направление закрывается FIN независимо; RST прерывает connection и может означать потерю buffered data. `CLOSE-WAIT` ждёт local application close; `TIME-WAIT` обычно принадлежит active closer и защищает новую incarnation от delayed segments/повторяет final ACK.

Половина close означает, что одна сторона больше не пишет, но может читать. Ошибка `EOF` сообщает завершение stream, а не business success. Подробнее: [connection lifecycle](../backend/connection-lifecycle.md).

## Production

Используйте persistent connections/pools, но задавайте connect, request/operation и idle deadlines отдельно. Наблюдайте RTT/retransmits/resets, backlog, states, ephemeral ports и cgroup/network saturation. TCP keepalive обнаруживает некоторые idle dead peers, но не заменяет application deadline.

## Источники

- [TCP, RFC 9293](https://www.rfc-editor.org/rfc/rfc9293)
- [TCP congestion control, RFC 5681](https://www.rfc-editor.org/rfc/rfc5681)

---
title: Основы компьютерных сетей
description: Packet switching, bandwidth, latency, queues, loss и layered protocols.
tags: [networking, fundamentals]
created: 2024-07-22
updated: 2026-09-10
---

# Основы компьютерных сетей

Сеть переносит данные через links и intermediate devices между endpoints. Packet switching разделяет поток на units и статистически делит capacity; в отличие от заранее выделенного circuit, нагрузка конкурирует за queues/links.

## Основные величины

- bandwidth/capacity — возможная скорость link-а;
- throughput/goodput — реально переданные bytes, для goodput без overhead/retransmits;
- latency — propagation + transmission + queueing + processing;
- jitter — изменение latency;
- loss/reordering/duplication — возможные свойства datagram path;
- MTU — максимальный размер packet/frame для конкретного hop/technology.

Высокая utilization может вызвать нелинейный рост queueing latency. Большой bandwidth не устраняет propagation RTT. Speed test с одного host/path не описывает весь production path.

## Flow и congestion

Flow control защищает receiver от sender-а. Congestion control адаптирует отправку к path capacity. Backpressure application-а должна продолжать эту цепочку: если handler читает бесконечно и складывает в unbounded queue, transport control не защищает memory.

QoS/classification может отдавать приоритет traffic classes, но не создаёт capacity и требует end-to-end operational policy. Real-time traffic часто предпочитает своевременность retransmission; durable transfer — полноту и integrity.

## Layers

Layers разделяют contracts: link доставляет frame на local segment, IP маршрутизирует datagrams между networks, transport создаёт process-to-process semantics, application задаёт messages/operations. Encapsulation полезна для reasoning, но implementations/proxies/offloads пересекают уровни.

Начните с [OSI](osi.md) как vocabulary и [TCP/IP model](tcp-ip-model.md) как Internet stack, затем [IP](ip.md), [sockets](sockets.md) и transports.

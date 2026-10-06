---
title: Основы компьютерных сетей
description: Packet switching, bandwidth, latency, queues, loss и layered protocols.
tags: [networking, fundamentals]
created: 2024-07-22
updated: 2026-10-06
---

# Основы компьютерных сетей

Для приложения сеть — ограниченный путь передачи с задержкой, потерями и очередями. Ёмкость канала отвечает «сколько байтов за секунду», задержка — «сколько ждать конкретный результат».

## Термины в этой статье

- **latency** — время ожидания результата конкретной операции.
- **MTU** — наибольший размер IP-пакета, который проходит через конкретный сетевой интерфейс без фрагментации.
- **RTT** — время прохождения запроса и ответа по сети.
- **flow control** — управление скоростью отправки, чтобы получатель успевал принимать данные.
- **congestion control** — ограничение отправки с учётом перегрузки сети.

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

Связанные темы: [OSI](osi.md), [TCP/IP model](tcp-ip-model.md), [IP](ip.md), [sockets](sockets.md) и transport protocols.

## Разбор на примере

Передача 10 MiB по идеальному 100 Mbit/s каналу требует примерно `10 × 2^20 × 8 / 10^8 = 0.84 s` только сериализации, без RTT и накладных расходов. Запрос на 1 KiB при RTT 100 мс может ждать сеть гораздо дольше, чем передачу самих байтов.

Для использования канала 1 Gbit/s с RTT 100 мс нужно держать примерно `1e9 × 0.1 / 8 = 12.5 MB` данных в полёте: bandwidth-delay product. Это не рекомендация вслепую увеличить буферы до этого размера; ограничения памяти, окна и числа соединений надо измерять.

Когда входящий поток работы приближается к скорости обработки, очередь и p99 растут. Большая очередь не добавляет производительности, а удерживает запросы, которые могут уже не успеть к deadline. Ограничение concurrent requests, backpressure и отказ части нагрузки защищают полезную работу.

## Проверь себя

1. Сколько времени занимает передача 10 MiB по 100 Mbit/s без overhead?
2. Почему большой buffer может ухудшить p99?

<details>
<summary>Ответы</summary>

1. Около 0.84 секунды; различайте биты и байты, MiB и MB.

2. Работа дольше стоит в очереди; ёмкость буфера не увеличивает скорость обработки.

</details>

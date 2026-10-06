---
title: Bulkhead
description: Изоляция ресурсов между workloads и dependencies.
tags: [backend, patterns, reliability]
updated: 2026-10-06
---

# Bulkhead


Bulkhead — отдельные запасы ресурсов для разных видов работы, как водонепроницаемые отсеки корабля.

## Проблема

Один медленный dependency, tenant или request class занимает все workers/connections и делает недоступными независимые функции.

## Как работает

Разделите bounded (с явным конечным пределом) resource pools и queues: отдельные HTTP/DB connection pools, semaphores, worker pools или quotas для critical/background traffic. Резервируйте capacity для health/admin/recovery paths.

## Гарантии и границы

При корректных границах exhaustion одного compartment не забирает выделенные ресурсы другого. Pattern не гарантирует успех повреждённого compartment и не устраняет общие bottlenecks CPU/memory/network.

## Ошибки и отказы

- слишком крупный pool всё равно истощает общий resource;
- слишком мелкий простаивает и режет throughput (скорость успешной обработки);
- request держит ресурс одного pool, ожидая другой — cross-pool deadlock;
- high-priority traffic starves background навсегда;
- число application instances умножает database pool limit.

## Компромиссы

Изоляция снижает эффективность общего pooling и усложняет capacity planning. Нужны отдельные metrics saturation/queue/rejections по compartment и контролируемое перераспределение spare capacity.

## Когда не применять

Если workloads действительно имеют общий fate/resource и одинаковый priority, один простой bounded pool лучше множества искусственных partitions.

## Пример

API получает 80 DB slots, batch jobs — 15, admin/recovery — 5. Каждый limit согласован с total connections всех replicas; при saturation (насыщение ресурса и образование очереди) batch получает backpressure, а не занимает API slots.

## Разобранный пример

Пусть БД допускает 500 соединений, 100 оставляем администрированию/миграциям, приложение имеет 20 реплик. Общий предел на реплику — не больше 20 соединений в этой оценке. Выдать каждой реплике «80 API + 15 batch + 5 admin» означало бы 2 000 соединений. Проверяем общий бюджет, а затем делим его внутри реплики. Эти числа — пример, предел определяется реальной БД.

Изоляция включает семафор, ограниченную очередь и deadline (крайний срок завершения), а не только разные HTTP-клиенты. Если запрос держит соединение БД, ожидая внешний сервис, два независимых пула всё ещё блокируют друг друга. Освобождаем ресурсы до перехода к долгому внешнему шагу, если бизнес-протокол это допускает.

## Источник механизма

[Google SRE: изоляция и защита от каскадных отказов](https://sre.google/sre-book/addressing-cascading-failures/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему отдельные пулы не гарантируют полную изоляцию?
2. Как проверить размер DB pool?

<details>
<summary>Ориентиры для ответа</summary>

1. Остаются общие CPU, память, сеть и сама БД.
2. Умножить лимиты всех процессов и классов работы, включая фоновые задачи.

</details>

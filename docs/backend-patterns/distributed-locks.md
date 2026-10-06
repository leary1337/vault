---
title: Distributed locks
description: Leases, ownership tokens и fencing для внешних side effects.
tags: [backend, patterns, distributed-systems]
updated: 2026-10-06
---

# Distributed locks


Распределённая блокировка согласует несколько процессов; lease (временное право владения) — право владения на ограниченное время, fencing (отклонение действий старого владельца самим ресурсом) — отклонение устаревшего владельца самим защищаемым ресурсом.

## Проблема

Несколько processes должны координировать редкую critical section или singleton ownership (владение данными или ответственность за ресурс), а local mutex не охватывает replicas.

## Как работает

Linearizable coordination service выдаёт lease/lock с unique ownership и monotonic fencing token. Holder прикладывает token к downstream mutation; downstream отклоняет token ниже уже принятого. TTL (время жизни записи) ограничивает liveness (способность продолжать продвижение; у probe — жив ли процесс) при crash, но не заменяет fencing.

## Гарантии и границы

Guarantee зависит от backend protocol, quorum (достаточный набор участников для решения), clock assumptions и downstream validation. Lock без fencing может допустить concurrent side effects после pause/partition, даже если key уже принадлежит новому holder.

## Ошибки и отказы

- process pause дольше lease и продолжает работу;
- asynchronous replica (копия данных на другом узле) failover теряет lock;
- release удаляет lock нового owner;
- renewal loop жив, а protected work зависла;
- lock order создаёт deadlock;
- coordinator unavailable блокирует progress.

## Компромиссы

Strong coordinator добавляет latency (срок ответа) и availability (доступность заявленной операции) dependency. Lease ускоряет recovery, но создаёт uncertainty window. Часто optimistic concurrency, database unique constraint или idempotency проще и сильнее соответствует invariant (правило, которое система обязана сохранять).

## Когда не применять

Не используйте lock для маскировки non-idempotent (без второго эффекта при повторе одного намерения) handler, долгого workflow или correctness-critical external action без fencing. Для cache stampede (множество одинаковых одновременных загрузок) best-effort singleflight/lease имеет более мягкие требования.

## Пример

Worker получает `(resource, lease_expiry, fencing_token=57)`. Storage сохраняет max token; поздняя запись holder 56 отвергается. Release compare-ит ownership token. Redis-specific ограничения и Redlock trade-offs: [Redis distributed locks](../databases/redis/distributed-locks.md).

## Разобранный пример

A получил token=56 и остановился на 40 s; lease истёк через 30 s. B получил 57 и изменил файл. A проснулся и пишет старый результат. Проверка TTL только перед началом работы не защищает запись после паузы.

Хранилище атомарно сравнивает token с максимальным принятым и отклоняет token ниже него. Равный token может быть допустим для нескольких действий одного владельца, поэтому fencing не заменяет отдельный ID операции. Token должен происходить из надёжно возрастающей власти; случайная строка ownership годится для безопасного release, но не для сравнения поколений.

Если ресурс не умеет проверять token, у lock нет заявленной защиты внешнего эффекта. Для изменения строки зачастую проще `UPDATE ... WHERE version=$expected`, а для уникальной выдачи — constraint.

## Источник механизма

[etcd 3.6: API guarantees](https://etcd.io/docs/v3.6/learning/api_guarantees/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему TTL не обеспечивает исключение двух писателей?
2. Чем owner ID отличается от fencing token?

<details>
<summary>Ориентиры для ответа</summary>

1. Старый процесс может продолжить после истечения lease.
2. Первый идентифицирует владельца, второй упорядочивает поколения и проверяется ресурсом.

</details>

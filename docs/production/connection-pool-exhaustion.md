---
title: Connection pool exhaustion
description: Диагностика pool wait, leaked connections, slow operations и capacity mismatch.
tags: [production, connections, database]
updated: 2026-10-06
---

# Connection pool exhaustion

Исчерпание пула — все соединения заняты, новые операции ждут свободного места.

## Симптомы

Pool waiters/wait duration и acquisition timeouts растут, хотя database может не быть на пределе. Active connections равны max; latency (срок ответа) распространяется на unrelated requests.

## Возможные причины

Slow/blocked queries, long transactions, leaked/unclosed rows or response bodies, concurrency burst, слишком маленький pool, слишком большой fleet-wide pool для server capacity, connection churn или dependency outage.

## Что измерить

Open/in-use/idle/max, wait count/duration, hold time, query/transaction latency, database sessions/waits/max, request concurrency, timeouts и connections across all replicas/jobs.

## Проверка гипотез

Разделите acquisition wait и operation time. Если hold time вырос — ищите slow/blocked work и ownership (владение данными или ответственность за ресурс) release path. Если concurrency вырос при прежнем hold time — оцените Little's Law/capacity. Сверьте process pool max × replicas с database/proxy limit и reserved admin headroom (запас ресурса сверх обычной нагрузки).

## Инструменты

Driver pool statistics, traces со span (измеряемый этап trace) (измеряемый этап trace (связь этапов одной операции)) на acquire и query, goroutine stacks, `pg_stat_activity`/locks, proxy metrics и connection establishment errors.

## Как уменьшить ущерб

Остановить leak/blocker, rollback (отмена локальной транзакции или возврат старой версии), ограничить request/job concurrency, shed load, сократить timeout/transaction scope. Увеличивать pool только если database имеет headroom; иначе очередь просто переместится и overload усилится.

## Механизм причины

Определите, почему connection удерживался дольше или demand превысил рассчитанную concurrency: missing close, remote call внутри transaction, lock, traffic burst или fleet scaling mismatch.

## Предотвращение

Всегда close rows/body, transaction deadlines, pool wait/hold metrics, bounded (с явным конечным пределом) concurrency, fleet-wide connection budget, leak tests и reserved operational connections. См. [connection pooling](../databases/postgresql/connection-pooling.md).

## Разбор с числами

Учебные данные: max=20, in_use=20, wait_count растёт на 200/s; DB CPU=25%, query p99 (время, в которое укладывается 99% наблюдений)=30 ms, acquisition p99=800 ms. Гипотеза «БД вычисляет слишком медленно» не подтверждается; вероятнее connection удерживается вне SQL или запросы ждут lock. В `pg_stat_activity` видны старые `idle in transaction`, а trace — внешний call между BEGIN/COMMIT.

В `database/sql` `WaitDuration` и `WaitCount` накопительные: берём разницу за интервал, не называем абсолютный counter текущим ожиданием. Проверяем `rows.Close`, чтение `rows.Err`, rollback на всех ветках, зависшие транзакции. Добавление max 20→100 при 50 репликах означает 5 000 потенциальных соединений вместо 1 000, поэтому сначала проверяем общий бюджет.

Гипотеза меняется, если query duration тоже выросла и DB I/O saturated: тогда pool wait — следствие DB bottleneck. Mitigation: отключить медленный фоновой job/rollback версии, ограничить concurrency; после действия проверяем wait и user p99.

## Источник механизма

[Go database/sql DBStats](https://pkg.go.dev/database/sql#DBStats). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему низкая DB CPU не исключает проблему?
2. Что означает WaitCount?

<details>
<summary>Ориентиры для ответа</summary>

1. Можно ждать locks/I/O либо удерживать idle transaction.
2. Накопленное число ожиданий, его rate показывает текущую динамику.

</details>

---
title: EXPLAIN
description: Как читать estimates, actual rows, buffers и loops.
tags: [databases, postgresql, performance]
updated: 2026-09-10
---

# EXPLAIN

`EXPLAIN` показывает план без выполнения. `EXPLAIN ANALYZE` выполняет statement и добавляет фактические метрики; для изменяющего запроса используйте явную transaction с `ROLLBACK`, помня, что triggers и внешние side effects могут всё равно сработать.

```sql
BEGIN;
EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, FORMAT TEXT)
UPDATE jobs SET attempts = attempts + 1 WHERE id = 42;
ROLLBACK;
```

## Как читать

Начинайте с фактического потока данных снизу вверх:

- `cost=startup..total` и `rows` — estimates planner;
- `actual time`, `rows`, `loops` — наблюдение одного запуска;
- общее число строк узла приблизительно `rows × loops`;
- `Buffers: shared hit/read/dirtied/written` отделяет cache hits от reads и writes;
- `Rows Removed by Filter` показывает позднюю фильтрацию;
- sort method, memory и disk usage выявляют spills;
- `WAL` помогает оценить write amplification.

Главный сигнал — не «использован ли индекс», а где фактический объём/время возникли и почему estimates неверны. Sequential scan малой таблицы или большой доли данных часто оптимален.

## Частые scan nodes

- `Seq Scan` читает table pages последовательно.
- `Index Scan` находит TIDs в индексе и читает heap.
- `Index Only Scan` может вернуть payload из индекса, но зависит от visibility map.
- `Bitmap Index Scan` + `Bitmap Heap Scan` группирует heap accesses и удобен для средней selectivity или объединения indexes.

## Осторожность измерения

`ANALYZE` добавляет instrumentation overhead; первый и повторный запуск имеют разный cache state. Клиентская передача результата обычно не включена в executor time. Сравнивайте одинаковые данные/параметры, несколько запусков и latency приложения.

В production сначала используйте `EXPLAIN` без `ANALYZE` для опасного statement или снимок из `pg_stat_statements`. Никогда не запускайте тяжёлый `EXPLAIN ANALYZE` вслепую.

## Источники

- [Using EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html)
- [EXPLAIN command](https://www.postgresql.org/docs/18/sql-explain.html)

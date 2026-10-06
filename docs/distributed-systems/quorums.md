---
title: Quorums
description: Majority, read/write intersection и ограничения формулы N/R/W.
tags: [distributed-systems, consensus]
updated: 2026-10-06
---

# Quorums

Кворум — набор участников, достаточный для решения; пересечение наборов переносит информацию между решениями.

Quorum (достаточный набор участников для решения) — достаточное подмножество участников для решения или операции. Majority (большинство участников) quorum пересекается с любым другим majority, поэтому два disjoint большинства не могут одновременно выбрать разных leaders в одной configuration.

Для N replicas leaderless storage часто приводят условия:

```text
W + R > N
W > N / 2
```

Первое даёт пересечение read/write sets, второе — write/write sets. Но это не готовое доказательство strong consistency (согласованность наблюдаемых значений и порядка).

## Почему формулы недостаточно

- sloppy quorum может писать на временные nodes вне home replica (копия данных на другом узле) set;
- concurrent writes требуют version/conflict resolution;
- read может получить stale responses и выбрать неправильную version;
- clock-based last-write-wins чувствителен к skew;
- membership/reconfiguration меняет множества;
- acknowledgement до durable storage ослабляет crash guarantees;
- repair/garbage collection может удалить нужную version.

Linearizable register требует protocol, который корректно определяет последнюю committed version и обрабатывает concurrency, а не только считает ответы.

## Кворум consensus

В Raft/Paxos quorum участвует в выборе leader (узел, координирующий запись) и commit (фиксация результата, который считается подтверждённым) replicated log. Узел с устаревшим log не должен победить только потому, что собрал голоса; election rules учитывают log freshness. Joint consensus/совместимая reconfiguration обеспечивает пересечение старой и новой configurations.

## Практические следствия

Quorum из 3 переносит один отказ, из 5 — два, если failures независимы. Добавление even voter обычно не повышает tolerated failures: 4 всё ещё требует 3 и переносит один. География voters (голосующие участники) задаёт minimum write/election latency (срок ответа) и поведение при потере region.

Не путайте quorum настройки разных слоёв: Kafka controller quorum, topic ISR/`min.insync.replicas` и application acknowledgement решают разные задачи.

## Источники

- [Raft paper](https://raft.github.io/raft.pdf)
- [Amazon Dynamo paper](https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf)

## Механизм на примере

Для N=3, W=2, R=2 наборы записи `{A,B}` и чтения `{B,C}` пересекаются в B. Но reader может выбрать старый ответ C, а конкурентные writers — разные версии. Нужен протокол выбора/подтверждения версии, не только арифметика.

Для majority `floor(N/2)+1`: N=3 требует 2, N=4 требует 3, N=5 требует 3. Четвёртый voter не увеличивает число переносимых отказов. Три voters в одной зоне выдержат одиночный процесс, но не потерю зоны. Два voters в зоне A и один в B: потеря A лишает quorum, потеря B нет.

Reconfiguration не делается мгновенным заменением списка: старый и новый quorum могут не пересечься. Raft joint configuration требует большинства обеих конфигураций в переходный период.

## Проверь себя

1. Почему R+W>N недостаточно для linearizability?
2. Почему четыре voters не лучше трёх по tolerated failures?

<details>
<summary>Ориентиры для ответа</summary>

1. Пересечение должно сопровождаться правильным протоколом версий/commit.
2. Большинство 3 из 4 всё ещё допускает только один отказ.

</details>

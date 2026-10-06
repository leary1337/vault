---
title: Replication в System Design
description: Read scale, failover и durability decisions.
tags: [system-design, replication]
updated: 2026-10-06
---

# Replication в System Design

Реплики дают копии и возможность восстановления; их свежесть и право стать лидером задаются протоколом.

Replication проектируют от failure domains и consistency (согласованность наблюдаемых значений и порядка), а не от числа копий.

## Решения

- leader (узел, координирующий запись), multi-leader или leaderless write path;
- synchronous acknowledgement или asynchronous lag;
- read routing и session guarantees;
- promotion authority, freshness и fencing (отклонение действий старого владельца самим ресурсом);
- repair, backup и reconciliation (сверка и устранение расхождений);
- placement across rack/zone/region.

Synchronous cross-zone replica (копия данных на другом узле) улучшает durability (сохранность подтверждённых данных при заявленных отказах), но добавляет latency (срок ответа) и может остановить writes при потере quorum (достаточный набор участников для решения). Asynchronous replica сохраняет availability/latency, но допускает потерю acknowledged tail и stale reads.

Read scaling работает только если workload допускает lag и replicas имеют capacity на replay (повторное проигрывание сохранённых событий) плюс queries. Долгий analytical query может конфликтовать с cleanup/replay конкретной database.

## Failure review

Проиграйте leader crash до/после acknowledgement, network partition (раздел журнала или данных; при network partition — разрыв связи) со старым leader, promotion lagging replica, loss whole zone и failed rejoin. Зафиксируйте RPO/RTO и кто принимает риск unclean failover.

Наблюдайте applied position/lag, not просто «replica connected». Регулярно тестируйте promotion, client rerouting, fencing и restore. Глубже: [replication models](../../distributed-systems/replication.md).

## На конкретном примере

Ответ после local commit (фиксация результата, который считается подтверждённым) и до отправки replica может потеряться вместе с primary. Для нулевого RPO (допустимая потеря подтверждённых данных) в выбранной модели нужно подтверждение достаточных durable копий и promotion, сохраняющий committed историю.

Replica получила WAL, но не применила: read ещё старый. Поэтому read-your-writes ждёт replay/applied position, не только receive. Для capacity считаем queries и replay вместе: тяжёлая аналитика способна увеличить lag. Backup нужен отдельно, поскольку DROP/delete/corruption тоже могут скопироваться.

## Источник механизма

[PostgreSQL 18: replication](https://www.postgresql.org/docs/18/warm-standby.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Достаточно ли replica connected для свежести?
2. Почему synchronous replication может уменьшить availability (доступность заявленной операции)?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, нужны applied position и lag.
2. Недоступность необходимых подтверждающих узлов останавливает записи.

</details>

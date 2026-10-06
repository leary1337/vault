---
title: Kafka consumer lag
description: Диагностика backlog age, consumer throughput, rebalances и hot partitions.
tags: [production, kafka, messaging]
updated: 2026-10-06
---

# Kafka consumer lag

Lag — отставание позиции consumer (потребитель работы или контракта); пользовательскую задержку лучше также измерять возрастом необработанного события.

## Симптомы

Offset lag и, важнее, возраст oldest unprocessed event растут; freshness SLO (цель качества сервиса за заданное окно) нарушается. Lag count может расти при нормальном processing time из-за traffic burst.

## Возможные причины

Arrival rate выше processing capacity, slow dependency, poison message/retry loop, rebalance churn, crashed/stalled members, too few partitions, hot partition/key, large records/batches, broker/network throttling или incorrect offset observation.

## Что измерить

Produce/consume rate, lag по partition (раздел журнала или данных; при network partition — разрыв связи), oldest event age, process latency/outcome, poll/commit/rebalance metrics, consumer membership, dependency saturation (насыщение ресурса и образование очереди) и broker request/throttle/under-replication signals.

## Проверка гипотез

Проверьте, растёт ли lag на всех или одной partition. Сравните arrival и successful completion rate, затем consumer health/rebalances и process spans. Найдите самый старый record metadata без вывода sensitive payload (полезное содержимое запроса или события). Отделите receive/poll от фактического business completion и commit (фиксация результата, который считается подтверждённым).

## Инструменты

Kafka consumer-group tooling/APIs, client metrics/logs, broker metrics, traces с messaging semantics, dependency dashboards и DLQ/retry-topic inspection.

## Как уменьшить ущерб

Устранить poison retry, pause необязательных producers/jobs, увеличить consumers до числа полезных partitions, ускорить/отключить bottleneck, применить controlled load shed или replay/DLQ policy. Не увеличивайте partitions поспешно: ordering/key distribution и later scale меняются.

## Механизм причины

Докажите, почему service rate стал ниже arrival rate или конкретная partition остановилась, включая trigger и missing bound. «Большой lag» — symptom; root cause находится в producer, consumer, dependency или broker path.

## Предотвращение

Alert на oldest age и growth, capacity headroom (запас ресурса сверх обычной нагрузки), bounded (с явным конечным пределом) retries/DLQ, idempotent (без второго эффекта при повторе одного намерения) processing, rebalance-safe shutdown, partition/key review и load/replay exercises. См. [Kafka consumers](../messaging/kafka/consumer.md).

## Разбор с числами

Учебный поток: вход 10 000/s, успешно обработано 8 000/s, lag растёт 2 000/s. Через 10 min прибавится 1,2 млн событий. После scale обработка 12 000/s при том же входе догонит за 10 min. Если 90% traffic у одной partition, дополнительные consumers других partitions не исправят её throughput (скорость успешной обработки).

Иллюстративная таблица: partitions 0..7 имеют lag≈100, partition 8 lag=900 000 и самый старый record 20 min. Проверяем key skew или poison record, а не общую CPU. Если все partitions отстают и DB pool wait вырос, увеличение consumers может усилить bottleneck.

Committed offset отражает подтверждённый префикс по контракту приложения; consumer position после poll не означает business completion. При параллельной обработке не подтверждаем 102, пока 101 ещё не сохранён. DLQ (очередь ошибочных событий с процедурой разбора) требует stable ID, причины, владельца и replay (повторное проигрывание сохранённых событий); перестановка сообщений может нарушить aggregate order.

## Источник механизма

[Kafka 4.3 design](https://kafka.apache.org/43/design/design/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему больше consumers не всегда помогает?
2. Как оценить catch-up time?

<details>
<summary>Ориентиры для ответа</summary>

1. Предел partitions, hot key (ключ с непропорционально высокой нагрузкой) или внешняя зависимость остаются.
2. Backlog (накопившаяся необработанная работа) разделить на service rate минус текущий arrival rate.

</details>

---
title: Failure handling
description: Failure matrix, timeouts, degraded modes и recovery.
tags: [system-design, reliability]
updated: 2026-10-06
---

# Failure handling

Отказ описывается через видимый результат, сохранённые данные и способ восстановления.

Design считается неполным, пока не описано поведение при частичном отказе. «Retry и fallback» без boundaries создаёт каскад.

## Матрица отказов

Для каждого critical dependency/zone/control plane рассмотрите:

| Failure | Detect | Immediate behavior | Data risk | Recovery |
| --- | --- | --- | --- | --- |
| timeout/slow | deadline (крайний срок завершения), latency (срок ответа) | retry/fail/shed | unknown outcome | status/idempotency |
| process/node loss | health + quorum (достаточный набор участников для решения) | reroute/failover | in-flight/ack tail | restart/replay |
| network partition (раздел журнала или данных; при network partition — разрыв связи) | quorum/lag | reject или stale mode | divergence | fence/repair |
| overload | queue/saturation | backpressure/shed | dropped/expired work | drain/scale |
| corruption/operator error | checks/audit | stop writes/isolate | incorrect replicated data | restore/reconcile |

Timeout ограничивает ожидание, cancellation best-effort. Retry только при idempotency и budget. Circuit breaker, bulkhead и load shedding защищают capacity, но должны иметь понятный user outcome.

## Восстановление

Определите RPO/RTO, source of truth (основной достоверный источник данных), backup/restore, replay (повторное проигрывание сохранённых событий) order, fencing (отклонение действий старого владельца самим ресурсом) и reconciliation (сверка и устранение расхождений) query. Failover без failback/rejoin procedure накапливает риск. Runbook содержит безопасные команды, preconditions и rollback (отмена локальной транзакции или возврат старой версии).

Chaos test начинается с hypotheses и observability: kill, pause, one-way partition, disk full, stale DNS, expired cert и dependency latency. Не тестируйте разрушительно без isolation. Подробнее: [failure models](../../distributed-systems/failure-models.md).

## На конкретном примере

Пример create: DB commit (фиксация результата, который считается подтверждённым) успешен, ответ потерян. Клиент повторяет stable key, получает прежний объект. Пример cache outage: ограниченный fallback защищает БД, часть запросов получает 503. Пример index outage: запись сохраняется, поиск отстаёт, Outbox (события, сохранённые вместе с бизнес-изменением) растёт и имеет alert по возрасту/диску.

Для каждого сценария проверяем три момента: до durable point, после него до ответа, после ответа. Recovery включает возвращение старого узла в кластер и предотвращение его устаревших writes. «Переключили DNS» без fencing не завершает failover.

## Источник механизма

[Google SRE: каскадные отказы](https://sre.google/sre-book/addressing-cascading-failures/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Что проверять после failover?
2. Что значит unknown outcome?

<details>
<summary>Ориентиры для ответа</summary>

1. Свежесть нового узла, остановку старых writes, маршрутизацию и восстановление реплик.
2. Клиент не получил ответ, но эффект мог быть сохранён.

</details>

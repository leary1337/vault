---
title: Production debugging
description: Системный порядок диагностики incidents по metrics, traces, logs и profiles.
tags: [observability, debugging, incident-response]
updated: 2026-10-06
---

# Production debugging

Диагностика — последовательное исключение гипотез по свидетельствам, затем проверка влияния исправления на пользователя.

Диагностика начинается с user impact и времени начала, а не с любимого инструмента. Цель первой фазы — ограничить ущерб и сузить пространство гипотез, сохраняя evidence.

## Порядок диагностики

1. Подтвердить incident: какой journey, доля пользователей, регионы и типы операций затронуты.
2. Зафиксировать timeline, текущее время, SLO (цель качества сервиса за заданное окно) burn, owners и канал координации.
3. Проверить последние deploy/config/feature/data/schema/infrastructure changes.
4. Сравнить healthy и unhealthy scope: version, pod/node/AZ, tenant, route, partition (раздел журнала или данных; при network partition — разрыв связи).
5. Пройти RED сверху вниз, затем USE на вероятном bottleneck.
6. Взять representative slow/error trace (связь этапов одной операции), перейти к связанным logs и dependency metrics.
7. Сформулировать проверяемые гипотезы и для каждой указать ожидаемый сигнал.
8. Выбрать минимально рискованный mitigation: rollback (отмена локальной транзакции или возврат старой версии), traffic shift, feature disable, load shed, capacity.
9. Проверить user-visible recovery и остановку burn, а не только исчезновение одного alert.
10. Сохранить evidence и назначить root-cause analysis после стабилизации.

## Связь сигналов

Metrics отвечают «когда и насколько», traces — «какой путь и где время», logs — «какое событие/решение», profiles — «где CPU/allocation/blocking внутри процесса». Deployment annotations и config audit связывают изменение со временем. Correlation (совпадение/связь наблюдений, ещё не доказанная причина) не доказывает причину: подтверждайте controlled rollback, comparison или mechanism.

## Безопасность диагностики

Не запускайте неограниченный debug logging, full packet capture или высокочастотный profiling на всём fleet без оценки overhead и privacy. Ограничивайте scope/time, используйте read-only запросы, сохраняйте timestamps и команды. Не рестартуйте все replicas одновременно: это уничтожает volatile evidence и может усилить outage.

## Быстрый triage

| Симптом | Первые проверки |
|---|---|
| ошибки | status/error taxonomy, dependency outcomes, deploy diff |
| latency (срок ответа) | p50/p95/p99, queue time, slow traces, saturation (насыщение ресурса и образование очереди) |
| падение traffic | ingress/DNS/TLS, client metrics, routing |
| высокая нагрузка | request amplification, retries, hot key/partition, CPU throttling |
| backlog (накопившаяся необработанная работа) | arrival/processing rate, oldest age, consumer (потребитель работы или контракта) health |

Конкретные сценарии продолжены в разделе [Production runbooks](../production/README.md).

## Источники

- [Google SRE: effective troubleshooting](https://sre.google/sre-book/effective-troubleshooting/)
- [Go diagnostics](https://go.dev/doc/diagnostics)

## Разбор с числами

Учебный пример: deploy 12:00 UTC, в 12:03 GET p99 (время, в которое укладывается 99% наблюдений) вырос 120→800 ms. Только новая версия имеет высокую latency; RPS неизменен; DB pool wait=600 ms, SQL execution=30 ms. Гипотеза A: новый code держит connection во время HTTP-вызова. Гипотеза B: SQL стал медленным. B не объясняет прежнее query time, A объясняет stack/trace между BEGIN и COMMIT (фиксация результата, который считается подтверждённым).

Проверка: берём медленный trace новой версии, сравниваем длину transaction и сетевой span (измеряемый этап trace) со старой. Mitigation — canary rollback, не увеличение DB pool сразу. Если после rollback pool wait и пользовательская latency снизились при том же трафике, связь усиливается; root cause закрепляем reproducer/test, а не одной временной корреляцией.

```mermaid
flowchart LR
    Impact[Пользовательский симптом] --> Scope[Какая версия и область]
    Scope --> Hyp[Гипотеза и ожидаемый сигнал]
    Hyp --> Evidence[Trace, профиль, ресурс]
    Evidence --> Mit[Ограниченное исправление]
    Mit --> Verify[SLI восстановлен]
```

Сохраняем временные границы и факты до массового restart, если это не мешает спасению сервиса.

## Проверь себя

1. Доказывает ли совпадение с deploy причину?
2. Чем проверять mitigation?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, нужна механическая связь и сравнение/воспроизведение.
2. Пользовательским SLI (измеренный показатель качества), а не только исчезновением одной метрики.

</details>

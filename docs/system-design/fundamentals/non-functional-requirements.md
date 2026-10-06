---
title: Non-functional requirements
description: SLO, durability, consistency, security и cost budgets.
tags: [system-design, requirements, slo]
updated: 2026-10-06
---

# Non-functional requirements

Нефункциональное требование задаёт измеряемое качество операции: время, долю успеха, свежесть и восстановление.

«Быстро, надёжно и масштабируемо» не проверяется. NFR задают число, scope и окно.

| Область | Проверяемый вопрос |
| --- | --- |
| Latency (срок ответа) | p50/p95/p99 какого operation, при какой нагрузке и где измеряется? |
| Availability (доступность заявленной операции) | доля успешных valid requests за 30 дней; какие errors исключены? |
| Durability (сохранность подтверждённых данных при заявленных отказах) | сколько acknowledged writes можно потерять при каких failures (RPO (допустимая потеря подтверждённых данных))? |
| Recovery | за сколько восстановить operation/data (RTO (допустимое время восстановления))? |
| Consistency (согласованность наблюдаемых значений и порядка) | linearizable, read-your-writes, bounded (с явным конечным пределом) staleness — для каких данных? |
| Scale | peak QPS (число запросов в секунду), bytes/s, cardinality (число разных значений или временных рядов), hotspots и growth horizon |
| Security | data classification, tenant isolation, auth, audit, retention (срок хранения) |
| Cost | monthly/operation budget и дорогие failure/headroom scenarios |

Availability и durability различаются: сервис может отвечать, теряя writes, или быть временно недоступным, сохраняя их. Latency percentile без traffic mix скрывает дорогие endpoints.

SLO (цель качества сервиса за заданное окно) ниже 100% создаёт error budget для релизов и incidents. Dependencies должны укладываться в end-to-end budget: если API p99 (время, в которое укладывается 99% наблюдений) 300 ms, нельзя каждому из трёх последовательных calls дать timeout 300 ms.

Запишите priorities и допустимые degraded modes: stale read, отложенная отправка, read-only, отказ low-priority traffic. Именно они определяют trade-offs архитектуры.

## На конкретном примере

SLO 99,9% успешных valid GET за 30 дней даёт error budget 0,1% запросов, не автоматически 43,2 минуты простоя. При равномерном трафике время — приближение, при пиковой нагрузке минута ошибок стоит больше.

Требование «p99<300 ms при 5 000 RPS, 20% cache miss» содержит операцию, точку измерения и профиль нагрузки. «RPO=0 при потере одного узла» должно сопровождаться способом подтверждения durable копий; «RTO<60 s» включает обнаружение, переключение и прогрев, а не только restart.

## Источник механизма

[Google SRE: Service Level Objectives](https://sre.google/sre-book/service-level-objectives/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему SLO по запросам не равен времени uptime?
2. Что входит в RTO?

<details>
<summary>Ориентиры для ответа</summary>

1. Трафик меняется; одна минута может содержать разное число requests.
2. Всё время до восстановления заявленной операции, включая обнаружение и переключение.

</details>

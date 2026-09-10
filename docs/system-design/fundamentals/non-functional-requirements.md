---
title: Non-functional requirements
description: SLO, durability, consistency, security и cost budgets.
tags: [system-design, requirements, slo]
updated: 2026-09-10
---

# Non-functional requirements

«Быстро, надёжно и масштабируемо» не проверяется. NFR задают число, scope и окно.

| Область | Проверяемый вопрос |
| --- | --- |
| Latency | p50/p95/p99 какого operation, при какой нагрузке и где измеряется? |
| Availability | доля успешных valid requests за 30 дней; какие errors исключены? |
| Durability | сколько acknowledged writes можно потерять при каких failures (RPO)? |
| Recovery | за сколько восстановить operation/data (RTO)? |
| Consistency | linearizable, read-your-writes, bounded staleness — для каких данных? |
| Scale | peak QPS, bytes/s, cardinality, hotspots и growth horizon |
| Security | data classification, tenant isolation, auth, audit, retention |
| Cost | monthly/operation budget и дорогие failure/headroom scenarios |

Availability и durability различаются: сервис может отвечать, теряя writes, или быть временно недоступным, сохраняя их. Latency percentile без traffic mix скрывает дорогие endpoints.

SLO ниже 100% создаёт error budget для релизов и incidents. Dependencies должны укладываться в end-to-end budget: если API p99 300 ms, нельзя каждому из трёх последовательных calls дать timeout 300 ms.

Запишите priorities и допустимые degraded modes: stale read, отложенная отправка, read-only, отказ low-priority traffic. Именно они определяют trade-offs архитектуры.

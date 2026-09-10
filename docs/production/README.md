---
title: Production engineering
description: Incident response и диагностические runbooks для типичных backend failures.
tags: [production, sre, troubleshooting]
updated: 2026-09-10
---

# Production engineering

Раздел превращает симптомы в упорядоченные расследования. Сначала определяйте user impact и scope, затем сравнивайте healthy/unhealthy cohorts, проверяйте изменения и только после этого углубляйтесь в process/database/broker.

## Runbooks

- [Incident response](incident-response.md) — роли, timeline, mitigation и learning.
- [High CPU](high-cpu.md), [high memory](high-memory.md), [memory leak](memory-leak.md), [goroutine leak](goroutine-leak.md).
- [High latency](high-latency.md), [database overload](database-overload.md), [Kafka lag](kafka-lag.md).
- [Connection pool exhaustion](connection-pool-exhaustion.md), [retry storm](retry-storm.md), [thundering herd](thundering-herd.md).

Runbook — starting point, не набор команд для слепого выполнения. Укажите владельца, environment-specific dashboards, права, rollback и опасные действия. Любая mitigation проверяется по пользовательскому SLI.

Основной workflow: [Production debugging](../observability/production-debugging.md).


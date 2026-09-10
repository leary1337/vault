---
title: Alerting
description: Actionable alerts, SLO burn rate, routing, deduplication и runbooks.
tags: [observability, alerting, sre]
updated: 2026-09-10
---

# Alerting

Alert требует человеческого действия. Если получатель не может назвать impact, срочность и следующий диагностический шаг, это dashboard signal или ticket, а не page.

## На что alert-ить

- быстрый или устойчивый расход SLO error budget;
- непосредственный риск data loss/security incident;
- saturation, которая скоро нарушит пользовательский контракт;
- отказ обязательного synthetic/end-to-end journey;
- отсутствие telemetry только когда оно скрывает критичное состояние.

CPU 80%, один pod restart или единичный log error редко достаточны сами по себе. Симптомный alert должен переживать смену внутренней архитектуры; cause metrics помогают diagnosis.

## Multi-window burn rate

Одна короткая window быстро реагирует, но шумит; одна длинная точна, но медленна и долго восстанавливается. Multi-window, multi-burn-rate правило требует превышения одного threshold одновременно на long и short windows и использует несколько пар для быстрых и медленных burns.

Для 99.9% SLO за 30 дней Google SRE предлагает как стартовые, не универсальные, page-пары `14.4×` на `1h/5m` и `6×` на `6h/30m`, а более медленный расход — ticket. Low-traffic services требуют minimum-event guards, synthetic checks или более длинных окон: одна ошибка не всегда оправдывает page.

## Alert contract

Каждое правило содержит:

- service/SLI, severity и affected scope;
- owner и routing/escalation;
- краткое объяснение условия и dashboard/trace links;
- runbook с безопасными mitigations и rollback;
- deduplication/grouping key;
- тест правила и способ временно silencing при контролируемой работе.

Page — немедленное действие; ticket — действие в рабочее время. Группируйте производные alerts под root symptom, используйте inhibition для заведомо зависимых failures и не скрывайте независимые impacts.

После incident проверяйте precision, recall, detection и recovery time. Удаляйте alerts, которые систематически не ведут к действию; не компенсируйте плохой сигнал большим `for` без понимания цены задержки.

## Источники

- [Google SRE Workbook: alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)
- [Prometheus alerting rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Alertmanager concepts](https://prometheus.io/docs/alerting/latest/alertmanager/)


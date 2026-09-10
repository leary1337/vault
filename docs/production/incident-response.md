---
title: Incident response
description: Управление impact, ролями, коммуникацией, mitigation и post-incident learning.
tags: [production, incident-response, sre]
updated: 2026-09-10
---

# Incident response

## Symptoms

SLO burn, synthetic failure, data/security alert или подтверждённая жалоба показывает существенный пользовательский impact. Объявляйте incident по impact/uncertainty, не ждите полной причины.

## Possible causes

Любое недавнее изменение, dependency/infrastructure failure, overload, data corruption, credential/security event или сочетание latent defect и нового traffic shape.

## What to measure

Affected journeys/users/regions, start time, error/latency/freshness SLI, burn rate, data/security exposure и скорость изменения. Отдельно фиксируйте observed facts и hypotheses.

## Diagnostics

Назначьте incident commander, operations lead и communications lead; для малого incident роли может совмещать один человек явно. Создайте общий UTC timeline. Сравните healthy/unhealthy cohorts и recent changes, затем проверяйте по одной falsifiable hypothesis. Не позволяйте нескольким людям независимо выполнять conflicting changes.

## Tools

SLO/dashboard, deployment/config audit, traces/logs/profiles, feature flags, status page, incident channel/document и runbooks. Доступ должен быть подготовлен заранее и защищён MFA/audit.

## Immediate mitigation

Сначала уменьшите impact: rollback, disable feature, traffic shift, load shedding, capacity или degraded read-only mode. Выбирайте reversible action с понятным blast radius; сохраняйте evidence до restart, если это не задерживает восстановление.

## Root cause

После стабилизации восстановите causal chain от trigger через control gaps к impact. «Человек ошибся» и «сервер упал» — не root cause. Отделите trigger, contributing factors, detection/response gaps и почему defenses не остановили отказ.

## Prevention

Назначьте конкретные actions с owner/deadline/verification: устранение механизма, ограничение blast radius, раннее обнаружение, безопасный rollback и rehearsal. Post-incident review должен быть blameless, но не безответственным; проверяйте выполнение actions.

## Источники

- [Google SRE: managing incidents](https://sre.google/sre-book/managing-incidents/)
- [Google SRE Workbook: postmortem culture](https://sre.google/workbook/postmortem-culture/)


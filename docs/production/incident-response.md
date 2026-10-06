---
title: Incident response
description: Управление impact, ролями, коммуникацией, mitigation и post-incident learning.
tags: [production, incident-response, sre]
updated: 2026-10-06
---

# Incident response

Incident response сначала уменьшает ущерб, потом закрепляет причину и исправления.

## Симптомы

SLO (цель качества сервиса за заданное окно) burn, synthetic failure, data/security alert или подтверждённая жалоба показывает существенный пользовательский impact. Объявляйте incident по impact/uncertainty, не ждите полной причины.

## Возможные причины

Любое недавнее изменение, dependency/infrastructure failure, overload, data corruption, credential/security event или сочетание latent defect и нового traffic shape.

## Что измерить

Affected journeys/users/regions, start time, error/latency/freshness SLI (измеренный показатель качества), burn rate, data/security exposure и скорость изменения. Отдельно фиксируйте observed facts и hypotheses.

## Проверка гипотез

Назначьте incident commander, operations lead и communications lead; для малого incident роли может совмещать один человек явно. Создайте общий UTC timeline. Сравните healthy/unhealthy cohorts и recent changes, затем проверяйте по одной falsifiable hypothesis. Не позволяйте нескольким людям независимо выполнять conflicting changes.

## Инструменты

SLO/dashboard, deployment/config audit, traces/logs/profiles, feature flags, status page, incident channel/document и runbooks. Доступ должен быть подготовлен заранее и защищён MFA/audit.

## Как уменьшить ущерб

Сначала уменьшите impact: rollback (отмена локальной транзакции или возврат старой версии), disable feature, traffic shift, load shedding, capacity или degraded read-only mode. Выбирайте reversible action с понятным blast radius; сохраняйте evidence до restart, если это не задерживает восстановление.

## Механизм причины

После стабилизации восстановите causal chain от trigger через control gaps к impact. «Человек ошибся» и «сервер упал» — не root cause. Отделите trigger, contributing factors, detection/response gaps и почему defenses не остановили отказ.

## Предотвращение

Назначьте конкретные actions с owner/deadline/verification: устранение механизма, ограничение blast radius, раннее обнаружение, безопасный rollback и rehearsal. Post-incident review должен быть blameless, но не безответственным; проверяйте выполнение actions.

## Источники

- [Google SRE: managing incidents](https://sre.google/sre-book/managing-incidents/)
- [Google SRE Workbook: postmortem culture](https://sre.google/workbook/postmortem-culture/)

## Разбор с числами

Учебный timeline: 12:00 deploy; 12:03 burn alert; 12:05 подтверждён отказ PATCH новой версии; 12:07 остановлен rollout; 12:10 rollback; 12:14 success вернулся; 12:20 проверена очередь неопределённых операций. UTC timestamp и действия/наблюдения разделяем.

Гипотеза «новый запрос блокирует таблицу» получает evidence `pg_blocking_pids`, длинный migration transaction и совпавший scope. Гипотеза «весь регион потерян» противоречит здоровым старым replicas. Commander координирует одно изменение за раз, operations выполняет, communications сообщает проверенный impact.

Восстановление HTTP 200 не закрывает incident автоматически: сверяем сохранённые/потерянные записи, backlog (накопившаяся необработанная работа) и внешний эффект неизвестных операций. Postmortem содержит механизм, почему защита не сработала, owner и проверку action; «быть внимательнее» не предотвращает повтор.

## Проверь себя

1. Когда объявлять incident?
2. Что проверить после восстановления ответов?

<details>
<summary>Ориентиры для ответа</summary>

1. При значимом impact/неопределённости, не после окончательного RCA.
2. Данные, backlog, неопределённые эффекты и устойчивость SLI.

</details>

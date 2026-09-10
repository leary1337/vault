---
title: Monolith vs microservices
description: Deployment, data ownership, consistency и организационные trade-offs.
tags: [architecture, monolith, microservices]
updated: 2026-09-10
---

# Monolith vs microservices

Monolith и microservices различаются прежде всего deployment/runtime boundaries. Они не говорят автоматически о качестве внутренней модульности. Distributed monolith получает network failures без независимости изменений; modular monolith может иметь сильные границы в одном процессе.

## Сравнение

| Свойство | Monolith | Microservices |
|---|---|---|
| deploy | единый artifact/release | независимый при реальной decoupling |
| calls | in-process, низкая latency | network, timeout/partial failure |
| transactions | проще общая ACID boundary | локальная ACID, cross-service workflow |
| data | легко разделить физически хуже | ownership обязательно, duplication часто нужно |
| operations | проще старт | discovery, observability, delivery, security сложнее |
| scaling | весь process/unit | отдельные bottlenecks независимо |

## Когда разделять

Полезные сигналы: разные команды и cadence, отдельный security/compliance boundary, радикально иной scaling/failure profile, независимая availability или доказанное ограничение monolith deployment. Размер кода сам по себе слабый критерий.

Перед extraction зафиксируйте bounded context, ownership данных, API/event contracts, migration/rollback и observability. Нельзя просто дать двум сервисам запись в одни таблицы: это сохраняет schema coupling и не определяет consistency owner.

## Цена distribution

Каждый sync call добавляет latency, availability multiplication, retries и load amplification. Cross-service invariant требует redesign: saga, reservation, idempotency и reconciliation. Eventual consistency — не оправдание неопределённого результата; пользователю нужен state model.

Начинайте с более простого deployable, если нет организационной или runtime причины распределять. Возвращение нескольких сервисов в один процесс тоже допустимая архитектурная работа.


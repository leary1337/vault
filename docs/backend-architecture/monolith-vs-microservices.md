---
title: Monolith vs microservices
description: Deployment, data ownership, consistency и организационные trade-offs.
tags: [architecture, monolith, microservices]
updated: 2026-10-06
---

# Monolith vs microservices

Микросервисная граница добавляет независимый запуск и сетевой отказ; монолитная — оставляет вызов в одном процессе.

Monolith и microservices различаются прежде всего deployment/runtime boundaries. Они не говорят автоматически о качестве внутренней модульности. Distributed monolith получает network failures без независимости изменений; modular monolith может иметь сильные границы в одном процессе.

## Сравнение

| Свойство | Monolith | Microservices |
|---|---|---|
| deploy | единый artifact/release | независимый при реальной decoupling |
| calls | in-process, низкая latency (срок ответа) | network, timeout/partial failure |
| transactions | проще общая ACID boundary | локальная ACID, cross-service workflow |
| data | легко разделить физически хуже | ownership (владение данными или ответственность за ресурс) обязательно, duplication часто нужно |
| operations | проще старт | discovery, observability, delivery, security сложнее |
| scaling | весь process/unit | отдельные bottlenecks независимо |

## Когда разделять

Полезные сигналы: разные команды и cadence, отдельный security/compliance boundary, радикально иной scaling/failure profile, независимая availability (доступность заявленной операции) или доказанное ограничение monolith deployment. Размер кода сам по себе слабый критерий.

Перед extraction зафиксируйте bounded (с явным конечным пределом) context, ownership данных, API/event contracts, migration/rollback и observability. Нельзя просто дать двум сервисам запись в одни таблицы: это сохраняет schema coupling и не определяет consistency (согласованность наблюдаемых значений и порядка) owner.

## Цена distribution

Каждый sync call добавляет latency, availability multiplication, retries и load amplification. Cross-service invariant (правило, которое система обязана сохранять) требует redesign: saga, reservation, idempotency и reconciliation (сверка и устранение расхождений). Eventual consistency — не оправдание неопределённого результата; пользователю нужен state model.

Начинайте с более простого deployable, если нет организационной или runtime причины распределять. Возвращение нескольких сервисов в один процесс тоже допустимая архитектурная работа.

## Механизм на примере

Учебный расчёт: запрос вызывает последовательно пять сервисов, каждый доступен 99,9%, отказы условно независимы и любой отказ ломает ответ. Доступность пути ≈ `0.999^5 = 99.501%`, ещё без gateway/БД. При общих отказах независимость неверна; формула — модель, а не измерение.

Пять последовательных calls по 40 ms дают не меньше 200 ms только зависимостей. Параллелизм сокращает время, но умножает одновременную нагрузку и требует отмены/частичных результатов. Разделение имеет смысл при отдельном масштабировании, команде, доступе или отказоустойчивости. Независимый deploy не получен, если каждый release требует синхронной смены схемы пяти сервисов.

## Источник механизма

[Google SRE: каскадные отказы](https://sre.google/sre-book/addressing-cascading-failures/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему микросервисы могут снизить доступность?
2. Что доказывает необходимость разделения?

<details>
<summary>Ориентиры для ответа</summary>

1. Критический путь получает больше независимых и общих точек отказа.
2. Конкретная независимая граница scale, команды, безопасности или жизненного цикла.

</details>

---
title: Saga
description: Long-running workflow из local transactions и compensations.
tags: [backend, patterns, transactions]
updated: 2026-10-06
---

# Saga


Saga — процесс из локальных транзакций; компенсация выполняет новое обратное бизнес-действие, не стирая историю.

## Проблема

Business workflow изменяет несколько services/resources, которые нельзя включить в одну короткую ACID transaction.

## Как работает

Saga хранит durable state machine из local transactions. После failure выполняются compensating actions для уже завершённых steps. Orchestration явно командует steps; choreography реагирует на events без центрального coordinator.

## Гарантии и границы

При durable workflow, idempotent (без второго эффекта при повторе одного намерения) steps и бесконечном/операторском recovery saga со временем приходит в terminal business state. Она не даёт global isolation и не скрывает intermediate states.

## Ошибки и отказы

- crash между side effect и записью step state;
- duplicate/out-of-order command/event;
- compensation сама падает или становится невозможной;
- concurrent saga меняет тот же aggregate;
- choreography образует невидимый cycle;
- бесконечный retry блокирует business/manual resolution.

## Компромиссы

Orchestrator улучшает observability/control, но централизует workflow coupling. Choreography сохраняет autonomy, но усложняет понимание, versioning и end-to-end tracing. Compensation — новая business logic, которую нужно тестировать.

## Когда не применять

Если invariant (правило, которое система обязана сохранять) можно держать в одной database transaction, saga избыточна. Если промежуточное состояние никогда нельзя показывать, нужен другой boundary/atomic protocol.

## Пример

Order saga: reserve inventory → authorize payment → confirm order. При failure payment: release inventory. При failure после charge: refund — это новое действие, не стирающее audit факта оплаты. Каждый step имеет stable command ID, timeout и manual state.

Подробнее: [distributed transactions](../distributed-systems/distributed-transactions.md).

## Разобранный пример

Для покупки храним `workflow(id,state,version)` и `step(command_id,status)`: резерв → авторизация оплаты → подтверждение. Каждый переход условен по версии; команды имеют устойчивый ID. Если деньги списаны, refund — новый платёжный факт. Если письмо отправлено, отменить его невозможно.

Компенсация резерва после отмены должна не освободить резерв другого заказа: передаём reservation ID, не просто product ID. Неизвестный исход charge сначала выясняем у провайдера по key; повторное charge или раннее release могут одновременно создать оплату без товара. Неуспешная компенсация получает состояние `manual_review`, ответственного и срок, а не исчезает в журнале ошибок.

## Источник механизма

[Исходная работа о Saga](https://www.cs.cornell.edu/andru/cs711/2002fa/reading/sagas.pdf). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Даёт ли saga общую изоляцию?
2. Почему compensation может не вернуть старый мир?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, промежуточные состояния могут быть видны.
2. Внешние эффекты необратимы, а другие участники уже реагировали на них.

</details>

---
title: Распределённые транзакции
description: 2PC, coordinator failure, saga и transactional messaging.
tags: [distributed-systems, transactions]
updated: 2026-10-06
---

# Распределённые транзакции

Распределённая транзакция согласует атомарное решение нескольких хранилищ; saga допускает промежуточные состояния и компенсирует шаги.

Distributed transaction пытается атомарно изменить несколько independent resource managers. Сначала спросите, можно ли colocate invariant (правило, которое система обязана сохранять), сделать один authoritative (владеющий достоверным состоянием) write и распространить события асинхронно.

## Two-phase commit

1. Prepare: coordinator просит participants подготовить transaction; каждый durable записывает решение «готов» и удерживает locks/resources.
2. Commit/abort: после всех yes coordinator durable фиксирует global decision и рассылает его.

2PC даёт atomic commit (фиксация результата, который считается подтверждённым) при assumptions protocol, но не является consensus. Если participant prepared и потерял coordinator/decision, он может блокироваться, пока решение не восстановлено. Coordinator log, participant recovery, heuristic outcomes и timeouts требуют operational plan.

XA/2PC подходит, когда все resources поддерживают protocol, locks короткие, latency/failure domains приемлемы и atomicity важнее availability (доступность заявленной операции). Он плохо сочетается с произвольными HTTP services и долгими business workflows.

## Saga

Saga — последовательность local transactions с compensating actions при failure. Orchestration хранит workflow state централизованно; choreography связывает services events и уменьшает центральную логику, но усложняет tracing/evolution.

Compensation не rollback (отмена локальной транзакции или возврат старой версии): отправленный email не «отправить назад», refund не отменяет факт charge, а concurrent observers уже видели промежуточное состояние. Steps должны быть idempotent (без второго эффекта при повторе одного намерения), state machine — durable, retry/timeout/manual resolution — явными.

## Messaging boundary

[Transactional Outbox (события, сохранённые вместе с бизнес-изменением)](../messaging/transactional-outbox.md) атомарно сохраняет business change и intent-to-publish в одной БД. [Inbox (записи уже применённых событий для защиты от повторов)](../messaging/inbox-pattern.md) deduplicate-ит consumer (потребитель работы или контракта) effect. Это даёт reliable eventual workflow, но не мгновенную global isolation.

Выбирайте по invariant, допустимому промежуточному состоянию, blocking time, availability, audit и recovery, а не по названию pattern.

## Источники

- [Gray and Lamport: Consensus on Transaction Commit](https://www.microsoft.com/en-us/research/publication/consensus-on-transaction-commit/)
- [Saga paper](https://www.cs.cornell.edu/andru/cs711/2002fa/reading/sagas.pdf)

## Механизм на примере

2PC: участник записал prepared и удерживает lock; coordinator исчез до получения commit/abort. Timeout не даёт права произвольно abort: другой участник мог уже получить commit. Нужен durable decision/recovery протокол. Репликация coordinator повышает его доступность, но это отдельный механизм consensus, а не свойство любого 2PC.

Пример альтернативы для заказа: один store владеет заказом, inventory выдаёт reservation ID с сроком, payment использует stable key. Состояния pending/confirmed/cancelled видны явно. Истёкший резерв после неизвестной оплаты требует reconciliation (сверка и устранение расхождений); компенсация освобождает именно reservation, не любой резерв товара.

При возможности положить баланс и запись перевода в одну короткую SQL transaction это проще saga. Выбор определяется недопустимым промежуточным состоянием и доступностью, а не популярностью паттерна.

## Проверь себя

1. Почему prepared участник не может просто отмениться по timeout?
2. Делает ли saga мгновенную атомарность?

<details>
<summary>Ориентиры для ответа</summary>

1. Общее решение могло уже быть commit на другой стороне.
2. Нет, она реализует восстанавливаемый бизнес-процесс с промежуточными состояниями.

</details>

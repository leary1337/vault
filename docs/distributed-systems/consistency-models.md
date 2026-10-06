---
title: Модели согласованности
description: Linearizability, sequential, causal и client-centric guarantees.
tags: [distributed-systems, consistency]
updated: 2026-10-06
---

# Модели согласованности

Модель согласованности описывает разрешённые наблюдения клиента: какие старые значения и порядки он может увидеть.

Consistency (согласованность наблюдаемых значений и порядка) model ограничивает результаты concurrent operations, которые разрешено наблюдать. Это контракт API/storage, а не синоним «реплики когда-нибудь совпадут».

## Строгие модели

- Linearizability: каждая operation выглядит мгновенной между invocation и response и уважает real-time order. После завершившейся записи более позднее чтение не может вернуть старое значение.
- Sequential consistency: существует единый порядок operations, согласованный с program order каждого client, но не обязан уважать real time между clients.
- Serializability: transaction outcome эквивалентен последовательному выполнению transactions. Без strictness она не обязательно linearizable относительно real time.
- Strict serializability объединяет serializability с real-time ordering и является transactional аналогом linearizability.

Не смешивайте isolation level внутри одной database с consistency replicated service: это связанные, но разные границы.

## Weaker и session guarantees

- Causal consistency сохраняет cause-before-effect; concurrent независимые writes могут наблюдаться в разном порядке.
- Eventual consistency обещает convergence при отсутствии новых updates, но сама по себе не задаёт conflict resolution, maximum staleness или session behavior.
- Read-your-writes позволяет client видеть собственные завершённые writes.
- Monotonic reads не возвращает одной session всё более старые версии.
- Monotonic writes сохраняет порядок writes session.
- Bounded (с явным конечным пределом) staleness ограничивает отставание временем или версиями.

## Как выбирать

Сначала задайте invariant (правило, которое система обязана сохранять). Уникальная выдача денег/lease часто требует linearizable compare-and-set или serializable transaction. Feed и analytics могут допускать stale reads. Один сервис может давать разные guarantees: linearizable metadata и eventual cache.

Тестируйте model при реальных faults и concurrency. «Запись ушла на три replicas» ещё не доказывает linearizability: важны quorum (достаточный набор участников для решения) intersection, leader (узел, координирующий запись) fencing (отклонение действий старого владельца самим ресурсом), retry semantics и read path.

## Источники

- [Herlihy and Wing: Linearizability](https://cs.brown.edu/~mph/HerlihyW90/p463-herlihy.pdf)
- [Jepsen consistency models](https://jepsen.io/consistency/models)

## Механизм на примере

Начальное x=0. A записал x=1 и получил успех. Затем B начинает read и получает 0. Это нарушает linearizability одного ключа, но может соответствовать eventual replica (копия данных на другом узле) read. Если A сам получает 0, нарушено также read-your-writes его сессии.

Для двух клиентов допустим общий порядок, не совпадающий с реальным временем, — sequential consistency. Для двух SQL-транзакций serializability означает эквивалент некоторому последовательному выполнению целых транзакций. Она не равна «каждый statement видит самую свежую реплику».

Выдача minimum-version token работает, только если read endpoint проверяет применённую версию и ждёт/перенаправляет запрос. Добавить поле `version` в JSON без такого поведения недостаточно. При недоступности достаточно свежей реплики выбираем ожидание/ошибку, а не незаметный откат гарантии.

## Проверь себя

1. Что нарушает read 0 после завершённого write 1?
2. Как гарантировать свои записи через replica?

<details>
<summary>Ориентиры для ответа</summary>

1. Линейризуемость, если read начался после ответа write в той же границе ключа.
2. Передать минимальную версию и дождаться её применения либо прочитать authority.

</details>

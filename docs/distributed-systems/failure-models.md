---
title: Модели отказов
description: Crash, omission, timing, Byzantine faults и partial failure.
tags: [distributed-systems, reliability]
updated: 2026-10-06
---

# Модели отказов

Частичный отказ — часть системы работает, но клиент не знает, выполнена ли операция другой частью.

Алгоритм корректен только относительно заявленной failure model. Production incident часто выходит за неявные assumptions: диск подтверждает незаписанные данные, часы скачут, DNS stale, а несколько replicas оказываются в одной зоне.

## Классы

- Crash-stop: процесс остановился и не возвращается.
- Crash-recovery: процесс перезапускается с частью durable state; нужны epochs и recovery protocol.
- Omission: request/response/message теряется, дублируется или задерживается.
- Timing fault: operation завершается позже ожидаемого; в asynchronous model конечной верхней границы нет.
- Byzantine fault: узел произвольно врёт/искажает данные; обычный Raft/Paxos это не покрывает.
- Data corruption и misconfiguration: процесс жив, но state неверен.

Network partition (раздел журнала или данных; при network partition — разрыв связи) — частичный omission: группы узлов общаются внутри, но не между собой. Slow node неотличим от failed по одному timeout, поэтому failure detector даёт suspicion, а не знание.

## Correlated failures

Три replicas в одном rack/account/region или на одном power/network path не дают три независимых failure domain. Общие dependencies — DNS, IAM, certificate, deploy, clock source, quota — создают одновременный отказ.

## Timeout и retry

Timeout ограничивает ожидание клиента, но не отменяет server work. После timeout outcome может быть unknown; retry без idempotency создаёт duplicate. Массовые синхронные retries усиливают overload, поэтому нужны deadline (крайний срок завершения) propagation, exponential backoff, jitter, budgets и load shedding.

## Проверка дизайна

Для каждой операции спросите:

1. Что durable до acknowledgement?
2. Может ли старый leader (узел, координирующий запись) продолжать side effects?
3. Что делает client при timeout/duplicate/out-of-order response?
4. Сколько failure domains можно потерять?
5. Как state repair-ится после partition?
6. Проверяли ли restore/failover с реальной нагрузкой?

## Источники

- [Chandra and Toueg: Unreliable failure detectors](https://www.cs.cornell.edu/home/sam/FDpapers/CT96-JACM.pdf)
- [Jepsen analyses](https://jepsen.io/analyses)

## Механизм на примере

Три момента операции: до durable write; после write до ответа; после ответа. Падение в первом случае не оставляет effect, во втором — неизвестный для клиента результат, в третьем — уже подтверждённые данные должны пережить заявленный класс отказов.

Crash-recovery отличается от crash-stop: перезапущенный процесс может отправить отложенный старый ответ или продолжить действие с устаревшим lease (временное право владения). Добавляем epoch/ID, проверяем владельца на ресурсе. Тест kill -9 не воспроизводит долгую паузу живого процесса и односторонний partition.

Общая конфигурационная ошибка/удаление одновременно влияет на все реплики: три копии не делают backup. RPO (допустимая потеря подтверждённых данных) обозначает допустимую потерю уже подтверждённых данных, RTO (допустимое время восстановления) — срок восстановления операции; оба надо проверять конкретным восстановлением.

## Проверь себя

1. Что сообщает timeout?
2. Почему три реплики не заменяют backup?

<details>
<summary>Ориентиры для ответа</summary>

1. Только истечение ожидания, не факт неисполнения.
2. Они могут синхронно повторить ошибочное удаление.

</details>

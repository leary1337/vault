---
title: Модели отказов
description: Crash, omission, timing, Byzantine faults и partial failure.
tags: [distributed-systems, reliability]
updated: 2026-09-10
---

# Модели отказов

Алгоритм корректен только относительно заявленной failure model. Production incident часто выходит за неявные assumptions: диск подтверждает незаписанные данные, часы скачут, DNS stale, а несколько replicas оказываются в одной зоне.

## Классы

- Crash-stop: процесс остановился и не возвращается.
- Crash-recovery: процесс перезапускается с частью durable state; нужны epochs и recovery protocol.
- Omission: request/response/message теряется, дублируется или задерживается.
- Timing fault: operation завершается позже ожидаемого; в asynchronous model конечной верхней границы нет.
- Byzantine fault: узел произвольно врёт/искажает данные; обычный Raft/Paxos это не покрывает.
- Data corruption и misconfiguration: процесс жив, но state неверен.

Network partition — частичный omission: группы узлов общаются внутри, но не между собой. Slow node неотличим от failed по одному timeout, поэтому failure detector даёт suspicion, а не знание.

## Correlated failures

Три replicas в одном rack/account/region или на одном power/network path не дают три независимых failure domain. Общие dependencies — DNS, IAM, certificate, deploy, clock source, quota — создают одновременный отказ.

## Timeout и retry

Timeout ограничивает ожидание клиента, но не отменяет server work. После timeout outcome может быть unknown; retry без idempotency создаёт duplicate. Массовые синхронные retries усиливают overload, поэтому нужны deadline propagation, exponential backoff, jitter, budgets и load shedding.

## Проверка дизайна

Для каждой операции спросите:

1. Что durable до acknowledgement?
2. Может ли старый leader продолжать side effects?
3. Что делает client при timeout/duplicate/out-of-order response?
4. Сколько failure domains можно потерять?
5. Как state repair-ится после partition?
6. Проверяли ли restore/failover с реальной нагрузкой?

## Источники

- [Chandra and Toueg: Unreliable failure detectors](https://www.cs.cornell.edu/home/sam/FDpapers/CT96-JACM.pdf)
- [Jepsen analyses](https://jepsen.io/analyses)

---
title: Leader election
description: Terms, leases, fencing и безопасный failover.
tags: [distributed-systems, consensus]
updated: 2026-10-06
---

# Leader election

Выбор лидера назначает новое поколение владельца, но остановить старого владельца должен протокол и защищаемый ресурс.

Leader (узел, координирующий запись) election выбирает единственного coordinator на epoch (номер поколения), но одного выбора недостаточно: старый leader может быть жив в partition (раздел журнала или данных; при network partition — разрыв связи). Без fencing (отклонение действий старого владельца самим ресурсом) два процесса одновременно выполнят side effects.

## Consensus-backed election

Quorum (достаточный набор участников для решения) protocol выдаёт новый монотонный term/epoch. Leader прикладывает epoch к writes; replicated state или downstream resource отвергает epoch ниже уже принятого. Это отличает ownership (владение данными или ответственность за ресурс) proof от «я давно не видел другого leader».

Candidate (кандидат на лидерство) должен иметь достаточно актуальный replicated state, иначе promotion теряет committed data. Election timeout рандомизируют, чтобы кандидаты не голосовали синхронно; слишком маленький timeout вызывает churn при latency (срок ответа) spike, слишком большой увеличивает failover time.

## Leases

Time-based lease (временное право владения) даёт leadership на ограниченный срок. Для safety нужны bounded (с явным конечным пределом) clock drift/uncertainty и правило, не допускающее overlap; process pause может пережить lease. Даже после локальной проверки времени downstream fencing token остаётся сильнее.

## Небезопасные варианты

- lock file на shared storage без надёжной atomicity/fencing;
- «самый маленький instance ID» без согласованного membership;
- TTL (время жизни записи) key с failover на asynchronous replica (копия данных на другом узле);
- health check/load balancer, который только меняет traffic и не fence-ит old leader;
- ручное promotion двух сторон network partition.

## Эксплуатация

Укажите election authority, quorum, epoch storage, readiness (готовность принять новую работу) condition и demotion path. При incident проверяйте current term/leader, quorum reachability, last committed/applied position и старые processes. Chaos test должен включать pause, one-way partition и delayed messages, а не только kill процесса.

Для cron-like singleton часто проще сделать работу idempotent (без второго эффекта при повторе одного намерения) и допустить несколько workers, чем строить слабую election.

## Источники

- [Raft paper](https://raft.github.io/raft.pdf)
- [Leases: an efficient fault-tolerant mechanism](https://dl.acm.org/doi/10.1145/74850.74870)

## Механизм на примере

A term (поколение лидерства)=7 потерял связь с большинством; B избран в term=8. A остаётся жив и может выполнять старую задачу. Сообщения Raft с term=7 отвергаются, но внешний файловый store ничего не знает о Raft, если token не передан. Leader election защищает свой журнал, а не любой внешний side effect.

Для job runner каждый запуск имеет durable ID, lease и fencing на записи результата. После потери лидерства прекращаем новые задачи; отмена текущих best-effort. Получивший token=8 storage не принимает позднюю запись token=7. Измеряем время обнаружения, выборов, catch-up и перенаправления клиентов отдельно: один election timeout не равен RTO (допустимое время восстановления).

## Проверь себя

1. Почему health check не fence старого лидера?
2. Что входит в failover time?

<details>
<summary>Ориентиры для ответа</summary>

1. Он меняет маршрутизацию, но не запрещает старую запись в ресурс.
2. Обнаружение, выборы, готовность данных и переключение клиента.

</details>

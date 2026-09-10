---
title: Consensus
description: Зачем нужен consensus и концептуальная модель Raft.
tags: [distributed-systems, consensus]
updated: 2026-09-10
---

# Consensus

Consensus позволяет участникам согласовать ordered decisions несмотря на crashes и задержки: кто leader, какая запись следующая, какая configuration актуальна. Он нужен для replicated state machine, metadata/control plane и linearizable coordination.

## Требования

- Safety: два корректных участника не решают конфликтующие значения/log entries.
- Liveness: при достаточной связи и доступном quorum система со временем продвигается.

В полностью asynchronous network невозможно гарантированно различить delay и failure; практические protocols получают liveness при периодах достаточной synchrony и timeouts, сохраняя safety при задержках.

## Raft conceptual model

Nodes переходят между follower, candidate и leader; term монотонно обозначает election epoch. Candidate собирает majority голосов, причём freshness log участвует в правиле голосования. Leader назначает log index/term, реплицирует entries followers и commit-ит, когда выполнено quorum rule; state machine применяет только committed prefix.

Term/epoch fence-ит сообщения старого leader. Majority intersection не позволяет commit двух разных entries на одном index при корректном protocol. Snapshot/log compaction сокращает history, но snapshot installation тоже часть protocol.

## Что consensus не делает

- не делает медленный storage быстрым;
- не выдерживает потерю majority;
- обычный Raft не защищает от Byzantine nodes;
- не делает произвольный external side effect частью log;
- не заменяет client idempotency: response может потеряться после commit;
- не равен distributed transaction protocol.

## Production design

Расположите voters в независимых failure domains и оцените latency majority path. Наблюдайте leader changes, term, commit/apply lag, snapshot/recovery и quorum health. Отделяйте data replicas/learners от voting members: больше voters может снизить availability и увеличить latency.

## Источники

- [In Search of an Understandable Consensus Algorithm](https://raft.github.io/raft.pdf)
- [The Part-Time Parliament (Paxos)](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf)

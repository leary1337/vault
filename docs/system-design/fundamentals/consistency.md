---
title: Consistency в System Design
description: Выбор модели по invariant и границе операции.
tags: [system-design, consistency]
updated: 2026-09-10
---

# Consistency в System Design

Не выбирайте между «strong» и «eventual» для всей системы. Укажите operation/data scope и observable guarantee.

## От invariant к модели

- списание денег/unique username: serializable/linearizable coordination или single authoritative transaction;
- profile после собственного update: read-your-writes/session routing;
- feed/search index: bounded/eventual staleness с visible timestamp;
- counter analytics: commutative aggregation и approximate result;
- configuration/leader: consensus-backed linearizable state.

Consistency, isolation и durability различаются. Serializable transaction может быть потеряна при слабой durability; replicated linearizable key не делает multi-key transaction atomic.

## Design questions

- Что видит client после successful write и после timeout?
- Можно ли читать replica/cache; как передаётся minimum version?
- Как concurrent writes conflict-уют и кто merge-ит?
- Что происходит при partition: reject или stale/ divergent response?
- Как derived views repair/rebuild-ятся?

Укажите latency/availability trade-off и degraded mode. «Eventually» дополните maximum acceptable lag, monitoring и recovery; иначе это отсутствие контракта. Подробнее: [consistency models](../../distributed-systems/consistency-models.md) и [CAP/PACELC](../../distributed-systems/cap-and-pacelc.md).

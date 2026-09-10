---
title: Profile-guided optimization
description: Сбор representative CPU profile и воспроизводимое применение PGO.
tags:
  - go
  - performance
  - pgo
updated: 2026-09-10
---

# Profile-guided optimization

PGO позволяет compiler использовать CPU profile representative production workload при inlining и devirtualization decisions.

Типовой flow:

1. Собрать CPU profile стабильной версии под типичной нагрузкой.
2. Сохранить его как `default.pgo` в main package или передать `go build -pgo=profile.pprof`.
3. Собрать и проверить новую версию обычными tests/load tests.
4. Обновлять profile периодически, не на каждом request/deploy автоматически.

Profile — build input: храните provenance, workload и Go version; не включайте чувствительные labels/paths. Нерепрезентативный profile может оптимизировать не тот path. PGO не заменяет исправление алгоритма и измерение end-to-end outcome.

## Источники

- [Profile-guided optimization](https://go.dev/doc/pgo)
- [PGO user guide](https://go.dev/doc/pgo)

---
title: Concurrency в Go
description: Модель конкурентности Go, goroutines, channels и синхронизация.
tags:
  - go
  - concurrency
updated: 2026-09-10
---

# Concurrency в Go

Порядок чтения: [модель памяти](memory-model.md) → [goroutines](goroutines.md) → [channels](channels.md) → [примитивы синхронизации](sync-primitives.md) → [atomics](atomics.md) → [context](context.md).

Затем переходите к failure modes: [data races](data-races.md), [goroutine leaks](goroutine-leaks.md), [backpressure](backpressure.md) и [graceful shutdown](graceful-shutdown.md). Мигрированные [основы](fundamentals.md) и [паттерны](patterns.md) сохраняют дополнительный материал и будут разделены при следующем проходе.

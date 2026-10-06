---
title: Concurrency в Go
description: Модель конкурентности Go, goroutines, channels и синхронизация.
tags:
  - go
  - concurrency
updated: 2026-10-06
---

# Concurrency в Go

Конкурентность позволяет нескольким задачам продвигаться независимо. Здесь разбирается не только запуск goroutines, но и кто владеет данными, что их синхронизирует, как отменить ожидание и дождаться завершения. Простые примеры сопровождаются механизмом и производственными ограничениями.

## Темы

- [Atomics](atomics.md)
- [Backpressure](backpressure.md)
- [Channels](channels.md)
- [Context](context.md)
- [Data races](data-races.md)
- [Goroutine leaks](goroutine-leaks.md)
- [Goroutines](goroutines.md)
- [Graceful shutdown](graceful-shutdown.md)
- [Модель памяти Go](memory-model.md)
- [Основы конкурентности в Go](fundamentals.md)
- [Паттерны конкурентности](patterns.md)
- [Примитивы синхронизации](sync-primitives.md)

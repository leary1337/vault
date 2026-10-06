---
title: Runtime Go
description: Компиляция, scheduler, управление памятью и garbage collector Go.
tags:
  - go
  - runtime
updated: 2026-10-06
---

# Runtime Go

Runtime — встроенная в программу система выполнения: goroutines, scheduler, сеть, allocator и GC. Детали ниже относятся к стандартному Go 1.27, а исходники примеров реализации закреплены на Go 1.27.1. Эти знания помогают объяснить симптомы, но не заменяют измерение приложения.

## Темы

- [Garbage collector Go](garbage-collector.md)
- [Netpoller](netpoller.md)
- [Runtime Go](runtime-overview.md)
- [Scheduler Go](scheduler.md)
- [Компиляция и сборка Go](compilation.md)
- [Управление памятью Go](memory-management.md)

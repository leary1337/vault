---
title: System Design cases
description: Разборы проектирования с альтернативами и trade-offs.
tags: [system-design, cases]
updated: 2026-09-10
---

# System Design cases

Cases применяют [общий процесс](../system-design-process.md), но не выдают одну архитектуру за универсальную. Для каждого сначала уточните scale, SLO, consistency и abuse model: другой ответ меняет storage и topology.

Полезное упражнение: до чтения решения выпишите API, source of truth, read/write path и три failure scenarios; затем сравните trade-offs.

## Темы

- [Chat](chat.md)
- [Classifieds ads](classifieds-ads.md)
- [Distributed rate limiter](rate-limiter.md)
- [Favorites](favorites.md)
- [Feed](feed.md)
- [File storage](file-storage.md)
- [Notification service](notification-service.md)
- [Search autocomplete](search-autocomplete.md)
- [URL shortener](url-shortener.md)
- [View counter](view-counter.md)

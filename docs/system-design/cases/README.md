---
title: System Design cases
description: Разборы проектирования с альтернативами и trade-offs.
tags: [system-design, cases]
updated: 2026-09-10
---

# System Design cases

Cases применяют [общий процесс](../system-design-process.md), но не выдают одну архитектуру за универсальную. Для каждого сначала уточните scale, SLO, consistency и abuse model: другой ответ меняет storage и topology.

Начните с небольших stateful services — URL shortener, rate limiter, favorites, view counter. Затем переходите к notification, chat, feed, file storage, autocomplete и classifieds, где появляются несколько data models и asynchronous pipelines.

Полезное упражнение: до чтения решения выпишите API, source of truth, read/write path и три failure scenarios; затем сравните trade-offs.

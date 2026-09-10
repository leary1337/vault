---
title: Modular monolith
description: Bounded modules в одном deployable и путь к контролируемой extraction.
tags: [architecture, modular-monolith]
updated: 2026-09-10
---

# Modular monolith

Modular monolith — один deployable/process с явными bounded modules. Он сохраняет простоту локальных calls и transactions, но ограничивает compile-time/data coupling.

## Правила модуля

- public API/capabilities отделены от internal packages;
- module владеет своей schema/tables и migrations;
- другой module не читает его таблицы напрямую;
- synchronous calls идут через public interface, asynchronous — через typed events;
- dependency graph направлен и проверяется tooling/tests;
- composition root связывает modules, не business packages.

Physical database может быть общей, но ownership логический. Cross-module transaction допустима как осознанный monolith benefit, однако она усложняет будущую extraction; отмечайте такие invariants явно.

## Events внутри процесса

In-process event не durable: process crash теряет queued work. Если результат обязан пережить commit/restart, используйте transactional outbox даже внутри monolith. Не притворяйтесь, что локальный event bus уже обеспечивает Kafka semantics.

## Trade-offs

Плюсы: один deployment, простая локальная диагностика, низкая latency, refactoring через compiler. Риски: границы легко обходить, релизы связаны, один crash/resource leak влияет на process, масштабирование крупнозернистое.

Extraction успешна, когда module уже имеет contract, data ownership и telemetry. Сначала перенесите read/write ownership и сделайте network failure явным, затем отделяйте deployment; dual write без протокола reconciliation опасен.

Для малого продукта обычный хорошо структурированный monolith достаточен. Modular constraints окупаются при нескольких capabilities/teams или вероятной независимой эволюции.


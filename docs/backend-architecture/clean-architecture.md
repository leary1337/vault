---
title: Clean Architecture
description: Dependency Rule, use cases, entities и interface adapters без догматизма.
tags: [architecture, clean-architecture]
updated: 2026-09-10
---

# Clean Architecture

Clean Architecture организует policy концентрическими границами: enterprise/domain rules внутри, application use cases вокруг, interface adapters и frameworks снаружи. Dependency Rule: source-code dependencies направлены внутрь, к более устойчивой policy.

## Что это означает

- domain types не импортируют web framework или SQL driver;
- use case определяет необходимый outbound contract;
- controller/presenter переводит внешний protocol;
- composition root создаёт concrete adapters и связывает graph.

Направление runtime call может идти наружу через interface; направление compile-time dependency остаётся внутрь. Это тот же основной механизм, что в hexagonal architecture, с другой терминологией и акцентом.

## Не путать с числом папок

Четыре каталога не делают систему clean. Boundary оправдан, если стороны имеют разные причины изменения и contract можно сформулировать. Если entity — копия database row, use case только вызывает repository, а mapper механически дублирует 40 полей, структура не снижает coupling.

## Trade-offs

Изоляция policy облегчает unit tests и замену infrastructure, но увеличивает mapping/wiring и может скрыть performance-critical возможности storage. Иногда application query сознательно использует read model/SQL projection в обход богатого domain model — это допустимая оптимизация с явной границей.

Используйте Dependency Rule для сложных или долгоживущих business rules. Не превращайте архитектурную схему в запрет использовать возможности platform там, где они составляют сам продукт.

## Источник

- [Clean Coder Blog: The Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)


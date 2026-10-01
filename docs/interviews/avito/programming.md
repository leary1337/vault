---
title: Programming interview
description: Подготовка к алгоритмической секции через решение, проверку и коммуникацию.
tags: [interviews, avito, algorithms]
updated: 2026-09-10
---

# Programming interview

Публичный отчёт AvitoTech 2025 описывает секцию как проверку написания кода, алгоритмизации и понимания сложности. Статья AvitoTech об алгоритмических интервью подчёркивает объяснение решения; конкретные задачи и duration могут меняться.

## Workflow решения

1. Переформулировать input/output, constraints и edge cases.
2. Показать простой baseline и его complexity.
3. Выбрать pattern по constraint, объяснить invariant.
4. Написать компилируемый код небольшими шагами.
5. Пройти normal, boundary и adversarial examples вручную.
6. Назвать time/space complexity и limitations.

## См. также

- [Сложность алгоритмов](../../algorithms/complexity.md)
- [Алгоритмы и структуры данных](../../algorithms/README.md)
- [Примеры на Go](../../algorithms/go-examples.md)

Компиляция и тесты проверяют корректность решения; для concurrent-кода полезен race detector.

Оцените не число решённых задач, а долю, где вы сформулировали invariant, нашли counterexample и написали корректную границу. Молчаливый идеальный код слабее проверяемого reasoning.

## Источник

- [AvitoTech: алгоритмические секции](https://habr.com/ru/companies/avito/articles/662922/)


---
title: Consistency в System Design
description: Выбор модели по invariant и границе операции.
tags: [system-design, consistency]
updated: 2026-10-06
---

# Consistency в System Design

Гарантия согласованности описывает, какие версии данных допустимо показать после записи.

Не выбирайте между «strong» и «eventual» для всей системы. Укажите operation/data scope и observable guarantee.

## От invariant к модели

- списание денег/unique username: serializable/linearizable coordination или single authoritative (владеющий достоверным состоянием) transaction;
- profile после собственного update: read-your-writes/session routing;
- feed/search index: bounded/eventual staleness с visible timestamp;
- counter analytics: commutative aggregation и approximate result;
- configuration/leader: consensus-backed linearizable state.

Consistency (согласованность наблюдаемых значений и порядка), isolation и durability (сохранность подтверждённых данных при заявленных отказах) различаются. Serializable transaction может быть потеряна при слабой durability; replicated linearizable key не делает multi-key transaction atomic.

## Вопросы при проектировании

- Что видит client после successful write и после timeout?
- Можно ли читать replica/cache; как передаётся minimum version?
- Как concurrent writes conflict-уют и кто merge-ит?
- Что происходит при partition (раздел журнала или данных; при network partition — разрыв связи): reject или stale/ divergent response?
- Как derived views repair/rebuild-ятся?

Укажите latency/availability trade-off и degraded mode. «Eventually» дополните maximum acceptable lag, monitoring и recovery; иначе это отсутствие контракта. Подробнее: [consistency models](../../distributed-systems/consistency-models.md) и [CAP/PACELC](../../distributed-systems/cap-and-pacelc.md).

## На конкретном примере

В карточке продавец должен увидеть свой новый title сразу, а публичный поиск может отстать на 5 s по SLO (цель качества сервиса за заданное окно). Ответ обновления содержит v12; карточка читает primary или replica (копия данных на другом узле) с applied version>=12. Поиск имеет метрику возраста публикации, но eventual сам по себе не доказывает границу 5 s.

Для снятия запрещённого объявления допустимость старого поискового сниппета и фото обсуждаем отдельно от карточки. Проверка карточки защищает переход к объекту, но не удаляет текст из уже полученной выдачи.

## Источник механизма

[Herlihy/Wing: Linearizability](https://cs.brown.edu/~mph/HerlihyW90/p463-herlihy.pdf). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Можно ли выбрать eventual для всей системы?
2. Почему версия в ответе полезна?

<details>
<summary>Ориентиры для ответа</summary>

1. Нужно задавать гарантию каждой операции и данных.
2. Она позволяет последующему read требовать как минимум свою запись.

</details>

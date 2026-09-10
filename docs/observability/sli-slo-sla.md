---
title: SLI, SLO и SLA
description: User-centric reliability indicators, objectives, error budgets и burn rate.
tags: [observability, sre, slo]
updated: 2026-09-10
---

# SLI, SLO и SLA

SLI — измеренный показатель поведения сервиса. SLO — целевой диапазон SLI за окно. SLA — внешнее соглашение с последствиями нарушения; оно обычно слабее внутреннего SLO и включает юридические/коммерческие условия.

## Выбор SLI

Считайте good events / valid events максимально близко к пользовательскому результату:

- availability: доля корректно завершённых valid requests;
- latency: доля valid requests быстрее порога, например 300 ms;
- freshness: доля данных не старше допустимого возраста;
- correctness/durability: доля операций с подтверждённым контрактом.

Не объявляйте все `5xx` автоматически ошибкой SLI и все `4xx` успехом: классификация следует API contract. Исключения из denominator должны быть явными и редкими. Средняя latency скрывает хвост; threshold ratio обычно проще связать с обещанием, чем percentile alone.

## Error budget

Для SLO `99.9%` допустимая bad-event ratio равна `0.1%` за окно. Error budget — разрешённое количество/доля плохих событий, а не план вызвать ошибки. Он связывает product velocity и reliability: при быстром расходе ограничивают рискованные изменения и инвестируют в причины деградации.

Burn rate показывает скорость расходования budget относительно равномерной:

```text
burn_rate = observed_bad_ratio / (1 - SLO)
```

При SLO 99.9% bad ratio 1% даёт burn rate 10. Постоянный rate 10 исчерпает 30-дневный budget примерно за 3 дня.

## Окна и составные системы

Rolling window быстрее отражает текущее состояние, calendar window удобен для договорного периода. Запишите timezone, late data и reset semantics. Availability последовательных обязательных зависимостей перемножается только при независимых вероятностях; реальные failures коррелируют, поэтому измерение end-to-end важнее арифметической оценки.

Один сервис может иметь разные SLO для чтения, записи и критического checkout. Не усредняйте разные user journeys так, чтобы высокий volume дешёвого endpoint скрывал outage важного.

## Жизненный цикл

1. Определить пользователей и critical journeys.
2. Зафиксировать valid/good events и источник данных.
3. Выбрать достижимую цель и окно по историческим данным.
4. Реализовать recording rules, dashboard и burn alerts.
5. Проверить SLI на известных incidents и gaps telemetry.
6. Пересматривать цель при изменении продукта, а не после каждого нарушения.

## Источники

- [Google SRE Workbook: implementing SLOs](https://sre.google/workbook/implementing-slos/)
- [Google SRE: service level objectives](https://sre.google/sre-book/service-level-objectives/)


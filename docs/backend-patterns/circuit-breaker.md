---
title: Circuit breaker
description: Быстрый отказ при устойчивой неисправности dependency.
tags: [backend, patterns, reliability]
updated: 2026-10-06
---

# Circuit breaker


Circuit breaker — автоматический предохранитель: перестаём вызывать устойчиво неисправный сервис и периодически проверяем восстановление.

## Проблема

Продолжение вызовов failing/slow dependency тратит threads, connections и deadline (крайний срок завершения), вызывая cascading failure.

## Как работает

Closed пропускает calls и считает outcomes в rolling window. При достаточном sample и превышении threshold переходит Open и fail-fast. После cooldown Half-open пропускает ограниченные probes; успех закрывает breaker, failure снова открывает.

## Гарантии и границы

Breaker ограничивает часть бесполезных calls и ускоряет failure response. Он не восстанавливает dependency и не гарантирует снижение нагрузки, если instances независимо отправляют слишком много probes.

## Ошибки и отказы

- низкий traffic даёт шумный процент ошибок;
- один breaker смешивает разные endpoints/tenants и блокирует здоровые paths;
- slow calls не считаются failures;
- fallback возвращает опасно stale/default data;
- Open скрывает recovery из-за отсутствия корректных probes.

## Компромиссы

Threshold, window, minimum sample, slow-call duration и cooldown требуют tuning. Per-instance breaker прост и отказоустойчив, но не имеет глобального view; central breaker добавляет собственную dependency.

## Когда не применять

Для local deterministic validation и calls, уже защищённых строгим concurrency limit/short timeout, breaker может не дать пользы. Не ставьте его вокруг memory/CPU code path без внешнего failure mode.

## Пример

Разделите breakers по dependency operation class, ограничьте half-open probes и публикуйте state transitions, rejected calls, latency (срок ответа) и outcome reason. Сочетайте с [bulkhead](bulkhead.md), bounded (с явным конечным пределом) retries и полезным fallback, если он действительно существует.

## Разобранный пример

Учебная настройка: окно 30 s, минимум 50 вызовов, открытие при 50% ошибок, пауза 10 s, два проверочных вызова. Это допущения, не универсальные defaults. При десяти вызовах одна ошибка не открывает предохранитель; при 100 репликах по две проверки downstream увидит 200 probes. Поэтому добавляем разброс времени и ограничение общей нагрузки.

Ошибка проверки тела запроса не означает отказ поставщика. Timeout и слишком медленный успешный вызов могут означать проблему capacity. Метрика должна различать причину. Запасной ответ «баланс 0» опаснее явного отказа; допустимость fallback определяется смыслом операции.

## Источник механизма

[Google SRE: защита от каскадных отказов](https://sre.google/sre-book/addressing-cascading-failures/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Зачем minimum sample?
2. Что защищает от медленного здорового по статусу сервиса?

<details>
<summary>Ориентиры для ответа</summary>

1. Один сбой при малом трафике даёт шумный процент.
2. Deadline, concurrency limit и учёт слишком медленных вызовов, а не только HTTP 500.

</details>

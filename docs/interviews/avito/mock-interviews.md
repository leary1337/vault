---
title: Mock interviews
description: Сценарии репетиций screening, programming, platform, system design и final.
tags: [interviews, avito, practice]
updated: 2026-09-10
---

# Mock interviews

Mocks повторяют тип навыка из публично описанных секций, но не реальные закрытые вопросы Avito. Записывайте время, assumptions и rubric; после session сначала делает self-review кандидат, затем interviewer даёт evidence-based feedback.

## Mock 1 — foundation

20 вопросов × 90 секунд: Go interface/typed nil, slice aliasing, happens-before, MVCC/isolation/index, TCP/TLS/HTTP, consistency/idempotency/retry. Rubric: точность, mechanism, граница гарантии, пример.

## Mock 2 — programming

60 минут: одна medium задача (sliding window/heap/graph) и follow-up на constraints. Оцените clarification, baseline, invariant, correctness, edge tests, complexity и коммуникацию. Компиляция после интервью обязательна для проверки feedback.

## Mock 3 — platform

45–60 минут: review Go HTTP handler с unbounded body, потерянным cancellation, shared map race, response body leak и неверным retry. Кандидат должен найти не все «запахи», а самые рискованные, объяснить runtime/production impact и предложить test/diagnostic.

## Mock 4 — system design

60 минут: notification service, favorites или view counter. 10 минут requirements/estimates, 20 минут high-level/data flow, 25 минут два deep dives, 5 минут risks/evolution. Rubric: решения связаны с requirements, consistency/failure/user state ясны, observability/security встроены.

## Mock 5 — final

45 минут: incident, disagreement, failed decision, initiative, growth goal и вопросы команде. Уточняющий interviewer просит личный вклад, metric/outcome, альтернативу и learning. Не репетируйте текст дословно — подготовьте facts и causal chain.

## Feedback template

- сильное действие + observable evidence;
- главный риск/gap + момент интервью;
- как выглядел бы ответ следующего уровня;
- 1–3 ссылки из [skill matrix](skill-matrix.md);
- конкретное упражнение и дата повторного mock.


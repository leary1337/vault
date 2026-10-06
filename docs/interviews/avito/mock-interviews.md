---
title: Mock interviews
description: Сценарии репетиций screening, programming, platform, system design и final.
tags: [interviews, avito, practice]
updated: 2026-10-06
---

# Mock interviews

Репетиция — способ увидеть, где объяснение ломается на уточнении. Приведённые форматы самостоятельные; они не фиксируют точное расписание реального интервью.

Mocks повторяют тип навыка из публично описанных секций, но не реальные закрытые вопросы Avito. Записывайте время, assumptions и rubric; после session сначала делает self-review кандидат, затем interviewer даёт evidence-based feedback.

## Формат: foundation

20 вопросов × 90 секунд: Go interface/typed nil, slice aliasing, happens-before, MVCC/isolation/index, TCP/TLS/HTTP, consistency/idempotency/retry. Rubric: точность, mechanism, граница гарантии, пример.

## Формат: programming

60 минут: одна medium задача (sliding window/heap/graph) и follow-up на constraints. Оцените clarification, baseline, invariant, correctness, edge tests, complexity и коммуникацию. Компиляция после интервью обязательна для проверки feedback.

## Формат: platform

45–60 минут: review Go HTTP handler с unbounded body, потерянным cancellation, shared map race, response body leak и неверным retry. Кандидат должен найти не все «запахи», а самые рискованные, объяснить runtime/production impact и предложить test/diagnostic.

## Формат: system design

60 минут: notification service, favorites или view counter. 10 минут requirements/estimates, 20 минут high-level/data flow, 25 минут два deep dives, 5 минут risks/evolution. Rubric: решения связаны с requirements, consistency/failure/user state ясны, observability/security встроены.

## Формат: final

45 минут: incident, disagreement, failed decision, initiative, growth goal и вопросы команде. Уточняющий interviewer просит личный вклад, metric/outcome, альтернативу и learning. Не репетируйте текст дословно — подготовьте facts и causal chain.

## Feedback template

- сильное действие + observable evidence;
- главный риск/gap + момент интервью;
- как выглядел бы ответ следующего уровня;
- 1–3 ссылки из [skill matrix](skill-matrix.md);
- конкретное утверждение, которое стоит перепроверить по источнику.


## Готовый пример короткой репетиции

Вопрос: «Kafka consumer записал платёж в БД и упал до offset commit. Что произойдёт?» Хороший ответ: запись повторится; inbox marker и бизнес-изменение должны быть в одной transaction; offset после commit БД. Уточнения: marker удалили раньше replay, event_id меняется при retry, внешнее HTTP списание не входит в transaction. Проверяется граница атомарности, а не знание слова exactly-once.

Вопрос: «Два врача прочли, что дежурных двое, и сняли каждый себя». Кандидат рисует две транзакции, объясняет write skew Repeatable Read, предлагает Serializable с full retry либо общую строку lock. Уточнение «FOR UPDATE только своей строки» должно выявить, что инвариант между строками не защищён.

После ответа зафиксируйте фактическую ошибку: «сказал, что Repeatable Read исключает все аномалии», а не «плохо знаю БД». Следующее уточнение просит контрпример и новую формулировку. Для code session запустите тесты после объяснения, включая empty/duplicates/cancellation. Результат mock — наблюдаемая обратная связь, а не обещание grade.

## Проверь себя

1. **Как отличить полезный feedback от общей оценки?**

   <details>
   <summary>Ответ</summary>

   В нём есть конкретный ответ/момент, ошибка механизма и проверяемое исправление.

   </details>

2. **Нужно запоминать ответы mock дословно?**

   <details>
   <summary>Ответ</summary>

   Нет, переносить механизм и границы на изменённый сценарий.

   </details>

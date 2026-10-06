---
title: Singleflight
description: Объединение конкурентных одинаковых запросов.
tags: [backend, patterns, caching]
updated: 2026-10-06
---

# Singleflight


Singleflight объединяет одновременные одинаковые загрузки; результат после завершения сам по себе не хранит.

## Проблема

При cache miss или дорогом lookup много concurrent requests одного key одновременно выполняют одинаковую работу и создают stampede (множество одинаковых одновременных загрузок).

## Как работает

Первый caller становится leader (узел, координирующий запись) для key, остальные ждут тот же in-flight result. После завершения entry удаляется; это request coalescing, а не cache. В Go пакет `golang.org/x/sync/singleflight` предоставляет `Group.Do/DoChan`.

## Гарантии и границы

В пределах одного `Group` одновременно выполняется обычно одна function на key, а waiters разделяют result/error. Последующие вызовы после завершения снова выполняют function, если нет cache.

## Ошибки и отказы

- слишком грубый key объединяет разные auth/options;
- leader завис, и все waiters исчерпали deadlines;
- cancellation одного caller неправильно отменяет общую полезную работу;
- shared transient (временный, потенциально устранимый повтором) error возвращается всей волне;
- process-local group не объединяет replicas;
- result слишком велик или mutable и небезопасно разделяется.

## Компромиссы

Снижает duplicate load, но связывает latency (срок ответа) waiters с leader. Distributed coalescing требует lease/coordination и сложнее; часто достаточно local singleflight плюс TTL (время жизни записи) jitter/soft cache.

## Когда не применять

Не объединяйте operations с caller-specific side effects, credentials или non-identical consistency (согласованность наблюдаемых значений и порядка) requirements. Для дешёвого lookup synchronization overhead может быть лишним.

## Пример

Key включает tenant, resource ID и data version. Каждый waiter имеет собственный deadline (крайний срок завершения); shared loader имеет bounded (с явным конечным пределом) lifetime, результат кладётся в cache, затем все получают immutable copy.

## Источники

- [Go singleflight package](https://pkg.go.dev/golang.org/x/sync/singleflight)

## Разобранный пример

`Do` ждёт общий результат и не принимает context. `DoChan` даёт канал, на который caller может ждать через `select` вместе со своим deadline; канал результата не закрывается. Отмена ожидания не отменяет автоматически общую функцию. У loader должен быть собственный ограниченный срок, который не зависит от случайного первого клиента.

`Forget(key)` позволяет новой загрузке начаться, пока старая ещё выполняется: абсолютная гарантия «ровно одна функция в любой момент» после Forget неверна. Key включает права/tenant и параметры запроса. Указатель на изменяемый slice/map, отданный всем ожидающим, требует копирования либо строгого правила неизменности. [API singleflight](https://pkg.go.dev/golang.org/x/sync/singleflight).

## Проверь себя

1. Является ли singleflight кэшем?
2. Что делает отмена caller через DoChan?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, следующий вызов после завершения снова запускает loader.
2. Прекращает его ожидание; общий loader продолжает по своему контракту.

</details>

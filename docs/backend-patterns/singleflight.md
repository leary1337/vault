---
title: Singleflight
description: Объединение конкурентных одинаковых запросов.
tags: [backend, patterns, caching]
updated: 2026-09-10
---

# Singleflight

## Problem

При cache miss или дорогом lookup много concurrent requests одного key одновременно выполняют одинаковую работу и создают stampede.

## Mechanism

Первый caller становится leader для key, остальные ждут тот же in-flight result. После завершения entry удаляется; это request coalescing, а не cache. В Go пакет `golang.org/x/sync/singleflight` предоставляет `Group.Do/DoChan`.

## Guarantees

В пределах одного `Group` одновременно выполняется обычно одна function на key, а waiters разделяют result/error. Последующие вызовы после завершения снова выполняют function, если нет cache.

## Failure modes

- слишком грубый key объединяет разные auth/options;
- leader завис, и все waiters исчерпали deadlines;
- cancellation одного caller неправильно отменяет общую полезную работу;
- shared transient error возвращается всей волне;
- process-local group не объединяет replicas;
- result слишком велик или mutable и небезопасно разделяется.

## Trade-offs

Снижает duplicate load, но связывает latency waiters с leader. Distributed coalescing требует lease/coordination и сложнее; часто достаточно local singleflight плюс TTL jitter/soft cache.

## When not to use

Не объединяйте operations с caller-specific side effects, credentials или non-identical consistency requirements. Для дешёвого lookup synchronization overhead может быть лишним.

## Example

Key включает tenant, resource ID и data version. Каждый waiter имеет собственный deadline; shared loader имеет bounded lifetime, результат кладётся в cache, затем все получают immutable copy.

## Источники

- [Go singleflight package](https://pkg.go.dev/golang.org/x/sync/singleflight)

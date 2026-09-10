---
title: Secrets management
description: Secret lifecycle, delivery, rotation, least privilege и incident response.
tags: [security, secrets, operations]
updated: 2026-09-10
---

# Secrets management

Secret — credential или cryptographic material, раскрытие которого даёт доступ: password, API key, private key, token, database credential. Его жизненный цикл важнее места хранения.

## Lifecycle

1. Генерировать cryptographically random с owner/purpose/expiry.
2. Хранить encrypted с access policy и audit.
3. Доставлять только workload identity, которому secret нужен.
4. Использовать без записи в logs, command line, crash dump или metrics.
5. Rotating без downtime через overlap/versioning.
6. Отзывать и удалять по policy; репетировать compromise response.

Не храните secrets в Git, container image, sample config или frontend bundle. Environment variables удобны, но могут попадать в process inspection, diagnostics и child processes; mounted file/agent/API имеют другие риски. Выбирайте delivery по platform threat model.

## Least privilege

Разные environments/services получают разные credentials; read и write scopes разделяют. Предпочитайте short-lived dynamic credentials/workload identity статическим ключам. Secret manager administrator не должен автоматически быть application/data administrator.

Application читает secret при startup или обновляет контролируемо. Не делайте request к secret manager на каждый business request без cache/failure design. Rotation включает dual-valid period, reload/reconnect, verification и отзыв старого значения.

## Утечка

Если secret попал в commit/log/chat, удаление строки недостаточно: считайте его раскрытым, отзовите/rotate, найдите access и downstream impact, очистите доступные копии согласно retention. Переписывание Git history — отдельная операция и не отменяет уже сделанные clones.

## Источники

- [OWASP Secrets Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [Kubernetes Secrets good practices](https://kubernetes.io/docs/concepts/security/secrets-good-practices/)


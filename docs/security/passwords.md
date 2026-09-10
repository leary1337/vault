---
title: Passwords
description: Password hashing, salts, peppers, policy, verification и migration.
tags: [security, passwords, cryptography]
updated: 2026-09-10
---

# Passwords

Пароль не шифруют для обратного получения и не хэшируют быстрым general-purpose hash. Хранят результат password hashing function с уникальной random salt и параметрами работы.

## Алгоритм

OWASP рекомендует Argon2id; текущий минимум cheat sheet — 19 MiB memory, 2 iterations, parallelism 1, но production параметры выбирают benchmark-ом под latency/capacity и пересматривают. Если Argon2id недоступен, следуйте актуальной рекомендации для scrypt; bcrypt — legacy fallback с work factor и лимитом входа.

Salt обычно генерирует library и хранится рядом с hash. Pepper — optional secret отдельно от database (vault/HSM); его компрометация требует rotation, часто с повторной верификацией пароля. Не изобретайте собственную схему.

## Policy

- разрешайте длинные passphrases и password managers;
- проверяйте новый пароль по спискам известных утечек;
- не навязывайте периодическую смену без compromise signal;
- не используйте composition rules как замену длине;
- ограничьте максимальную длину разумно против resource exhaustion, не молча truncate;
- MFA/passkeys снижают риск password reuse/phishing.

## Verification и migration

Сравнение выполняет library constant-time primitives. Generic response не раскрывает наличие account. Rate limiting не должен позволять легко заблокировать жертву.

Hash record хранит algorithm/version/parameters. После успешного login сравните параметры с current policy и rehash. При смене алгоритма поддерживайте проверку старого формата только на migration window. Password reset token должен быть random, single-use, short-lived и храниться в hashed form; recovery события отзывают нужные sessions/tokens.

## Источники

- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [NIST SP 800-63B: Authentication and authenticator management](https://pages.nist.gov/800-63-4/sp800-63b.html)


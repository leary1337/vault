---
title: Passwords
description: Password hashing, salts, peppers, policy, verification и migration.
tags: [security, passwords, cryptography]
updated: 2026-10-06
---

# Passwords

Хеширование пароля намеренно дорогое: оно замедляет перебор после утечки БД. Salt делает результат разным для одинаковых паролей; pepper — отдельный секрет, а не замена salt.

## Термины в этой статье

- **salt** — случайные несекретные данные, добавляемые к каждому паролю перед вычислением его хеша.
- **rotation** — замена ключа или секрета с прекращением использования предыдущего.
- **rehash** — повторное вычисление хеша с новыми параметрами после успешной проверки пароля.
- **credential** — предъявляемое доказательство личности: пароль, ключ, токен или сертификат.

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

## Разбор на примере

Два пользователя выбрали одинаковый пароль. С разными random salt их records должны отличаться. Запись хранит алгоритм, параметры, salt и hash, чтобы проверять старые версии и обновлять после успешного login. Не храните исходный пароль ради будущего rehash.

Если выбранный Argon2id расходует 64 MiB на активную проверку, 100 одновременных login требуют порядка 6.25 GiB только этой памяти. Это учебный capacity расчёт, не рекомендация конкретных параметров. Дорогую верификацию нужно ограничивать по concurrency/rate до исчерпания RAM, сохраняя выбранную безопасность. Минимум OWASP 19 MiB/2/1 — нижняя рекомендация, не универсальная production настройка.

После успешной проверки старого hash библиотека сравнивает параметры с текущей policy и записывает новый hash. Race с password reset нужно учитывать: условный update по старой версии не должен возвращать старый пароль в актуальное состояние.

Для bcrypt legacy учитывайте ограничение входа 72 байта и особенности выбранной библиотеки; 72 Unicode-символа могут занимать больше байтов. Не вводите молчаливую обрезку. Recovery token — отдельный random single-use credential, защищённый в хранилище; его утечка обходит сильный password hash.

## Источники

- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [NIST SP 800-63B: Authentication and authenticator management](https://pages.nist.gov/800-63-4/sp800-63b.html)


## Проверь себя

1. Почему salt не обязан быть секретным?
2. Почему более дорогой hash требует admission control?

<details>
<summary>Ответы</summary>

1. Его задача — исключить одинаковые hashes и массовую предварительную подготовку; секретность обеспечивает пароль, при необходимости отдельно pepper.

2. Каждая проверка потребляет CPU/RAM; неограниченный параллелизм превращает login в DoS-вектор.

</details>

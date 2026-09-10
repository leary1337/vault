---
title: Backend security controls
description: CORS, CSRF, SSRF, injection, path traversal и abuse/resource controls.
tags: [security, owasp, backend]
updated: 2026-09-10
---

# Backend security controls

Input validation уточняет business contract, но основная защита часто должна быть structural: parameterized query вместо escaping SQL, argument API вместо shell, allowlisted destination вместо blacklist URL.

## CORS и CSRF

CORS — browser policy чтения cross-origin responses, не authentication и не firewall: non-browser client её игнорирует. Allowlist точных trusted origins, методов и headers; credentialed requests несовместимы с wildcard origin. Проверяйте origin parser и cache variation.

CSRF использует automatic credentials browser-а для нежелательного state change. Защищайте cookie-authenticated mutations `SameSite`, synchronizer/double-submit token или проверкой `Origin`/Fetch Metadata по выбранной модели. `GET` не должен менять state. XSS может обходить многие CSRF defenses, поэтому обе угрозы независимы.

## SSRF

Server-side fetcher может достичь metadata, localhost и internal control plane. Разбирайте URL стандартным parser, разрешайте только нужные schemes/hosts/ports, resolve DNS и проверяйте все полученные IP ranges, контролируйте redirects и повторную resolution. Блокируйте loopback, link-local, private/internal ranges по назначению; применяйте egress network policy и отдельную identity. Blacklist строк и один preflight DNS lookup уязвимы к encoding/rebinding/redirect.

## Injection

- SQL: parameterized queries/prepared statements; allowlist для identifiers/order, которые нельзя bind; DB least privilege.
- Command: не запускать shell; использовать direct process API с отдельными args и allowlist. Если shell неизбежен, redesign и sandbox важнее escaping.
- Templates/headers/logs: использовать context-aware encoding и библиотеки, не конкатенацию.

## Path traversal и uploads

Не соединяйте user path с root и не полагайтесь только на удаление `../`. Лучше отображать opaque ID на server-owned path. Если path необходим: normalize, resolve symlinks с учётом race, затем доказать принадлежность разрешённому root; используйте OS primitives вроде directory-relative open там, где доступны.

Upload получает random server filename, allowlisted type/size, content validation, isolated storage без execute permission и malware/archive-bomb controls. Original filename — metadata, не filesystem path.

## Abuse и exceptional conditions

Ограничивайте body, decompression ratio, batch/page, recursion, regex complexity, concurrency и expensive endpoints. Rate limit — defense-in-depth, не замена authorization; распределённый limiter должен иметь явную fail-open/fail-closed policy. Timeouts, load shedding и bounded queues защищают availability.

Ошибки наружу имеют стабильный code без stack/SQL/internal path; внутри — correlation и audit без secrets. Failures validation, parsing и cleanup тестируются fuzz/property/integration tests.

## Источники

- [OWASP SSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html)
- [OWASP SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
- [OWASP OS Command Injection Defense Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html)
- [OWASP Path Traversal](https://owasp.org/www-community/attacks/Path_Traversal)
- [OWASP CSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [Fetch Standard: CORS protocol](https://fetch.spec.whatwg.org/#http-cors-protocol)


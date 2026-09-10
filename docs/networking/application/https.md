---
title: HTTPS
description: HTTP over TLS, origin authentication, termination и browser security boundaries.
tags: [networking, https, security]
updated: 2026-09-10
---

# HTTPS

HTTPS — HTTP semantics поверх TLS-secured connection. URL scheme `https` определяет secure origin и default port 443; negotiated wire protocol может быть HTTP/1.1, HTTP/2 или HTTP/3.

## Что защищено

При корректной validation TLS защищает HTTP content от чтения/изменения на пути и аутентифицирует server identity по certificate. Он не скрывает все metadata, не защищает compromised endpoint и не заменяет authentication/authorization/input validation.

Для HTTP/1.1/2 обычно выполняются DNS → TCP → TLS → HTTP. HTTP/3 использует QUIC+TLS поверх UDP. Reuse/resumption уменьшает setup cost; измеряйте cold/reconnect path отдельно.

## Termination

TLS может завершаться на edge/load balancer. Тогда proxy видит plaintext и становится trust boundary; hop до backend защищают согласно threat model (TLS/mTLS/network isolation). Forwarded scheme/client-IP headers edge очищает, backend доверяет только известному proxy.

Reverse proxy может использовать другую HTTP version к upstream, поэтому client-side HTTP/3 не означает HTTP/3 во всём path. Certificate/SNI относятся к каждому TLS hop отдельно.

## Browser controls

HSTS заставляет browser использовать HTTPS для host после получения policy; `includeSubDomains`/preload требуют готовности всех names. Secure cookie ограничивает отправку HTTPS, HttpOnly закрывает JavaScript access, SameSite влияет на cross-site sending — ни один attribute не заменяет остальные controls.

Mixed content и insecure redirects снижают protection. Secrets/tokens не помещают в URL даже под HTTPS: URL остаётся в application/proxy logs, history и analytics.

## Источники

- [HTTP Semantics, RFC 9110](https://www.rfc-editor.org/rfc/rfc9110)
- [HSTS, RFC 6797](https://www.rfc-editor.org/rfc/rfc6797)
- [TLS](tls.md)

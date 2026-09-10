---
title: HTTP/1.1
description: HTTP semantics, message framing, persistent connections и interoperability risks.
tags: [networking, http]
updated: 2026-09-10
---

# HTTP/1.1

HTTP — stateless application protocol с едиными semantics методов, status codes, fields и representations. HTTP/1.1 (RFC 9112) задаёт текстовый wire format поверх reliable in-order transport, обычно TCP; semantics находятся в RFC 9110.

## Request и response

Request содержит method, target, protocol version, fields и optional content. Response — status, fields и optional content. Method semantics (`safe`, `idempotent`, cacheable) важнее CRUD-аналогии: retry определяется тем, мог ли повтор изменить эффект, а не только названием метода.

Message length задают framing rules: отсутствие корректного `Content-Length`/`Transfer-Encoding`, неоднозначность между intermediaries и некорректный parser могут привести к request smuggling. Не принимайте оба варианта произвольно; используйте обновлённый server/proxy stack и одинаковую normalization policy.

## Connections

HTTP/1.1 использует persistent connections по умолчанию. Без multiplexing один активный exchange занимает connection; pipelining требует ordered responses и почти не применяется. Pools открывают несколько connections, но должны ограничивать churn, idle/lifetime и total concurrency.

Чтение/закрытие body влияет на reuse. Server устанавливает header/body/idle limits и deadlines, а client — общий request context плюс transport timeouts. Timeout не доказывает, был ли mutation применён, поэтому нужны idempotency semantics.

## Intermediaries

Proxy может менять hop-by-hop fields и использовать другую HTTP version на следующем hop. `Host`/authority определяет target virtual host. Forwarding fields недоверенны до очистки trusted edge. Caching, conditional requests и range имеют отдельные contracts — не добавляйте их без validators/invalidation.

## Источники

- [HTTP Semantics, RFC 9110](https://www.rfc-editor.org/rfc/rfc9110)
- [HTTP/1.1, RFC 9112](https://www.rfc-editor.org/rfc/rfc9112)

---
title: HTTP/1.1
description: HTTP semantics, message framing, persistent connections и interoperability risks.
tags: [networking, http]
updated: 2026-10-06
---

# HTTP/1.1

HTTP задаёт смысл запросов и ответов. HTTP/1.1 передаёт их текстовыми заголовками и телом по соединению. Чтобы две стороны одинаково поняли границы тела, они должны одинаково применять правила framing.

## Термины в этой статье

- **multiplexing** — передача нескольких логических потоков по одному соединению.
- **proxy** — посредник, который принимает соединение или запрос и передаёт его дальше.

HTTP — stateless application protocol с едиными semantics методов, status codes, fields и representations. HTTP/1.1 (RFC 9112) задаёт текстовый wire format поверх reliable in-order transport, обычно TCP; semantics находятся в RFC 9110.

## Request и response

Request содержит method, target, protocol version, fields и optional content. Response — status, fields и optional content. Method semantics (`safe`, `idempotent`, cacheable) важнее CRUD-аналогии: retry определяется тем, мог ли повтор изменить эффект, а не только названием метода.

Message length задают framing rules: отсутствие корректного `Content-Length`/`Transfer-Encoding`, неоднозначность между intermediaries и некорректный parser могут привести к request smuggling. Не принимайте оба варианта произвольно; используйте обновлённый server/proxy stack и одинаковую normalization policy.

## Connections

HTTP/1.1 использует persistent connections по умолчанию. Без multiplexing один активный exchange занимает connection; pipelining требует ordered responses и почти не применяется. Pools открывают несколько connections, но должны ограничивать churn, idle/lifetime и total concurrency.

Чтение/закрытие body влияет на reuse. Server устанавливает header/body/idle limits и deadlines, а client — общий request context плюс transport timeouts. Timeout не доказывает, был ли mutation применён, поэтому нужны idempotency semantics.

## Intermediaries

Proxy может менять hop-by-hop fields и использовать другую HTTP version на следующем hop. `Host`/authority определяет target virtual host. Forwarding fields недоверенны до очистки trusted edge. Caching, conditional requests и range имеют отдельные contracts — не добавляйте их без validators/invalidation.

## Разбор на примере

```http
GET /ads/42 HTTP/1.1
Host: api.example.test
If-None-Match: "v7"

```

Если представление всё ещё имеет ETag `"v7"`, сервер может ответить `304 Not Modified` без тела представления. Для изменения клиент отправляет `If-Match: "v7"`: если состояние уже `v8`, предусловие не выполнено — `412 Precondition Failed`. Проверка версии и запись должны быть атомарны, например `UPDATE ... WHERE version = 7`; предварительное чтение без защиты оставляет race.

`DELETE` идемпотентен по желаемому эффекту, хотя первый вызов может вернуть 204, второй — 404. `POST` не становится безопасным для повтора от имени метода: нужен отдельный контракт ключа идемпотентности. `PUT` не освобождает от проверки скрытых side effects.

Несогласованный parsing между proxy и сервером создаёт request smuggling: одна сторона считает байты продолжением тела, другая — новым запросом. Не пишите самодельный tolerant parser; проверяйте обновлённые стеки и совместимость всех hops. Заголовки `Connection` и поля, названные в нём, относятся к конкретному hop.

## Источники

- [HTTP Semantics, RFC 9110](https://www.rfc-editor.org/rfc/rfc9110)
- [HTTP/1.1, RFC 9112](https://www.rfc-editor.org/rfc/rfc9112)

## Проверь себя

1. Чем If-None-Match при чтении отличается от If-Match при записи?
2. Должен ли повтор DELETE вернуть тот же status?

<details>
<summary>Ответы</summary>

1. Первое позволяет не передавать неизменённое представление; второе запрещает запись поверх неожиданной версии.

2. Нет. Идемпотентность описывает эффект повторения, а не идентичность ответа.

</details>

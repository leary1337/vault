---
title: HTTP/3
description: HTTP semantics over QUIC, independent streams, QPACK и deployment trade-offs.
tags: [networking, http3, quic]
updated: 2026-10-06
---

# HTTP/3

HTTP/3 сохраняет смысл HTTP, но переносит запросы по QUIC вместо TCP. Независимость потоков помогает при потерях; это изменение транспорта, а не способ ускорить медленную бизнес-логику.

## Термины в этой статье

- **ALPN** — согласование прикладного протокола во время установки защищённого соединения.
- **endpoint** — конкретный адрес службы или сторона соединения.
- **congestion control** — ограничение отправки с учётом перегрузки сети.
- **0-RTT** — передача ранних данных до завершения обычного обмена подтверждениями; возможен повтор данных.
- **RTT** — время прохождения запроса и ответа по сети.
- **replay** — повтор ранее переданного сообщения, который может снова вызвать действие.
- **multiplexing** — передача нескольких логических потоков по одному соединению.

HTTP/3 отображает те же HTTP semantics на QUIC. Connection устанавливается поверх UDP с интегрированным TLS 1.3; ALPN token `h3` подтверждает protocol. Endpoint обычно обнаруживается через Alt-Svc или HTTPS DNS records согласно client support.

## Streams

Каждая request/response pair использует bidirectional QUIC stream; control и QPACK используют специальные unidirectional streams. Loss в одном stream не препятствует delivery других уже полученных streams, хотя congestion control connection-а общий.

QPACK заменяет HPACK, потому что QUIC не даёт общего порядка между streams. Dynamic table references могут блокировать decoding до получения instruction; configuration балансирует compression и blocking risk.

## Establishment и migration

QUIC сокращает transport+crypto setup и поддерживает resumption; 0-RTT replayable и требует replay-safe operations. Connection IDs позволяют переживать некоторые path/address changes, но NAT/firewall/UDP policy и load balancer routing остаются failure modes.

## Operations

Поддерживайте graceful fallback на HTTP/2/1.1, измеряйте discovery, negotiated protocol, handshake/fallback, loss/RTT, stream resets и QPACK/flow-control blocking. Сравнивайте end-to-end latency/CPU и packet loss на реальном traffic; HTTP/3 не лечит slow handler/database.

Подробнее о различиях: [HTTP multiplexing](../backend/http-multiplexing.md) и [QUIC](../transport/quic.md).

## Разбор на примере

У мобильного клиента часть пакетов теряется. HTTP/3 может завершить уже полученный ответ B, пока поток A ждёт недостающий фрагмент. При общей перегрузке канала оба ответа всё равно замедлятся. Если 95% времени занимает запрос БД, смена HTTP-версии почти не меняет эту часть задержки.

В сети компании блокируется UDP/443: HTTP/3 не устанавливается, хотя TCP/443 доступен. Нужны fallback и метрики выбранного протокола; проверка лишь с офисного ноутбука не описывает весь трафик. В эксперименте сравнивают одинаковые ответы, RTT, loss, CPU, холодные/тёплые соединения и долю fallback.

QPACK позволяет сжимать заголовки без глобального порядка потоков. Но ссылка на ещё не полученную dynamic-table запись способна остановить декодирование конкретного блока. Лимит blocked streams — отдельная граница; лозунг «HTTP/3 устраняет любое ожидание» неверен.

## Источники

- [HTTP/3, RFC 9114](https://www.rfc-editor.org/rfc/rfc9114)
- [QPACK, RFC 9204](https://www.rfc-editor.org/rfc/rfc9204)

## Проверь себя

1. Почему HTTP/3 может не работать, когда HTTPS по HTTP/2 работает?
2. Что остаётся общим у QUIC-потоков?

<details>
<summary>Ответы</summary>

1. QUIC требует достижимости UDP, тогда как HTTP/2 обычно идёт по TCP.

2. Ресурсы соединения, congestion control и ресурсы приложения; QPACK также может создать ожидание.

</details>

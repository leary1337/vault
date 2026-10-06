---
title: HTTP/2
description: Binary framing, multiplexed streams, HPACK и flow control поверх TCP.
tags: [networking, http2]
updated: 2026-10-06
---

# HTTP/2

HTTP/2 позволяет нескольким запросам делить соединение: их кадры чередуются, а номер потока связывает кадр с запросом. Под ним остаётся TCP с единым порядком байтов.

## Термины в этой статье

- **ALPN** — согласование прикладного протокола во время установки защищённого соединения.
- **flow control** — управление скоростью отправки, чтобы получатель успевал принимать данные.
- **congestion control** — ограничение отправки с учётом перегрузки сети.
- **multiplexing** — передача нескольких логических потоков по одному соединению.
- **head-of-line** — ожидание последующих данных из-за задержанного предыдущего фрагмента.
- **pool** — набор объектов, например соединений, которые используются повторно.
- **proxy** — посредник, который принимает соединение или запрос и передаёт его дальше.

HTTP/2 сохраняет HTTP semantics, но использует binary frames и multiplexed streams на connection. Для HTTPS protocol обычно выбирается через TLS ALPN `h2`; cleartext deployment имеет отдельные discovery/upgrade constraints.

## Frames и streams

Каждый request/response занимает stream; frames разных streams interleave-ятся. Stream имеет state и identifier. Connection-level frames управляют settings, flow control и shutdown; `GOAWAY` сообщает, какие новые streams peer больше не обработает, что важно для safe retry.

HPACK сжимает fields через static/dynamic tables. Limits на header list/table необходимы против memory/CPU abuse. Binary framing не меняет header/body security semantics.

## Flow control

Receiver выдаёт credit на stream и connection. Если application не читает body или не обновляет windows, sender останавливается. Flow control HTTP/2 не заменяет TCP congestion control и application backpressure.

Multiplexing убирает HTTP/1.1 response-order blocking, но TCP выдаёт единый ordered byte stream: потеря segment задерживает bytes всех HTTP/2 streams. Это transport-level head-of-line blocking.

## Production

Проверяйте max concurrent streams, connection count/age, resets, `GOAWAY`, flow-control stalls, ping/idle policy и graceful drain. Одна connection может стать shared blast radius; client pool иногда использует несколько. Не включайте proxy retries для streamed/non-idempotent request без protocol-aware replay safety.

## Разбор на примере

Запрос A передаёт большой файл, B — маленький JSON. На уровне HTTP/2 B не обязан ждать завершения A. Но потеря TCP-сегмента с ранними байтами останавливает доставку последующих байтов соединения, даже если они принадлежат B.

Есть два уровня окна: поток и соединение. Клиент, который не читает response body, может исчерпать кредит потока и занять общий бюджет соединения. Нужно закрывать ненужный stream и ограничивать потребителей, не просто увеличивать окна. SETTINGS_MAX_CONCURRENT_STREAMS ограничивает число потоков peer, а не число бизнес-задач всего сервиса.

При GOAWAY сервер сообщает last-stream-ID: максимальный номер потока, который он обработал или ещё может обработать. Потоки с большим номером не обрабатываются и могут быть повторены на новом соединении. Для номеров меньше либо равных границе результат без ответа может оставаться неизвестным. Конкретная библиотека классифицирует повтор; для mutation прикладная идемпотентность всё равно нужна. HPACK сжимает заголовки, а не тело; лимиты decoded header list защищают память независимо от размера сжатых bytes.

## Источник

- [HTTP/2, RFC 9113](https://www.rfc-editor.org/rfc/rfc9113)

## Проверь себя

1. Как HTTP/2 сохраняет проблему TCP head-of-line?
2. Почему увеличение max streams не всегда увеличивает throughput?

<details>
<summary>Ответы</summary>

1. Кадры разделены логически, но TCP выдаёт один поток байтов по порядку.

2. Потоки делят сеть, окна, CPU и downstream capacity; дополнительная конкуренция может ухудшить хвост latency.

</details>

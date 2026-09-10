---
title: Connection lifecycle
description: TCP establishment, states, TIME_WAIT, keepalive, pools и ephemeral ports.
tags: [networking, tcp, connections]
updated: 2026-09-10
---

# Connection lifecycle

TCP connection идентифицируется endpoint pair; на практике flow различают source/destination address+port и protocol. До application data клиент обычно проходит DNS, TCP handshake и, для HTTPS, TLS handshake — каждый stage требует отдельного timeout/metric.

## Establishment и states

Active opener отправляет SYN, peer отвечает SYN+ACK, client подтверждает ACK; data может теряться/retransmit-иться согласно TCP. Основные состояния RFC 9293:

- `LISTEN`, `SYN-SENT`, `SYN-RECEIVED` — установление;
- `ESTABLISHED` — двусторонняя передача;
- `FIN-WAIT-1/2`, `CLOSING`, `LAST-ACK` — локальное/одновременное закрытие;
- `CLOSE-WAIT` — peer прислал FIN, application локально ещё не закрыл socket;
- `TIME-WAIT` — active closer ждёт достаточно долго для delayed segments и повторной доставки final ACK.

Много `CLOSE-WAIT` обычно указывает на application resource leak. Много `TIME-WAIT` само по себе нормально при частом active close; исследуйте connection churn и port pressure до sysctl tuning.

## Ephemeral ports

Outbound connection получает local ephemeral port. Одновременно доступная комбинация ограничена local addresses, port range и destination tuples; NAT/proxy имеет собственную таблицу/лимиты. Короткие connections к одному endpoint плюс `TIME-WAIT` могут исчерпать пространство раньше CPU.

Диагностируйте `connect` errors, active/TIME_WAIT counts по destination, port range и NAT capacity. Connection reuse обычно надёжнее агрессивного `tcp_tw_reuse`; kernel tunables version/platform-specific и могут менять safety semantics.

## Keepalive и pool

HTTP keep-alive/persistent connection означает повторное использование для requests. TCP keepalive — редкие probes idle connection; он не заменяет request deadline и часто имеет слишком длинные OS defaults. Application heartbeat проверяет protocol-level liveness, но тоже не доказывает, что следующая операция завершится вовремя.

Pool ограничивает open/idle/lifetime и concurrency. Слишком малый даёт acquisition queue, слишком большой перегружает dependency. Настройте max connections, idle count/time, max lifetime с jitter, acquire timeout и metrics. Lifetime должен учитывать load-balancer/NAT idle timeout; stale pooled connection может закрыться и потребовать безопасного retry.

В Go переиспользование HTTP connection требует дочитать/закрыть response body по contract transport-а. Создавайте долгоживущий `http.Client`/`Transport`, не по одному на request. См. [HTTP client](../../go/backend/http-client.md) и [pool exhaustion](../../production/connection-pool-exhaustion.md).

## Источники

- [TCP, RFC 9293](https://www.rfc-editor.org/rfc/rfc9293)
- [Linux IP sysctl](https://docs.kernel.org/networking/ip-sysctl.html)


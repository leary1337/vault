---
title: Connection lifecycle
description: TCP establishment, states, TIME_WAIT, keepalive, pools и ephemeral ports.
tags: [networking, tcp, connections]
updated: 2026-10-06
---

# Connection lifecycle

Соединение живёт дольше отдельного запроса. Его создание, повторное использование и закрытие расходуют разные ресурсы; разбор этих стадий помогает отличить медленную сеть от утечки сокетов.

## Термины в этой статье

- **endpoint** — конкретный адрес службы или сторона соединения.
- **handshake** — начальный обмен, в котором стороны устанавливают параметры соединения.
- **NAT** — преобразование адресов, часто вместе с портами, при прохождении через сетевой узел.
- **pool** — набор объектов, например соединений, которые используются повторно.

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

Pool ограничивает open/idle/lifetime и concurrency. Слишком малый даёт acquisition queue, слишком большой перегружает dependency. Настройте max connections, idle count/time, max lifetime с jitter, acquire timeout и metrics. Срок простоя idle connection согласуйте с idle timeout балансировщика/NAT; проверяйте keepalive и безопасную обработку соединения, которое посредник уже закрыл. Max lifetime ограничивает общий возраст соединения, включая активное: это другое ограничение. Даже проверка перед выдачей из pool не исключает закрытия сразу после неё; повтор требует учёта идемпотентности.

В Go переиспользование HTTP connection требует дочитать/закрыть response body по contract transport-а. Создавайте долгоживущий `http.Client`/`Transport`, не по одному на request. См. [HTTP client](../../go/backend/http-client.md) и [pool exhaustion](../../production/connection-pool-exhaustion.md).

## Разбор на примере

Приложение делает 2000 коротких соединений в секунду к одному адресу. Если условно доступно 28000 комбинаций портов, а закрытые соединения удерживаются 60 секунд, оценка давления — `2000 × 60 = 120000`, заметно выше бюджета. Это модель для поиска риска: фактическое повторное использование зависит от kernel, адресов и назначения, TIME_WAIT duration не задаётся произвольной константой для всех систем.

```bash
ss -tan state close-wait
ss -tan state time-wait
ss -s
cat /proc/sys/net/ipv4/ip_local_port_range
```

Команды предназначены для Linux. Растущий CLOSE-WAIT вместе с FD count говорит: peer уже закрыл направление, локальный процесс не освобождает сокет. TIME-WAIT при стабильном FD count скорее объясняется частым закрытием. Исправления разные: lifecycle в первом случае, уменьшение churn/pooling во втором. Поднимать лимит FD без исправления утечки лишь откладывает отказ.

В Go новые Client с nil Transport делят DefaultTransport; именно отдельный Transport создаёт отдельный пул. Не путайте число объектов Client с числом независимых пулов.

## Источники

- [TCP, RFC 9293](https://www.rfc-editor.org/rfc/rfc9293)
- [Linux IP sysctl](https://docs.kernel.org/networking/ip-sysctl.html)


## Проверь себя

1. Как различить CLOSE-WAIT и TIME-WAIT по ответственности?
2. Как оценить риск port exhaustion?

<details>
<summary>Ответы</summary>

1. CLOSE-WAIT ждёт закрытия локальным приложением после FIN peer; TIME-WAIT — штатная защита TCP после активного закрытия.

2. Связать частоту новых соединений, длительность удержания, локальные адреса и destination tuples; проверить фактические счётчики.

</details>

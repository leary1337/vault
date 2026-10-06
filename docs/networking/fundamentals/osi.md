---
title: Модель ISO OSI
description: Семь уровней OSI как reference model и диагностический словарь.
tags: [networking, osi, fundamentals]
created: 2024-07-22
updated: 2026-10-06
---

# Модель ISO OSI

OSI — словарь из семи уровней, который помогает разделять обязанности. Для диагностики полезнее назвать конкретный протокол и точку завершения, чем спорить о единственном номере слоя для TLS или QUIC.

## Термины в этой статье

- **handshake** — начальный обмен, в котором стороны устанавливают параметры соединения.
- **endpoint** — конкретный адрес службы или сторона соединения.
- **identity** — подтверждённая личность пользователя или службы.
- **proxy** — посредник, который принимает соединение или запрос и передаёт его дальше.

OSI Basic Reference Model разделяет communication functions на семь conceptual layers. Это не точное описание каждой современной implementation и не утверждение, что Internet protocols обязаны укладываться один-к-одному; модель полезна как vocabulary и для определения boundary отказа.

| Уровень | Роль | Примеры concepts |
|---|---|---|
| 7 Application | protocol operations приложения | HTTP, DNS, SMTP |
| 6 Presentation | representation/encoding/security transforms | serialization, historical placement encryption |
| 5 Session | dialog/session coordination | checkpoints, session state concepts |
| 4 Transport | process-to-process transport | TCP, UDP, QUIC (пересекает boundaries) |
| 3 Network | addressing и forwarding между networks | IPv4/IPv6, ICMP |
| 2 Data Link | frames и delivery на link | Ethernet, Wi-Fi MAC |
| 1 Physical | передача symbols/bits в medium | copper, fiber, radio PHY |

TLS обычно обсуждают между application и transport, а QUIC объединяет transport и cryptographic handshake, поэтому спор о «точном номере слоя» часто менее полезен, чем вопрос: какой endpoint завершает protocol и кто владеет key/state.

## Диагностика

Layered walk помогает не смешивать причины:

1. link/interface up, errors/drops;
2. IP address/route/MTU;
3. transport handshake/state/ports;
4. TLS/application protocol/status.

При этом наблюдаемый timeout на application layer может быть вызван queueing на любом нижнем или верхнем component. Модель организует проверку, но не доказывает cause.

## Разбор на примере

Пользователь видит «не открывается сайт». Link up ещё не означает доступный route; правильный route не означает открытый port; успешный connect не означает доверенный сертификат; корректный TLS не означает успешную авторизацию.

В trace: TCP handshake выполнен, TLS verification успешно, сервер вернул HTTP 403. Нижние стадии прошли, поэтому первым исследуют прикладную policy и identity, не кабель. Это локализация гипотезы, а не гарантия: proxy мог вернуть 403 вместо origin.

Сессия пользователя из приложения не обязана совпадать с OSI session layer, а TLS не всегда удобно «прибить» к presentation layer. QUIC объединяет transport и handshake, reverse proxy завершает одни протоколы и создаёт другие соединения. При объяснении укажите, какие данные и ответственность проходят через границу.

## Источник

- [ISO/IEC 7498-1: OSI Basic Reference Model](https://www.iso.org/standard/20269.html)

## Проверь себя

1. Что проверить первым при HTTP 403 после успешного TLS?
2. Почему OSI нельзя буквально считать схемой каждой реализации?

<details>
<summary>Ответы</summary>

1. Кто вернул ответ, identity и authorization policy; сам 403 не указывает на физический link.

2. Современные протоколы и proxies совмещают функции и пересекают концептуальные границы.

</details>

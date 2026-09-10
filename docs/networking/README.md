---
title: Сети
description: Сетевые основы и протоколы, важные для backend-разработки.
tags:
  - networking
updated: 2026-09-10
---

# Сети

Рекомендуемый порядок: [фундамент](fundamentals/README.md) → [transport layer](transport/README.md) → [application layer](application/README.md) → [backend connections](backend/README.md).

После моделей OSI и TCP/IP переходите к IP addressing и sockets, затем к TCP/UDP/QUIC и HTTP/TLS/DNS. Backend-подраздел связывает connection establishment/states, TIME_WAIT, keep-alive/pools/ephemeral ports, DNS cache, TLS handshake, HTTP multiplexing/HOL и L4/L7 proxies с production failure modes.

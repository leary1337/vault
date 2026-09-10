---
title: Go backend standard library
description: HTTP, JSON, time, logging и lifecycle production Go-сервиса.
tags:
  - go
  - backend
updated: 2026-09-10
---

# Go backend standard library

Порядок чтения: [net/http](net-http.md) → [HTTP server](http-server.md) и [HTTP client](http-client.md) → [request context](request-context.md) → [graceful shutdown](graceful-shutdown.md). Затем: [JSON](json.md), [time](time.md), [logging](logging.md).

Главная тема раздела — bounded resources: timeouts, body limits, connection pools, cancellation, observability и контролируемое завершение.

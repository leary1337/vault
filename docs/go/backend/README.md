---
title: Go backend standard library
description: HTTP, JSON, time, logging и lifecycle production Go-сервиса.
tags:
  - go
  - backend
updated: 2026-10-06
---

# Go backend standard library

Backend — серверная часть приложения. Здесь стандартная библиотека Go помогает обработать запрос, ограничить время и память, вызвать зависимости и остановиться без потери управляемой работы. Timeout ограничивает время, limit — размер/количество; оба нужны независимо.

## Темы

- [`net/http`](net-http.md)
- [Graceful shutdown HTTP-сервера](graceful-shutdown.md)
- [HTTP client и Transport](http-client.md)
- [HTTP request context](request-context.md)
- [HTTP server](http-server.md)
- [JSON в Go](json.md)
- [Structured logging в Go](logging.md)
- [Time и timers](time.md)

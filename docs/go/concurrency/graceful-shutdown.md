---
title: Graceful shutdown
description: Порядок остановки Go-сервиса без потери управляемой работы.
tags:
  - go
  - concurrency
  - production
updated: 2026-09-10
---

# Graceful shutdown

Graceful shutdown — bounded protocol, а не бесконечное ожидание всех goroutines.

## Порядок

1. Получить shutdown signal и прекратить readiness/admission новой работы.
2. Остановить listeners/consumers так, чтобы новые tasks не появлялись.
3. Отменить background context или дать in-flight work отдельное drain window.
4. Дождаться owned goroutines и закрыть producers/connections в dependency order.
5. При исчерпании deadline завершить принудительно и зафиксировать незавершённую работу.

```go
ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
defer stop()

<-ctx.Done()

shutdownCtx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
defer cancel()
if err := server.Shutdown(shutdownCtx); err != nil {
    return fmt.Errorf("shutdown HTTP server: %w", err)
}
```

`http.Server.Shutdown` закрывает listeners и idle connections и ждёт active handlers, но не знает о произвольных hijacked/background resources; их lifecycle нужно зарегистрировать отдельно.

## Production-нюансы

Orchestrator grace period должен быть длиннее внутреннего drain deadline с запасом. SIGKILL перехватить нельзя. Readiness следует выключить до закрытия listener с учётом propagation delay load balancer/service discovery.

Для Kafka consumer нужно координировать прекращение poll, завершение in-flight messages и commit policy. Для non-idempotent work timeout shutdown не должен автоматически означать безопасный retry.

## Источники

- [`os/signal.NotifyContext`](https://pkg.go.dev/os/signal#NotifyContext)
- [`http.Server.Shutdown`](https://pkg.go.dev/net/http#Server.Shutdown)

---
title: Probes
description: Startup, readiness и liveness без restart cascades.
tags: [containers, kubernetes, health]
updated: 2026-09-10
---

# Probes

Probes отвечают на разные вопросы:

- startup: приложение завершило долгий initial start; до успеха liveness/readiness не выполняются;
- readiness: можно ли направлять новую работу; failure удаляет Pod из ready Service endpoints, но не restart-ит;
- liveness: процесс застрял необратимо и restart полезен; failure restart-ит container.

Liveness не должна зависеть от общей БД/Redis: outage dependency перезапустит все Pods, уменьшит capacity и усилит incident. Readiness тоже используйте осторожно — если все Pods unready при overload, traffic некуда направлять.

```yaml
startupProbe:
  httpGet: {path: /health/startup, port: http}
  failureThreshold: 30
  periodSeconds: 2
readinessProbe:
  httpGet: {path: /health/ready, port: http}
  periodSeconds: 5
livenessProbe:
  httpGet: {path: /health/live, port: http}
  periodSeconds: 10
  failureThreshold: 3
```

Probe timeout, period, success/failure thresholds задают detection time. Endpoint должен быть дешёвым, concurrency-safe и не создавать новый process/connection leak. Exec probe дороже и может отсутствовать в distroless image; HTTP/TCP/gRPC выбирайте по нужной semantics.

Startup budget должен покрывать worst expected cold start без скрытия вечной ошибки. Liveness проверяет progress/event loop, а не только «порт открыт», если deadlock возможен.

Наблюдайте probe failures отдельно от application 5xx, events/restarts и latency endpoint. Тестируйте dependency outage и CPU throttling.

## Источники

- [Liveness, readiness and startup probes](https://kubernetes.io/docs/concepts/workloads/pods/probes/)

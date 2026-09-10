---
title: Graceful shutdown
description: Endpoint removal, preStop, SIGTERM и termination grace period.
tags: [containers, kubernetes, lifecycle]
updated: 2026-09-10
---

# Graceful shutdown

При удалении Pod API ставит deletion timestamp; control plane обновляет EndpointSlices, а kubelet начинает local termination. Эти действия происходят распределённо, поэтому некоторое время новый traffic ещё может прийти.

Kubelet выполняет `preStop` hook, если задан, затем посылает container stop signal (обычно `SIGTERM`). Весь процесс ограничен `terminationGracePeriodSeconds` (default 30 s); после grace period оставшиеся processes получают `SIGKILL`.

## Application sequence

1. Получить TERM через `signal.NotifyContext`.
2. Сделать application readiness false/остановить intake.
3. Закрыть listener или вызвать HTTP `Shutdown`; gRPC сначала `GracefulStop` с timeout fallback `Stop`.
4. Остановить polling consumer, завершить/вернуть in-flight records без раннего offset commit.
5. Flush critical telemetry/state в короткий bounded budget.
6. Exit 0 до platform deadline.

`preStop: sleep` может дать LB время, но съедает тот же grace budget и маскирует lifecycle race. Предпочитайте корректное endpoint termination handling и internal drain; fixed delay добавляйте только после измерения инфраструктуры.

```yaml
spec:
  terminationGracePeriodSeconds: 45
```

Shutdown budget включает worst request/RPC, queue ack и safety margin, но не должен позволять бесконечный stream. Client deadlines/retries/idempotency закрывают принудительное завершение.

Integration test: active request + TERM, проверка отсутствия новой работы, завершения bounded calls и отсутствия `SIGKILL`/duplicate side effects.

## Источники

- [Pod termination](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination)
- [Go graceful shutdown](../../go/backend/graceful-shutdown.md)

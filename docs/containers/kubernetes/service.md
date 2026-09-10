---
title: Service
description: Stable virtual endpoint, EndpointSlices и service types.
tags: [containers, kubernetes, networking]
updated: 2026-09-10
---

# Service

Service задаёт стабильное virtual endpoint/DNS для динамического набора Pods. Selector обычно формирует EndpointSlices из ready matching Pods; конкретный proxy/data plane реализуют kube-proxy replacement/CNI.

## Types

- `ClusterIP` — internal virtual IP (default);
- `NodePort` — port на nodes, обычно building block;
- `LoadBalancer` — просит внешнюю реализацию/provider создать LB;
- `ExternalName` — DNS CNAME, без proxy/selector;
- headless (`clusterIP: None`) — DNS возвращает individual endpoints для client-side discovery/stateful use.

`port` — Service port, `targetPort` — container/Pod port, `nodePort` — node exposure. Named ports помогают evolution.

```yaml
apiVersion: v1
kind: Service
metadata: {name: api}
spec:
  selector: {app: api}
  ports:
    - {name: http, port: 80, targetPort: http}
```

Service не проверяет application health сам: readiness влияет на ready endpoints. Existing connections могут продолжать идти в terminating Pod в зависимости от client/LB/connection; graceful shutdown всё равно нужен.

## Debug

```bash
kubectl get service api -o yaml
kubectl get endpointslice -l kubernetes.io/service-name=api
kubectl get pod -l app=api --show-labels
```

Если endpoints пусты, проверьте selector, readiness и target port прежде DNS/firewall. Service routing не гарантирует равный request load при keep-alive/HTTP2.

## Источники

- [Services](https://kubernetes.io/docs/concepts/services-networking/service/)

---
title: Ingress
description: HTTP routing, controllers, TLS и Gateway API context.
tags: [containers, kubernetes, ingress]
updated: 2026-09-10
---

# Ingress

Ingress resource описывает HTTP/HTTPS host/path routing к Services. Без установленного Ingress controller он ничего не делает. Controller implementation определяет annotations, TLS, retries, timeouts, limits и status.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: api}
spec:
  ingressClassName: public
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service: {name: api, port: {number: 80}}
```

Ingress API stable, но feature set frozen; Kubernetes рекомендует Gateway API для новых richer routing use cases. Это не означает мгновенную deprecated removal: выбор зависит от installed controllers и platform roadmap.

## Design

- `ingressClassName` явно выбирает controller;
- TLS Secret/issuer lifecycle и redirect policy;
- max body/header, request/per-try timeout;
- trusted proxy/source IP и forwarded headers;
- idempotent-only retries с budgets;
- rate/WAF/auth placement;
- gRPC/HTTP2/WebSocket support конкретного controller.

Path rewriting/regex annotations непереносимы. Test должен проходить через реальный controller/LB, не только Service.

```bash
kubectl describe ingress api
kubectl get ingressclass
kubectl logs -n <ns> <ingress-controller-pod>
```

## Источники

- [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Gateway API](https://gateway-api.sigs.k8s.io/)

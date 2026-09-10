---
title: Kubernetes networking
description: Pod network, CNI, Service, DNS и NetworkPolicy.
tags: [containers, kubernetes, networking]
updated: 2026-09-10
---

# Kubernetes networking

Kubernetes network model предполагает уникальный Pod IP и прямую Pod-to-Pod communication cluster-wide без application-level NAT между Pods. CNI/plugin реализует routing/overlay, IPAM, policy и observability; детали latency/MTU/encapsulation зависят от него.

## Layers

- Pod network: veth/routes/overlay or native routing;
- Service: virtual IP + EndpointSlices, реализованные proxy/eBPF/data plane;
- DNS: Service/Pod discovery через CoreDNS;
- Ingress/Gateway/LoadBalancer: north-south routing;
- NetworkPolicy: L3/L4 ingress/egress allow rules, только если CNI поддерживает.

NetworkPolicy additive и обычно default-allow до появления selecting policy. Создайте explicit default-deny + required DNS/dependency paths и test реальным CNI. Она не понимает HTTP user authorization и не шифрует traffic.

## Common failures

- selector/readiness оставляет Service без endpoints;
- DNS suffix/search `ndots` создаёт лишние queries;
- MTU mismatch ломает большие packets/TLS при работающем ping;
- conntrack/SNAT/ephemeral port exhaustion;
- stale keep-alive connection после Pod termination;
- policy блокирует DNS/return path;
- asymmetric routing/source IP expectations.

Диагностируйте по слоям: name resolution → endpoints → route/connect → TLS/application. Ephemeral debug container/network namespace полезнее установки tools в production image.

## Источники

- [Cluster networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

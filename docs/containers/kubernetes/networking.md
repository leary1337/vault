---
title: Kubernetes networking
description: Pod network, CNI, Service, DNS и NetworkPolicy.
tags: [containers, kubernetes, networking]
updated: 2026-10-06
---

# Kubernetes networking

Pod получает адрес, Service даёт устойчивое имя, DNS находит его, а network plugin реализует передачу пакетов. Ошибку удобнее искать по этим границам.

Kubernetes network model предполагает уникальный Pod IP и прямую Pod-to-Pod communication cluster-wide без application-level NAT между Pods. CNI/plugin реализует routing/overlay, IPAM (выделение и учёт IP-адресов), policy и observability; детали latency/MTU/encapsulation зависят от него.

## Layers

- Pod network: veth/routes/overlay or native routing;
- Service: virtual IP + EndpointSlices, реализованные proxy/eBPF/data plane;
- DNS: Service/Pod discovery через CoreDNS;
- Ingress/Gateway/LoadBalancer: north-south routing;
- NetworkPolicy: L3/L4 ingress/egress allow rules, только если CNI (интерфейс network plugin для настройки сети containers) поддерживает.

NetworkPolicy additive и обычно default-allow до появления selecting policy. Создайте explicit default-deny + required DNS/dependency paths и test реальным CNI. Она не понимает HTTP user authorization и не шифрует traffic.

## Common failures

- selector/readiness оставляет Service без endpoints;
- DNS suffix/search `ndots` создаёт лишние queries;
- MTU (максимальный размер пакета на участке сети) mismatch ломает большие packets/TLS при работающем ping;
- conntrack/SNAT/ephemeral port exhaustion;
- stale keep-alive connection после Pod termination;
- policy блокирует DNS/return path;
- asymmetric routing/source IP expectations.

Диагностируйте по слоям: name resolution → endpoints → route/connect → TLS/application. Ephemeral debug container/network namespace полезнее установки tools в production image.

## Политика ограничивает сеть, а не пользователя

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: api-ingress}
spec:
  podSelector: {matchLabels: {app: api}}
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector: {matchLabels: {app: gateway}}
      ports: [{protocol: TCP, port: 8080}]
```

Пример разрешает ingress к api только от gateway Pods в том же namespace, если CNI поддерживает policy. Egress этим manifest не ограничен. Разные policies суммируют разрешения: добавление правила не отменяет другие allow.

CNI не обязан быть kube-proxy: Service traffic может реализовываться iptables/nftables/IPVS или eBPF. Kubernetes 1.37 baseline не определяет единственный data plane. Для DNS, MTU и conntrack (учёт состояния сетевых соединений) выберите средства конкретного установленного plugin; policy не проверяет HTTP права и не шифрует payload.

## Источники

- [Cluster networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

## Проверь себя

1. Суммируются ли разрешения NetworkPolicy?
2. Контролирует ли пример egress?

<details>
<summary>Ориентиры для ответа</summary>

1. Да, selecting policies additive; одно allow не перекрывается более строгим другим.
2. Нет, указан только Ingress; outbound требует отдельного policy.

</details>

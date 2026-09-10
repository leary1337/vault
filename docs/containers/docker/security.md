---
title: Docker security
description: Least privilege, image supply chain, secrets и runtime isolation.
tags: [containers, docker, security]
updated: 2026-09-10
---

# Docker security

Container делит kernel с host. Security строится слоями: trusted/minimal image, non-root/rootless where possible, capabilities/seccomp/AppArmor/SELinux, read-only filesystem, network/secret policy и patched host.

## Image/build

- pin/review base digest и регулярно rebuild для patches;
- multi-stage final image без compiler/package manager;
- scan vulnerabilities, но triage по reachability/fix; generate SBOM/provenance/sign artifacts;
- не передавать secrets через `ARG`, `ENV`, layer или public build cache;
- ограничить untrusted build context и CI registry credentials.

## Runtime

Запускайте explicit non-zero UID/GID; root внутри container сохраняет опасные capabilities/host attack paths. Drop all capabilities и добавляйте только нужные, включите `no-new-privileges`, default/custom seccomp, read-only root и narrow mounts.

Не монтируйте Docker socket: control над daemon обычно равен control над host. Privileged container, host PID/network, host root bind mounts и device access разрушают isolation и требуют отдельного threat review.

Secrets передавайте runtime file/tmpfs/secret manager с rotation, не env, если process dump/inspect exposure неприемлем. Ограничьте egress и published ports.

## Operations

Patch kernel/runtime вместе с images; audit daemon/API access; rootless Docker уменьшает daemon/container privilege, но имеет compatibility limits. Resource/PID limits защищают availability, не только cost.

## Источники

- [Docker Engine security](https://docs.docker.com/engine/security/)
- [Docker security best practices](https://docs.docker.com/build/building/best-practices/)

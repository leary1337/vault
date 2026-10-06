---
title: Docker security
description: Least privilege, image supply chain, secrets и runtime isolation.
tags: [containers, docker, security]
updated: 2026-10-06
---

# Docker security

Container разделяет ядро с host. Защита уменьшает полномочия процесса, число доступных ресурсов и вероятность доставки вредного image.

Container делит kernel с host. Security строится слоями: trusted/minimal image, non-root/rootless where possible, capabilities/seccomp/AppArmor/SELinux, read-only filesystem, network/secret policy и patched host.

## Image/build

- pin/review base digest (криптографический идентификатор конкретного содержимого) и регулярно rebuild для patches;
- multi-stage final image без compiler/package manager;
- scan vulnerabilities, но triage по reachability/fix; generate SBOM/provenance/sign artifacts;
- не передавать secrets через `ARG`, `ENV`, layer или public build cache;
- ограничить untrusted build context и CI registry credentials.

## Runtime

Запускайте explicit non-zero UID/GID; root внутри container сохраняет опасные capabilities/host attack paths. Drop all capabilities (отдельные полномочия Linux вместо всех полномочий root) и добавляйте только нужные, включите `no-new-privileges`, default/custom seccomp (ограничение разрешённых системных вызовов), read-only root и narrow mounts.

Не монтируйте Docker socket: control над daemon обычно равен control над host. Privileged container, host PID/network, host root bind mounts и device access разрушают isolation и требуют отдельного threat review.

Secrets передавайте runtime file/tmpfs/secret manager с rotation, не env, если process dump/inspect exposure неприемлем. Ограничьте egress и published ports.

## Operations

Patch kernel/runtime вместе с images; audit daemon/API access; rootless Docker уменьшает daemon/container privilege, но имеет compatibility limits. Resource/PID limits защищают availability, не только cost.

## Минимальные полномочия обычного API

```bash
docker run --user 10001:10001 --read-only   --cap-drop=ALL --security-opt=no-new-privileges   --tmpfs /tmp:rw,nosuid,nodev,size=16m api-image
```

Пример требует, чтобы API не нуждался в root, capabilities и записи вне /tmp. Default seccomp не отключён. Такой запуск уменьшает поверхность, но не доказывает полную sandbox-безопасность.

Docker socket позволяет управлять daemon и создавать containers с host mounts; передача `/var/run/docker.sock` приложению обычно даёт намного больше, чем нужно для API. Для image scanning и builds отделите CI identity и допустимые registry permissions.

Non-root UID внутри rootful container и rootless daemon — разные уровни ограничения. Секреты с short-lived credentials и rotation требуют, чтобы приложение перечитывало файл и обновляло connections.

## Источники

- [Docker Engine security](https://docs.docker.com/engine/security/)
- [Docker security best practices](https://docs.docker.com/build/building/best-practices/)

## Проверь себя

1. Зачем no-new-privileges вместе с non-root?
2. Почему доступ к Docker socket опаснее обычного volume?

<details>
<summary>Ориентиры для ответа</summary>

1. Он запрещает приобретать новые privileges через exec, например setuid binary.
2. Это управление daemon, часто позволяющее получить host-level доступ.

</details>

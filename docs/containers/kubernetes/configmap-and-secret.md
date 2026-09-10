---
title: ConfigMap и Secret
description: Configuration delivery, update semantics и secret protection.
tags: [containers, kubernetes, configuration, security]
updated: 2026-09-10
---

# ConfigMap и Secret

ConfigMap хранит non-confidential configuration. Secret — отдельный API object с access controls, но base64 в manifest не encryption. Защитите etcd encryption at rest, RBAC, audit, namespace и delivery path.

## Consumption

- environment variables фиксируются при старте container и не обновляются;
- mounted volume files обновляются eventually через kubelet projection, но `subPath` mount не получает automatic updates;
- application должна atomic-read/reload или rollout-иться по version/checksum;
- immutable ConfigMap/Secret снижает accidental mutation и watch load, но требует нового object для change.

## Practice

Не commit-ьте Secret manifest с plaintext/base64. Используйте external secret manager/operator или encrypted GitOps flow с разделёнными ключами. ServiceAccount token проецируйте short-lived с нужной audience, не legacy long-lived secret.

Configuration version включайте в deployment annotation/checksum, чтобы rollout был наблюдаем. Validate при startup и fail fast для invalid required config; optional dynamic change должна иметь rollback/default.

Secrets не передавайте в command args/logs/metrics. Env проще, но видна child/process diagnostics и не rotating; file mount обычно удобнее для rotation, если client перечитывает. После rotation учитывайте old sessions/connections.

```bash
kubectl auth can-i get secrets --as system:serviceaccount:ns:app -n ns
kubectl get configmap app-config -o yaml
```

Не выводите Secret contents в incident transcript. Ограничьте list/watch secrets: это раскрывает весь namespace scope.

## Источники

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Good practices for Secrets](https://kubernetes.io/docs/concepts/security/secrets-good-practices/)

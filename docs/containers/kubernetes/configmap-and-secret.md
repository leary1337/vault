---
title: ConfigMap и Secret
description: Configuration delivery, update semantics и secret protection.
tags: [containers, kubernetes, configuration, security]
updated: 2026-10-06
---

# ConfigMap и Secret

ConfigMap передаёт обычную конфигурацию, Secret — чувствительные данные с отдельными правилами доступа. Base64 кодирует bytes, но любой получивший значение может его декодировать.

ConfigMap хранит non-confidential configuration. Secret — отдельный API object с access controls, но base64 в manifest не encryption. Защитите etcd encryption at rest, RBAC (разграничение прав по ролям), audit, namespace и delivery path.

## Consumption

- environment variables фиксируются при старте container и не обновляются;
- mounted volume files обновляются eventually через kubelet projection, но `subPath` mount не получает automatic updates;
- application должна atomic-read/reload или rollout (замена экземпляров приложения новой версией)-иться по version/checksum;
- immutable (неизменяемый после создания) ConfigMap/Secret снижает accidental mutation и watch load, но требует нового object для change.

## Practice

Не commit-ьте Secret manifest с plaintext/base64. Используйте external secret manager/operator или encrypted GitOps flow с разделёнными ключами. ServiceAccount token проецируйте short-lived с нужной audience, не legacy long-lived secret.

Configuration version включайте в deployment annotation/checksum, чтобы rollout был наблюдаем. Validate при startup и fail fast для invalid required config; optional dynamic change должна иметь rollback/default.

Secrets не передавайте в command args/logs/metrics. Env проще, но видна child/process diagnostics и не rotating; file mount обычно удобнее для rotation, если client перечитывает. После rotation учитывайте old sessions/connections.

```bash
kubectl auth can-i get secrets --as system:serviceaccount:ns:app -n ns
kubectl get configmap app-config -o yaml
```

Не выводите Secret contents в incident transcript. Ограничьте list/watch secrets: это раскрывает весь namespace scope (область измерения: host, cgroup или process).

## Файл, который можно обновлять

Фрагмент Pod spec, Secret `app-credentials` должен быть создан отдельно:

```yaml
containers:
  - name: api
    image: registry.example/api:2026-10-06
    volumeMounts:
      - {name: credentials, mountPath: /var/run/app, readOnly: true}
volumes:
  - name: credentials
    secret:
      secretName: app-credentials
```

Файлы проекции обновляются не мгновенно; приложение должно заново читать путь, а не бесконечно держать старый FD. Для `subPath` automatic update не действует. При rotation новый пароль должен быть принят downstream до отказа старого; уже открытые sessions тоже имеют lifecycle.

Право создавать Pod в namespace может косвенно дать возможность монтировать Secret, даже без прямого get secret. Поэтому защита требует RBAC/admission и разделения workload identities, а не только запрета просмотра yaml.

## Источники

- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Good practices for Secrets](https://kubernetes.io/docs/concepts/security/secrets-good-practices/)

## Проверь себя

1. Меняется ли env после обновления ConfigMap?
2. Почему base64 Secret не защищает содержимое?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, env фиксируется при запуске; нужен restart/rollout.
2. Это обратимое кодирование без ключа; нужны доступ и encryption at rest.

</details>

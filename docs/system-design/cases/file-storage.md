---
title: File storage
description: Multipart upload, metadata, integrity, CDN и lifecycle.
tags: [system-design, cases, storage]
updated: 2026-09-10
---

# File storage

## Requirements

Upload/download больших files, resumable multipart, metadata, sharing/permissions, versioning, delete/retention и optional processing. Уточнить max size/types, checksum, malware policy, regional residency, durability/RPO и download bandwidth.

## Architecture

Control plane API хранит metadata/authorization в database; bytes идут напрямую в object storage по short-lived scoped upload URL, чтобы application servers не стали bandwidth bottleneck. CDN обслуживает immutable/versioned downloads.

## Upload path

1. Client создаёт upload session с idempotency key, size/type/checksum.
2. Service authorizes quota и выдаёт multipart URLs/object key.
3. Client загружает parts и сообщает completion.
4. Service проверяет storage metadata/checksum/size, атомарно переводит `uploading → processing`.
5. Async scanner/processor создаёт derived versions и публикует `ready`.

Object key должен быть opaque и tenant-scoped; client filename — metadata, не filesystem path. Download каждый раз проверяет authorization или использует очень короткий signed URL.

## Failures и cleanup

Crash оставляет orphan multipart/object либо metadata без object. Lifecycle abort-ит незавершённые uploads, reconciliation сравнивает states. Completion duplicate idempotent. Delete сначала закрывает access/помечает tombstone, затем async удаляет versions/CDN; legal hold меняет flow.

## Scale и trade-offs

Metadata shard по owner/object ID, listings используют deterministic cursor. Content-addressed dedup экономит bytes, но создаёт privacy/reference-count/encryption complexity. Cross-region replication повышает durability и cost/latency; consistency metadata и object visibility проверяется у выбранного store.

## Security/observability

Ограничьте type/size, archive bombs, URL scope, encryption keys, scanning quarantine. Metrics upload success/time, orphan bytes, checksum failures, scan age, egress/CDN hit и storage errors.

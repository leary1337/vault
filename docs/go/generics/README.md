---
title: Generics в Go
description: Type parameters, constraints, generic types и generic methods в Go 1.27.
tags:
  - go
  - generics
level:
  - middle
  - senior
updated: 2026-09-10
---

# Generics в Go

Generics позволяют описать алгоритм или структуру данных для набора типов, сохранив compile-time type checking. Порядок чтения: [type parameters](type-parameters.md) → [constraints и type sets](constraints-and-type-sets.md) → [generic types и methods](generic-types.md).

Version boundary: generic aliases стабильны с Go 1.24; generic methods — с Go 1.27. Interface methods по-прежнему не могут объявлять собственные type parameters.

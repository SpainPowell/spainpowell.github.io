---
name: composition-patterns
description:
  React composition patterns that scale. Use when refactoring components with
  boolean prop proliferation, building flexible component libraries, or
  designing reusable APIs. Triggers on tasks involving compound components,
  render props, context providers, or component architecture.
license: MIT
metadata:
  author: vercel
  version: '1.1.0'
---

# React Composition Patterns

Composition patterns for building flexible, maintainable React components. Avoid
boolean prop proliferation by using compound components, lifting state, and
composing internals.

## When to Apply

Reference these guidelines when:

- Refactoring components with many boolean props
- Building reusable component libraries
- Designing flexible component APIs
- Reviewing component architecture
- Working with compound components or context providers

## Rule Categories by Priority

| Priority | Category                | Impact | Prefix          |
| -------- | ----------------------- | ------ | --------------- |
| 1        | Component Architecture  | HIGH   | `architecture-` |
| 2        | State Management        | MEDIUM | `state-`        |
| 3        | Implementation Patterns | MEDIUM | `patterns-`     |

## Quick Reference

### 1. Component Architecture (HIGH)

- `rules/architecture-avoid-boolean-props.md` - Don't add boolean props to
  customize behavior; use composition
- `rules/architecture-compound-components.md` - Structure complex components
  with shared context

### 2. State Management (MEDIUM)

- `rules/state-decouple-implementation.md` - Provider is the only place that
  knows how state is managed
- `rules/state-context-interface.md` - Define generic interface with state,
  actions, meta for dependency injection
- `rules/state-lift-state.md` - Move state into provider components for
  sibling access

### 3. Implementation Patterns (MEDIUM)

- `rules/patterns-explicit-variants.md` - Create explicit variant components
  instead of boolean modes
- `rules/patterns-children-over-render-props.md` - Use children for
  composition instead of renderX props

## How to Use

Read the individual rule file (paths above, relative to this skill) when a task
touches its pattern. Each rule file contains the why, an incorrect example, and
a correct example.

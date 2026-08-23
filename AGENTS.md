# Personal Portfolio AGENTS.md

This file is self-contained for use in Spain Powell's portfolio website repo. It includes the generic agent contract plus personal/portfolio-specific constraints.

## Generic Agent Contract

- State the goal and the smallest change that achieves it before coding.
- For unfamiliar or ambiguous work, do a blind-spot pass first: unknowns, references, and questions that could change the plan.
- Prefer the simplest implementation that works; do not add speculative abstraction.
- Make surgical edits. Touch only what the task requires; unrelated cleanup is separate work.
- Stay goal-driven. If a subtask stops serving the stated goal, stop and re-check.
- Run the project verifier after changes. If it cannot run, say why and what risk remains.
- Ask before changing CI workflows, adding dependencies, deploying, editing secrets, or taking destructive git actions.
- Never commit to main, force-push, edit `.env*`, or add unattended/security-sensitive automation without owner, kill switch, audit trail, heartbeat/freshness, identity/activity profile, and rollback path.

## Source Order

1. `Personal Access Boundary.md` for privacy, publication, and context-use limits.
2. `Personal Profile.md` for durable identity and professional throughline.
3. `Personal Narrative.md` for reusable bios, positioning, and audience-specific language.
4. `Experience.md`, `Accomplishments.md`, and `Resume Source.md` for claims, roles, education, metrics, and evidence.
5. `Project and Harness Work Source.md` for portfolio signals from Win the Numbers, FoamFinger, Braisen, TheBrain, and agent-harness work.
6. `Values and Principles.md`, `Strengths and Patterns.md`, `Preferences and Context.md`, and `Goals.md` for tone, priorities, and decision filters.
7. `handoff/README.md` for the portfolio brand identity and visual system.

If sources conflict, preserve the conflict and ask. Do not invent or inflate professional claims.

## Commands

- Use the actual repo scripts once the portfolio site exists.
- Expected web checks: install, typecheck, lint, test if present, build, and visual smoke check.
- For a likely Next.js portfolio: `npm install`, `npm run lint`, `npm run build`, and a local preview command.
- Update this section with the real commands after the portfolio repo is scaffolded.

## Privacy Boundary

- This folder may be used for the portfolio website because Spain explicitly requested it.
- Do not use private personal context for unrelated projects or general background.
- Do not publish sensitive details unless they are already intended for public professional use.
- Prefer public/professional facts from `Resume Source.md`, `LinkedIn Profile Source.md`, `Personal Narrative.md`, and project docs.
- Keep private lifestyle/personality context subtle and purpose-bound. It can inform warmth and voice, but should not become oversharing.
- Claims about impact, roles, education, projects, awards, or metrics must trace back to a source note.

## Portfolio Positioning

- Core identity: data scientist, engineer, and product-minded systems builder.
- Professional throughline: turning complex data, product ideas, and AI-agent workflows into measurable, usable systems.
- Emphasize applied analytics at operational scale: Python forecasting models, SQL over large datasets, Power BI dashboards, Streamlit analytics tools, React Native product work, and verification-first AI-agent harnessing.
- Lead with measurable outcomes where appropriate: FedEx productivity model, under-5-minute model runs replacing manual ArcGIS workflows, reported `$1.5M` monthly savings, `$16M` monthly upside identified, and projected `$24M` annual pickup-process opportunity.
- Portfolio projects to feature: Win the Numbers, FoamFinger, Braisen, TheBrain knowledge system, and reusable Claude/Codex agent harness.
- Current career direction: data science and AI roles where predictive models, analytics systems, and data products create measurable real-world impact.

## Content Rules

- Separate facts, inferences, and open questions.
- Preserve exact numbers and dates from source notes; do not round up, exaggerate, or add unsupported claims.
- Avoid corporate filler. Make the work concrete: problem, action, system, evidence, outcome.
- Show how projects were structured, validated, documented, secured, or launched, not just what they are.
- Treat project status honestly: shipped app, active product, concept, plan, or laboratory should be clear.
- Do not imply employer endorsement, confidential FedEx details, private customer data, or proprietary internals.

## Design Constraints

- Use `handoff/README.md` as the visual identity source of truth.
- Direction: coastal California precision; warm, sunlit, human, disciplined. Never beachy, never corporate, no purple/blue AI tropes.
- Dark mode is default. Palette: ink `#100D0A`, graphite `#1C1712`, bone `#F7EEDF`, driftwood `#9C8E79`, pacific `#2F8578`, signal `#C6D230`, clay `#DE8248`.
- Ratio: about 60% ink/graphite, 30% bone, 10% color. Never combine signal and clay in one component.
- Use Archivo for display/body and IBM Plex Mono for labels, coordinates, metrics, and version tags.
- Primary mark is the SP route monogram. Never recolor strokes, add gradients, or redraw it by eye.
- Hero should feel like route/model/runbook discipline under coastal warmth. Use the route animation as the one flourish.

## Ask Before

- Publishing, deploying, or making private personal details public.
- Changing professional claims, metrics, dates, education details, or award language.
- Adding analytics, tracking, contact forms, newsletters, or third-party embeds.
- Changing the brand palette, mark geometry, typography, or hero direction.
- Using content from outside `Personal/` unless the task explicitly asks for broader vault context.

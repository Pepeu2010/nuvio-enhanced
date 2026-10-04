# Approved source of truth

Approved by the user on 2026-10-03 (America/Sao_Paulo). The complete original
requirements are preserved verbatim in PRODUCT_REQUIREMENTS.md. This document
records the approved architecture, delivery decisions and subsequent amendments.

## Non-negotiable decisions

- Independent native forks of NuvioDesktop and NuvioTV, retaining Git history.
- Kotlin Multiplatform / Compose Desktop and Kotlin / Jetpack Compose / Media3;
  preserve existing native player implementations and platform portability.
- Independent installation, local data, package identity, signing and updater.
- Existing Nuvio authentication, supported sync and Stremio addon contracts.
- Windows and Android TV first; 2 GB / 1080p TV Box performance reference.
- Nuvio Enhanced is a temporary name and explicitly an unofficial client.
- Small verified milestones; no rewrite, fake buttons, lost existing features,
  mandatory telemetry, embedded content/providers or invented server endpoints.
- Phase 0 audit and clean upstream builds precede application modifications.
- Continue directly into the first implementation foundation after Phase 0
  unless a genuine technical blocker prevents that work.

## Amendments approved before execution

1. **Adaptive cache:** 1 GiB Desktop and 256 MiB TV are configurable starting
   defaults, not permanent limits. Auto considers available storage and device
   capabilities; quotas, eviction and cleanup still bound cache growth. Downloads
   are separate. Explicit user settings remain available.
2. **Timed metadata:** Phase 2 introduces a generic timeline/player abstraction
   for time-bound metadata. Chapters, intro/recap/credits and bookmarks use the
   abstraction; Scene Info providers are implemented in Phase 7 without changing
   the underlying player contract. Unknown data stays unknown.
3. **Live TV design readiness:** Phase 1 prepares visual tokens/components for
   channels, now/next, program progress, EPG cells/grid and D-pad focus. No Live TV
   route or actionable control is exposed until Phase 6 has real source support.

## Delivery boundaries

- MVP 1: all mandatory original requirements, both Windows and Android TV.
- MVP 2: Live TV/EPG, advanced failover, Phone Remote, Smart Collections,
  download improvements and complete Spoiler Shield.
- MVP 3: Scene Info, advanced filmstrip, experimental local analysis,
  timeshift, multi-view and advanced recommendations.
- Scene Info Phase 7 does not block earlier milestones. Timeshift/multi-view
  and local recognition are experimental and disabled until validated.
- Shared enhanced domain models stay small and platform-independent; current
  auth/sync repositories remain owned by their original clients.
- Local custom avatars/preferences are not advertised as officially synced;
  upload or cross-device support requires an existing verified server contract.

## Acceptance

Implementation defaults from the approved plan: PreviewCoordinator has a
750 ms Desktop and 1200 ms TV delay, silent autoplay and one active preview;
primary playback takes ownership of decoder resources. Source score starts with
quality 30, language/audio 20, hardware 20, availability/latency 20 and historical
stability 10, with visible evidence and Unknown states. Best Quality/Balanced/
Data Saver/Manual do not remove manual choice. Timeline adapters distinguish
requested/effective timestamp, consult cache, use declared source/sprites/metadata
and isolated local extraction, never repositioning the main player for previews.
Phone Remote is opt-in; random short-lived pairing expires after two minutes
and requires explicit host confirmation. External telemetry is off by default.

Every feature needs implementation, loading/empty/error states, keyboard or
D-pad behavior, accessibility, performance evidence, meaningful tests and docs.
Compilation is not runtime, visual, codec, HDR or modest-device proof. Accounts,
real sources and physical devices require explicit evidence, never invented
results. Preserve copyright, licenses, notices and corresponding source for
distributed modifications.

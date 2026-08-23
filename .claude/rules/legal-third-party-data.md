## Verify License/ToS Before Adding or Exposing Any Third-Party Data Source

**Consuming someone's public API or a public GitHub CSV is not a license. Every upstream source this app
re-serves has its own terms, and the riskiest ones are the easiest to add.**

**Why:** The July 2026 data-licensing research (`docs/compliance/legal-compliance-report.md` §4) found the
current stack already carries real risk: PFR-derived advanced stats reach us third-hand (PFR → nflverse scraper →
GitHub releases → `nfl_data_py`) with no license chain back to Sports Reference — the one dependency with genuine
cease-and-desist tail risk; Sleeper's binding ToS grants only a personal, non-commercial license despite
developer-friendly API docs; and Sleeper CDN headshots are licensed photography that *C.B.C.* (which protects
names+stats) does not cover. Data added "because the endpoint was right there" becomes a legal dependency of a
monetized product.

**How to apply:**
- Before wiring in a new data source — or a new *field* from an existing one — read its actual ToS/license and
  record the conclusion in `docs/compliance/legal-compliance-report.md` §4: does it permit caching, redistribution
  to end users, and commercial (ad-gated/subscription) use? What attribution is required?
- PFR/Sports-Reference posture (backlog §4.1, decided 2026-08-02): the PFR *advanced stats*
  (`import_seasonal_pfr`/`load_pfr_advstats`, missed-tackle RB inputs) were **removed** and stay removed. The
  remaining nflverse `draft_picks` usage (PFR-scraped: draft-capital scoring, the `/api/draft-picks` route, the
  `pfr_player_id`→`gsis_id` bridge) is a **knowingly-accepted residual risk** — kept because only the public-fact
  integer round/pick is consumed, never PFR advanced columns. So: don't re-introduce PFR *advanced-stat* fields,
  and don't add any *new* PFR-derived field (advanced columns like `w_av`/`car_av`, or a new source) without a
  fresh §4 entry — but the existing draft-position consumption is an accepted, not open, item.
- nflverse-native data is CC-BY 4.0 (FTN data CC-BY-SA): fine commercially, but attribution is a binding license
  term — keep the in-app attribution current when adding nflverse datasets.
- Player **names + stats** are protected fantasy use (*C.B.C. v. MLBAM*, 8th Cir. 2007). Player **photos** are
  not — never add a new image source (NFL or college prospects) without confirmed image-licensing rights;
  initials/silhouette avatars are the safe fallback.
- Never bundle NFL/NCAA team logos, wordmarks, or team-branded art. Plain-text team names/abbreviations in a
  stats context are fine.
- Respect published rate limits and keep the TTL-caching posture (`backend/sleeper_proxy.py`,
  `backend/cache_utils.py`) — polite consumption is also the legal-risk-mitigation posture.

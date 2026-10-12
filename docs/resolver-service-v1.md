# Resolver Service v1

## Status

**Implementation specification; service not yet implemented.**

Resolver Service v1 is the acquisition boundary for Recipe Intelligence ingestion. It converts one staged `recipe_inbox` item into normalized, auditable `recipe_inbox_evidence` plus truthful resolution state.

The service deliberately does **not** classify recipes, decide duplicate identity, create taxonomy, or promote recipes.

It implements the Resolver role defined in [Agent Contract v1.1](agent-contract-v1.md).

## Design goals

Resolver Service v1 must:

- give agents one narrow domain operation instead of provider-specific scraping credentials;
- choose acquisition adapters internally;
- preserve source provenance and access limitations;
- short-circuit when existing evidence is already sufficient;
- be safe to retry;
- avoid duplicate evidence as far as the current schema allows;
- keep provider failures local to one inbox item;
- make `partial`, `failed_access`, and `failed_processing` first-class outcomes;
- normalize all successful acquisition into the existing evidence contract.

It must not make semantic recipe decisions merely because an acquisition provider returned structured text.

## Public domain interface

The intended logical operation is:

```text
resolve_inbox_item(inbox_id)
```

The normal caller supplies only `inbox_id`.

Provider choice, credentials, retry policy, cache policy, and acquisition depth are service-owned policy. Reasoning agents must not choose Firecrawl directly or receive Firecrawl/API credentials.

A privileged specialist/debug path may later support an explicit refresh flag, but routine agent operation should not expose provider selection.

### Request

```json
{
  "inbox_id": "uuid"
}
```

### Response

Logical response shape:

```json
{
  "inbox_id": "uuid",
  "resolution_status": "resolved | partial | metadata_only | failed_access | failed_processing",
  "evidence_ids": ["uuid"],
  "adapter_trace": [
    {
      "adapter": "youtube | generic_web | social | manual_context",
      "outcome": "success | partial | skipped | failed",
      "reason_code": "stable_machine_code"
    }
  ],
  "retryable": false,
  "error_code": null,
  "stop_reason": "sufficient_evidence | exhausted_legitimate_paths | access_failure | processing_failure"
}
```

The response is an execution summary. The durable source of truth remains `recipe_inbox` plus `recipe_inbox_evidence`.

## Preconditions

Before acquisition the service must verify:

1. the inbox row exists;
2. `source_ref` or explicit manual input is available;
3. the item is not already completed unless an authorized refresh is requested;
4. the source identity is canonical enough to route;
5. the request is scoped to a permitted ingestion item.

The current live database already enforces unique non-null `recipe_inbox.source_ref`, so rerunning discovery must reuse the same inbox identity.

## Durable state transitions

The service owns resolver-related state only.

Typical flow:

```text
new / ready_for_review / blocked
        |
        v
processing
        |
        +--> resolved
        +--> partial
        +--> metadata_only
        +--> failed_access
        +--> failed_processing
```

`content_resolution_status` records acquisition completeness.

`recipe_inbox.status` records workflow state. Resolver completion does not by itself mean the overall ingestion item is completed.

Recommended post-resolver workflow behavior:

- usable `resolved`, `partial`, or `metadata_only` evidence -> inbox can proceed to classification/review;
- `failed_access` -> preserve failure and route to supported fallback/manual recovery policy;
- `failed_processing` -> retry only when the error is considered retryable;
- no evidence must never be disguised as `resolved`.

## Normalized evidence contract

Each adapter returns zero or more normalized evidence items compatible with the live `recipe_inbox_evidence` table:

```json
{
  "evidence_role": "source_content | creator_reference | external_reference | manual_context",
  "evidence_type": "metadata | description | captions | transcript | audio_transcript | keyframe_text | webpage_text | manual_note | other",
  "locator": "canonical locator when available",
  "content_text": "resolved text when appropriate",
  "payload": {},
  "resolver": "adapter/provider identifier",
  "confidence_score": 0.0,
  "is_primary": false
}
```

At least one of `locator`, `content_text`, or `payload` must be present, matching the live DB constraint.

### Provenance rules

- Original source material -> `source_content`.
- Creator-owned linked recipe/article page -> `creator_reference`.
- Third-party corroboration -> `external_reference`.
- User-supplied recovery/context -> `manual_context`.

An adapter must never relabel a third-party page as creator evidence.

## Adapter interface

Every acquisition adapter implements the same conceptual contract:

```text
supports(inbox_context) -> yes/no
resolve(inbox_context, service_policy) -> AdapterResult
```

`AdapterResult` contains:

- normalized evidence items;
- outcome;
- stable reason/error code;
- retryability;
- discovered child locators worth following;
- whether the adapter believes evidence is sufficient to stop escalation.

Adapters do not write recipe candidates or recipes.

## Routing policy

### 1. Existing/manual evidence first

Before external acquisition, reuse durable evidence already attached to the inbox item when it is still sufficient.

Explicit `manual_context` may complete a previously inaccessible source without reopening unrelated providers.

### 2. YouTube adapter

Preferred order remains:

1. canonical video identity and metadata;
2. description;
3. creator-owned links discovered from the source;
4. linked creator pages via the generic-web adapter;
5. captions/transcript when available and necessary;
6. audio transcription only when legitimate and necessary;
7. keyframe/vision fallback only when necessary;
8. external reference only when source/creator evidence remains insufficient.

The YouTube adapter owns YouTube-specific source acquisition, but creator-owned HTTP pages should normally be delegated to the generic-web adapter rather than reimplementing web scraping.

### 3. Generic-web adapter

Primary backend for v1: **Firecrawl**.

Responsibilities:

- retrieve the requested public page;
- extract main page content and useful metadata;
- preserve canonical/source URL;
- return normalized `webpage_text` evidence;
- expose provider/access errors without converting them into recipe facts.

Firecrawl is infrastructure behind this adapter. Agents do not call it directly.

### 4. Social adapter

Instagram/Facebook support is intentionally **not yet selected**.

Resolver Service v1 reserves a `social` adapter boundary so these sources can be added without changing the caller contract or evidence model.

Until the social acquisition spike is completed:

- unsupported Instagram/Facebook acquisition returns an explicit access/unsupported outcome;
- existing metadata may still be preserved as source evidence where legitimately available;
- user-supplied content can enter through `manual_context`;
- the service must not fabricate captions, ingredients, or recipe identity from an inaccessible reel/post.

### 5. External-reference fallback

Third-party evidence is used only when the approved resolver policy allows it and original/creator evidence is insufficient.

It remains `external_reference`, never source content.

## Evidence sufficiency and short-circuiting

Resolver Service should stop acquisition once evidence is strong enough for downstream Classification to work without pretending unsupported facts are known.

Examples:

- creator recipe page contains recipe title, ingredients, method, servings, and source linkage -> do not fetch audio/keyframes;
- only YouTube title is available -> usually `metadata_only`, not `resolved`;
- source title plus creator page fully supports a recipe -> `resolved` may be appropriate;
- creator page covers only part of a compilation -> `partial`;
- all legitimate routes fail -> `failed_access` or `failed_processing`.

The service does not decide whether a candidate is unique or promotable.

## Error model

Use stable machine-oriented codes internally and store a concise sanitized explanation in `resolution_error`.

Initial code families:

- `SOURCE_MISSING`
- `UNSUPPORTED_SOURCE`
- `ACCESS_DENIED`
- `NOT_FOUND`
- `RATE_LIMITED`
- `PROVIDER_ERROR`
- `CONTENT_EMPTY`
- `PARTIAL_EVIDENCE`
- `PROCESSING_ERROR`
- `BUDGET_EXHAUSTED`

Provider secrets, raw authorization failures, tokens, cookies, or sensitive headers must never be written into recipe tables/evidence.

## Retry policy

Retries happen at the adapter/source step, not by restarting the whole cohort.

Guidelines:

- retry transient rate-limit/provider/network failures with bounded backoff;
- do not repeatedly retry stable access-denied/unsupported outcomes;
- preserve successful evidence when a later fallback fails;
- a rerun should reuse the same inbox item;
- completed downstream candidates are not recreated merely because Resolver is retried.

## Idempotency

Current live safeguards:

- `recipe_inbox.source_ref` has a unique partial index;
- `recipe_candidates(inbox_id, candidate_index)` is unique.

The live `recipe_inbox_evidence` table currently has **no unique evidence fingerprint**.

Resolver v1 therefore needs an application-level evidence fingerprint, conceptually based on:

```text
inbox_id
+ evidence_role
+ evidence_type
+ canonical locator
+ resolver/provider
+ normalized content or payload hash
```

Before inserting evidence, the service should detect and reuse an equivalent existing item.

### Concurrency hardening

Application-level dedupe is sufficient for the first supervised/single-worker implementation, but it is not a complete concurrency guarantee.

Before parallel autonomous resolver workers are enabled, add a reviewed schema migration that persists an evidence fingerprint (or equivalent deterministic key) and enforces uniqueness at the database layer.

That migration is **planned hardening**, not implemented by this specification.

## Caching and freshness

Provider fetching should be cached where safe to reduce token/provider cost and repeated external requests.

Refresh policy must distinguish:

- immutable/stable source identity;
- creator page content that may be edited;
- transient access failures;
- explicit user request to refresh.

Existing durable evidence should be reused by default. Re-fetch only when freshness materially matters, evidence is insufficient/conflicting, or an authorized refresh is requested.

## Security boundary

Resolver Service owns external acquisition credentials.

Reasoning agents receive:

- inbox identifiers;
- normalized evidence;
- resolver outcome/status.

They do **not** receive:

- Firecrawl keys;
- future social API tokens/cookies;
- arbitrary provider credentials;
- unrestricted database credentials.

The service must not disable or bypass RLS, modify Auth, or store secrets in evidence.

## Observability

Every resolver run should make it possible to answer:

- which adapter ran;
- why it ran;
- what evidence it produced/reused;
- where it stopped;
- whether the result is retryable;
- why the final resolution status was chosen.

For v1 this trace may live in structured resolver metadata rather than a new table. A dedicated run-log table should be added only if real operations show that durable execution history is needed.

## Non-goals for v1

Resolver Service v1 does not:

- classify cuisine/protein/concepts;
- decide unique vs duplicate vs variant;
- apply user food preferences;
- create recipes;
- promote candidates;
- normalize creators into a new entity;
- solve Instagram/Facebook acquisition inside this specification;
- introduce a generic browser-agent platform.

## Implementation sequence

1. Implement the service shell around `resolve_inbox_item(inbox_id)`.
2. Implement evidence reuse and current-state checks.
3. Implement generic-web adapter using Firecrawl.
4. Implement YouTube adapter/orchestration and creator-link delegation.
5. Add normalized failure/retry behavior.
6. Test against already validated acceptance cases without changing their semantic outcomes.
7. Add evidence-fingerprint DB hardening before parallel workers.
8. Run a separate Instagram/Facebook acquisition spike and plug the selected strategy into the reserved social adapter.
9. Only then connect the Resolver Service to the broader autonomous-agent runtime.

## Acceptance tests

At minimum, implementation must reproduce these known behaviors:

- Garlic Butter Rice: generic creator page resolves cleanly through Firecrawl.
- Gochujang Pt.2: one source can resolve enough creator evidence for four candidates.
- Jaengban Jjajang: richer creator-page evidence is preserved so downstream QA can correct source identity.
- 2024 Gochujang Noodles: insufficient creator evidence remains visibly partial.
- Facebook Bulgur Meatball Noodle Soup: inaccessible social source may remain failed/blocked until explicit manual context is supplied; manual recovery must preserve provenance.
- rerunning a resolved inbox item must not create duplicate evidence/candidates.

## Ownership

Recipe Intelligence owns this service's domain interface and evidence semantics.

Project OS/Core may later decide where the service runs, how workers are scheduled, and how it is exposed to the wider agent ecosystem.

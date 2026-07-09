# Section Contracts

## Abstract

- Section: Abstract
- Reference path(s) read: `references/section-writing/general.md`
- Purpose in the paper: State the problem, method, strongest evidence, and boundary in a compact form.
- Required content moves: problem; method mechanism; primary result; evidence boundary.
- Required terminology: use frozen paper-facing method and mechanism names.
- Forbidden terminology or internal traces: no file paths, route names, script names, "promoted route", or routine hyperparameters.
- Required evidence links: claim IDs from `claim_evidence_map.md`; primary table or figure IDs.
- Forbidden claims: no deployment, superiority, robustness, or generality claims not licensed by evidence.
- Style constraints: concrete, non-defensive, no generic first sentence.
- Paragraph-level outline: one paragraph, 4-6 sentences.

## Introduction

- Section: Introduction
- Reference path(s) read: `references/section-writing/introduction.md`
- Purpose in the paper: Build the problem-to-mechanism narrative and motivate the method.
- Required content moves: existing assumption; failure phenomenon; mechanism gap; method response; bounded contributions.
- Required terminology: same method and mechanism names as `paper_claims.md`.
- Forbidden terminology or internal traces: no code identifiers, route names, window/step settings, or workflow traces.
- Required evidence links: literature gap entries and claim IDs for contribution bullets.
- Forbidden claims: no claims that require results not yet audited.
- Style constraints: precise, not defensive, not a literature dump.
- Paragraph-level outline: problem context; failure/gap; method mechanism; evidence-backed contributions.

## Related Work

- Section: Related Work
- Reference path(s) read: `references/section-writing/related-work.md`
- Purpose in the paper: Position the work among task, technique, and closest related methods.
- Required content moves: method families; representative works; relation to gap; closest-work distinction.
- Required terminology: use method-family names consistently with the literature matrix.
- Forbidden terminology or internal traces: no experiment log language or internal route framing.
- Required evidence links: `literature_matrix.md` entries and baseline links.
- Forbidden claims: no broad "existing methods fail" claims without direct evidence.
- Style constraints: grouped by method families, not paper-by-paper listing.
- Paragraph-level outline: task-related methods; technique-related methods; closely related methods.

## Methods

- Section: Methods
- Reference path(s) read: `references/section-writing/methodology.md`
- Purpose in the paper: Explain the design logic and closed mechanism of the proposed method.
- Required content moves: problem formulation; method overview; core modules; training/inference or scoring.
- Required terminology: frozen method/module names only.
- Forbidden terminology or internal traces: no routine configuration unless it determines the method.
- Required evidence links: design claims linked to planned ablations or diagnostics.
- Forbidden claims: no performance or deployment conclusions.
- Style constraints: problem -> design -> mechanism -> output, with formula explanations.
- Paragraph-level outline: formulation; overview; module subsections; objective/inference.

## Experiments

- Section: Experiments
- Reference path(s) read: `references/section-writing/experiments.md`
- Purpose in the paper: Test the claims and define evidence boundaries.
- Required content moves: setup; main comparison; ablations; diagnostics; sensitivity or limitations.
- Required terminology: metrics, datasets, and variants match `result_audit.md`.
- Forbidden terminology or internal traces: no raw file paths, script names, or defensive result language.
- Required evidence links: `result_audit.md`, tables, figures, logs, and claim IDs.
- Forbidden claims: no conclusion without source table/figure/result audit support.
- Style constraints: state ranks, deltas, affected metrics, and bounded conclusions.
- Paragraph-level outline: protocol; main result; module evidence; analysis; limitations.

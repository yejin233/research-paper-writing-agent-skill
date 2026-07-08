# Manuscript Intent

- Frozen paper type: method_paper
- User-approved thesis: One sentence describing the method paper's central claim.
- Required introduction arc:
  1. Task and persistent challenge.
  2. Existing paradigm and concrete failure phenomenon.
  3. Mechanism gaps.
  4. Method mapped to gaps.
  5. Factual contribution list.
- Required methodology blueprint:
  1. Problem Formulation.
  2. Method Overview.
  3. Core Modules.
  4. Training Objective / Inference Procedure.
  5. Optional Algorithm or Complexity Analysis.
- Required core method claim: The method addresses a specific modeling object, constraint, or evidence source.
- Allowed claim weakenings: Conditional or dataset-scoped claims supported by evidence.
- Forbidden paper-type conversions: boundary_study, survey, benchmark, position, negative_result.
- Reframe policy: Mark reframe_required and stop manuscript expansion.
- Kill conditions:
  - Core ablation contradicts the claimed mechanism.
  - Simple baseline is not worse on the primary metric.
  - Improvement is explained only by unacceptable cost transfer.


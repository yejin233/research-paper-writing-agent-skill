# Experiment Analysis Audit

## Experiment Analysis Unit: exp-main

- Experiment: Main comparison on the declared benchmark.
- Claim tested: C1, the proposed mechanism improves the primary metric under the frozen protocol.
- Reviewer question answered: Does the proposed mechanism beat the strongest and closest baselines on the declared primary metric rather than only improving over a weak control?
- Primary observation: Ours ranks first on the primary metric with a 0.09 absolute delta over the strongest baseline in Table 1.
- Strongest baseline comparison: StrongBase reaches 0.82 F1 while Ours reaches 0.91 F1 under the same metric direction and evaluation split.
- Mechanism interpretation: The gain appears in the condition where the proposed mechanism changes the target behavior, which is consistent with the mechanism claim.
- Alternative explanation: The improvement may come from extra compute, threshold selection, or a dataset-specific patch rather than the proposed mechanism.
- Evidence against alternative explanation: The compute-matched control, fixed-threshold control, and removal ablation do not reproduce the same delta.
- Boundary condition: The result supports C1 only for the declared benchmark, metric, and frozen protocol; it does not establish deployment-scale generality.
- Failure or weak case: The method does not win on the secondary metric, so that metric should be reported as a boundary rather than hidden.
- Claim implication: Supports C1 for the primary metric under the declared protocol and supports only a bounded mechanism claim.
- Required prose: State the rank, 0.09 delta, strongest-baseline comparison, mechanism interpretation, secondary-metric boundary, and exact claim implication.

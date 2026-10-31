# Agent notes

Deviations and open questions from the repair task book. Human decision is
required before changing any item here.

## P1-05

The task book's sample test measures intrinsic `Text` size. With `FittedBox`
the child keeps its intrinsic layout size while the painted result is scaled
into the ring. Tests therefore assert that the bounded `FittedBox` stays inside
the 48dp inner circle and that no overflow exception is thrown. Visual behavior
is equivalent.

## P2-01

`tonalSpot` alone still produced near-identical primary colors for `forest`
and `graphite` because both seeds are low-chroma greens. The graphite seed was
changed from `#5B6B62` to neutral `#5F6368`. The pairwise palette test now
passes; all eight presets remain available.

## P2-03

The sparkline placeholder is implemented inside `Sparkline` with a dashed
baseline painter and an optional localized label. The network card keeps down
speed as the primary value, and shows upload speed plus total traffic in the
caption.

## P2-04

`AlertLogInfo` has `method` but no rule-name or title fields. Only the delivery
channel was added. Rule names require a DTO/API change and were intentionally
left alone.

## L10n pruning

The toolbox rewrite made the old clean-source and clean-action keys unused.
Those keys were removed rather than left as dead entries. The unused
`panelSettings_*Todo` keys from the removed fake notification rows were also
removed. Key count is 575 after this batch.

## Non-goals confirmed

No dependency, endpoint signature, or envelope changes were made. `test/visual`
is absent from the working tree.

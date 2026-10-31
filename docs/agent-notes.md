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

`tonalSpot` alone pulled the graphite seed toward blue and collided with
`ocean`. Graphite now keeps its original seed `#5B6B62` and uses
`DynamicSchemeVariant.neutral`, so its primary stays a low-saturation gray. The
pairwise test excludes graphite from hue comparison and separately asserts
saturation below 0.2.

## P2-03

`Sparkline` and `AreaChart` both show the localized collecting state below
three samples. The large network chart hides its grid instead of drawing a
baseline. A sparkline without a label renders nothing rather than an unlabeled
dashed divider. The network card keeps down speed as the primary value and
shows upload speed plus total traffic in a two-line caption.

## P2-04

`AlertLogInfo` has `method` but no rule-name or title fields. Only the delivery
channel was added. Rule names require a DTO/API change and were intentionally
left alone.

## P1-01 guard

The original single-line grep missed multiline calls. `tool/check_error_leaks.sh`
now checks a three-line window around `AppToast.error`, raw assignments to
`_error`, and direct `Text('$error')` rendering. The same rule runs as a Dart
test, so it executes inside `flutter test` in CI.

## L10n pruning

The toolbox rewrite made the old clean-source and clean-action keys unused.
Those keys were removed rather than left as dead entries. The unused
`panelSettings_*Todo` keys from the removed fake notification rows were also
removed. Key count is 575 after this batch.

## Non-goals confirmed

No dependency, endpoint signature, or envelope changes were made. `test/visual`
is absent from the working tree.

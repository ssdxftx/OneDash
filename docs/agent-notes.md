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

## R1 network card

The network card no longer carries a sparkline because the 160dp chart directly
below it shows the same data. The caption keeps upload speed and total traffic
in two lines. CPU and memory only render sparklines once three samples exist.

## L10n pruning

The toolbox rewrite made the old clean-source and clean-action keys unused.
Those keys were removed rather than left as dead entries. The unused
`panelSettings_*Todo` keys from the removed fake notification rows were also
removed. Key count is 575 after this batch.

## Non-goals confirmed

No dependency, endpoint signature, or envelope changes were made. `test/visual`
is absent from the working tree.

## 1Panel v2.4.2 P0

- `hosts/firewall/rules/search` rejects `all=true` with empty `scopes`
  (`FW_SCOPE_UNSUPPORTED`). The client now always sends the full managed scope
  list for the active backend.
- `POST /containers` rejects `networks: []` with `please set up the network`.
  The task book sample omitted this field; the create form now defaults to
  `1panel-network` and loads the panel network list.
- Forward rule editing is implemented as `remove` of the old rule followed by
  `add` of the new rule, matching the panel frontend.
- The hosted lab does not expose test container port 18080 externally. Container
  creation was verified through the panel API (running state and published
  ports), not through a browser request.
- No Android device or emulator is available in this workspace, so the new
  full-screen forms were validated by analyzer, tests, route smoke coverage and
  real API calls rather than device screenshots.

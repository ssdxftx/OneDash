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

## 1Panel v2.4.2 P1

- The lab panel has only MySQL instances installed (one local, one remote).
  PostgreSQL and MongoDB create/delete/password/bind paths were implemented
  against the v2.4.2 Swagger contract but could not be exercised on the lab
  panel without installing two additional apps.
- `POST /files/depth/size` returns an array of per-child sizes plus the
  requested directory. The client picks the entry whose `path` matches the
  requested directory, so the directory row shows the aggregate size.
- Terminal sessions are listed and closed from the terminal app bar. The
  endpoints are `/hosts/terminal/sessions/search`, `/close` and `/closeAll`
  (`agent/router/ro_host.go:91-93`). The list only shows sessions for the current
  auth session, matching the panel frontend.
- SSH changes are saved through `/hosts/ssh/update`. `/hosts/test/byid` tests a
  saved host record and the current panel server is not one, so port changes use
  the panel-local `/settings/ssh/check` endpoint before and after saving. The
  form still validates the port as a number.
- ClamAV and Fail2ban are not installed on the lab panel. Their pages, scan task
  creation (including the none/remove/move/copy infected-file strategy),
  service toggles, unban actions and scan record lists are implemented but the
  install / EICAR / ban acceptance flow still needs a panel with those tools
  installed. ClamAV installation itself is an OS package step; the panel API
  only starts, stops and restarts the installed service.
- Chunked upload uses the v2.4.2 resumable fields `uploadID`, `offset` and
  `fileSize`. Pause cancels the in-flight request and keeps the temporary part;
  resume continues from the last completed offset. Cancel calls
  `/files/chunkupload/stop` to remove the temporary part.
- SSH key generation and deletion are available in the host page. The generated
  private key is never rendered; only the key name and type are listed.
- PHP FPM configuration is edited through the five `pm.*` fields that the panel
  frontend exposes. Arbitrary FPM parameters are outside this form.
- The PHP extension tab has an explicit refresh action so installed state can be
  reloaded. The panel has no per-extension version-update endpoint; updates are
  install/uninstall plus this refresh.
- No Android device or emulator is available. New pages are covered by
  analyzer, unit/widget tests, route smoke tests, and read-only real API probes.

## 1Panel v2.4.2 P2

- The host page now has four tabs: monitoring, SSH, disks and diagnostics.
- Firewall settings now expose backend switching, whitelist editing, rule
  backups/restore/reset and the native firewalld/ufw detail reader. Native detail
  is only meaningful when the panel uses firewalld or ufw; the lab uses
  iptables, so that path is contract-tested only.
  Disks read `/hosts/disks`; diagnostics read `/hosts/diagnostics/summary` and
  `/hosts/diagnostics/goroutines`.
- Disk partition, mount and unmount follow the v2.4.2 request shapes. Partition
  and unmount require typing the device or mount point before submission, and
  mount also asks for confirmation. These destructive paths were not executed
  against the shared lab panel; only `GET /hosts/disks` was exercised.
- Runtime profile capture uses `POST /hosts/diagnostics/profiles` with
  `ResponseType.bytes` and saves the returned pprof file through the system
  save dialog. No new dependency was added.
- `/hosts/components/:name` has no standalone page in v2.4.2; the panel only
  uses it from file AI search to check `ffmpeg`. The diagnostics tab now exposes
  a small component check with an editable name, defaulting to `ffmpeg`. The
  raw executable error string is not rendered; a localized "not found" label is
  shown instead.
- Fail2ban basic rules can be edited from the toolbox page: port, max retries,
  ban time, find time, ban action and log path. The lab panel does not have
  Fail2ban installed, so these writes could not be exercised end to end.
- No Android device or emulator is available. New tabs are covered by analyzer,
  DTO unit tests, route smoke tests and read-only API probes.

## 1Panel v2.4.2 D batch (partial)

- The dashboard quick-action grid now has nine entries, adding websites,
  containers and installed apps to the existing six.
- Website detail has a load-balancing tab backed by `/websites/:id/lbs` and the
  create, update and delete endpoints. The form covers name, algorithm, server
  address, weight, status, max failures, fail timeout and max connections.
- Load balancing was exercised read-only on the lab panel. The two probed sites
  returned `data: null` for `/lbs`, which the client renders as an empty list.
  Create, update and delete were not executed because they would modify an
  existing site.
- Website templates are available from the websites app bar. The page supports
  listing, filtering, create/edit/delete, single-page HTML with variable
  auto-detection, multi-file ZIP upload, variable metadata, and generating a
  site from a template. Generated sites are listed in a sheet and can be
  deleted. Template preview is not rendered in the app because there is no
  WebView dependency; generation still uses the panel API.
- AI is implemented as file content search from the files app bar. It calls
  `/files/ai-search`, supports recursive search, case, whole-word and regex
  options, shows grep hits, and renders the AI summary when the panel has file
  AI enabled. The app never stores or asks for model credentials; it uses the
  panel's existing AI account setting. The separate Agent/model/GPU/MCP module
  is outside this batch.

## v6 验收回执

- v6 报告称 `POST /containers` 返回 `{taskID}`；v2.4.2 源码
  `agent/app/api/v2/container.go` 的 `ContainerCreate` 调用
  `helper.Success(c)`，任务 ID 来自请求体 `dto.ContainerOperate.taskID`，
  后台任务由 `ContainerService.ContainerCreate(req, true)` 启动。客户端因此
  使用请求体 taskID 轮询 `/logs/tasks/read`。
- 容器任务最长等待 2 分钟（240 次、500ms 间隔）；失败时保留表单并展示最后
  一行任务日志。
- 页签滚动使用 `Scrollable.ensureVisible`，筛选芯片只共享边缘渐隐实现。
- 网站删除保留选项页，再追加一次域名输入确认。
- 模板 DTO 没有版本字段，模板卡 chip 显示单页/多文件类型。

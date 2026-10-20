# Bloom Habit Tracker — Completion Plan (Beginner-Friendly)

Read `AUDIT_REPORT.md` first. Follow this plan top to bottom. Do not skip Phase 1 — everything later depends on safe data + green tests.

**How to use this file:** work one Step per sitting. Check the box when `How to verify` passes. If a step has ⚠️, read it twice before coding.

## Progress tracker (update as you go)

| Phase | Focus | Steps | Status |
|---|---|---|---|
| 0 | Stabilize workshop (git, baseline) | 0.1–0.3 | ⬜ Not started |
| 1 | Critical bugs & data safety first | 1.1–1.6 | ⬜ Not started |
| 2 | Clean Architecture foundations | 2.1–2.5 | ⬜ Not started |
| 3 | Missing features | 3.1–3.7 | ⬜ Not started |
| 4 | Tests & coverage | 4.1–4.5 | ⬜ Not started |
| 5 | Polish (theme, a11y, l10n, icons, perf) | 5.1–5.6 | ⬜ Not started |
| 6 | Release readiness | 6.1–6.5 | ⬜ Not started |

Total: **7 phases (0–6), 37 steps, ~85–90 hours** for an intermediate dev.

---

## Phase 0 — Stabilize the workshop

### Definition of Done (Phase 0)
- [ ] Working tree is clean, new branch `plan/<phase>` flow understood
- [ ] You can reproduce the red test + describe the 3 crash risks in your own words
- [ ] Baseline `flutter analyze` + `flutter test` outputs saved in a scratch note

---

### Step 0.1 — Commit or stash the dirty tree
1. **Goal:** Start from a known-clean commit.
2. **Files involved:** (git only, no code edits).
3. **What to do:**
   1. Run `git status --short` and `git diff HEAD --stat`.
   2. Commit the current logic work on a branch (e.g. `git checkout -b audit/baseline && git add -A && git commit -m "chore: baseline before completion plan"`), or stash if you prefer.
   3. Push the branch to origin so you have a remote backup.
4. **Why:** The audit found staged-but-uncommitted files (`AM`, `D`). Future refactors (file renames, DI) are dangerous on a dirty tree — you cannot `git bisect` or revert safely.
5. **How to verify:** `git status --short` prints nothing; `git log --oneline -3` shows your baseline commit.
6. **Estimated time:** 30 min.
7. **Dependencies:** None.

### Step 0.2 — Reproduce the red baseline
1. **Goal:** See the failure with your own eyes.
2. **Files involved:** `test/widget_test.dart` (read only).
3. **What to do:**
   1. Run `flutter analyze` (expect: No issues).
   2. Run `flutter test` (expect: 0 passed, 1 failed with `ProviderNotFoundException`).
   3. Open `lib/main.dart` and trace why: `MyApp` → `MainLayout` → `HomeScreen` calls `context.read<HomeCubit>()`, but the test pumps `MyApp` without the `BlocProvider` that `main()` normally adds.
4. **Why:** You learn the difference between “analyzer-clean” and “test-green.” Every later phase uses `flutter test` as its gate, so you must trust the signal.
5. **How to verify:** You can explain in one sentence why `takeException()` is non-null.
6. **Estimated time:** 45 min.
7. **Dependencies:** 0.1.

### Step 0.3 — Map the data flow on paper
1. **Goal:** Draw the current Hive → Repository → Cubit → UI path.
2. **Files involved:** `lib/core/data/habits_repository.dart`, `lib/features/home/cubit/home_cubit.dart`, `lib/features/habits/cubit/habits_cubit.dart`, `lib/features/main_layout.dart` (read only).
3. **What to do:**
   1. On paper/whiteboard draw boxes: `Hive boxes` → `HabitsRepository` → `HomeCubit` + `HabitsCubit` → `HomeScreen` / `HabitsScreen`.
   2. Mark the two `new HabitsRepository()` sites with a star. Mark `streak()` and `fromMap` with a warning triangle.
4. **Why:** Phase 2 will replace the concrete arrows with an interface + single shared instance. If you cannot draw today’s flow, the DI refactor will confuse you.
5. **How to verify:** You can point to the file+line of each arrow without searching.
6. **Estimated time:** 45 min.
7. **Dependencies:** 0.2.

---

## Phase 1 — Critical bugs & data safety first

> Order matters: fix crashes and data loss before features. Each step is small and verifiable.

### Definition of Done (Phase 1)
- [ ] `flutter test` passes (even if only 1–2 tests — red → green)
- [ ] Corrupt Hive rows no longer crash launch (fallback + logged)
- [ ] Rapid habit creation never overwrites
- [ ] Out-of-range `iconIndex`/`period` renders a fallback icon instead of `RangeError`
- [ ] `flutter analyze` still clean

---

### Step 1.1 — Make `HabitItem.fromMap` total (never throw)
1. **Goal:** Corrupt storage degrades gracefully instead of crashing.
2. **Files involved:** Edit `lib/core/data/habit_item.dart`; create `test/habit_item_test.dart` (scratch check, full suite lands in Phase 4).
3. **What to do:**
   1. Change signature to `factory HabitItem.fromMap(Map m)` → validate each key with `as int? ?? fallback` pattern. Suggested fallbacks: `id: -1` (then filter out), `name: 'Untitled'`, `iconIndex: 0`, `goal: 1`, `unit: ''`, `period: 0`, `colorValue: <default>`, `createdAt: 0`.
   2. Add a `bool get isValid => id >= 0 && goal > 0` helper.
   3. In `HabitsRepository.forDay/all/weeks`, filter `where((h) => h.isValid)`.
   4. ⚠️ Be careful: do not silently “fix” data by writing fallbacks back to Hive yet — only filter in memory. Migration writes come in Phase 2.
4. **Why:** Concept: *parse, don’t validate later*. Storage is untrusted input like a network response. Total parsers keep one bad row from bricking the app.
5. **How to verify:** `flutter test test/habit_item_test.dart` with cases: valid map, missing keys, wrong types (`{'id':'x'}`) — expect no throw, fallback object. `flutter analyze` clean.
6. **Estimated time:** 2 h.
7. **Dependencies:** 0.3.

### Step 1.2 — Harden `streak()` and log parsing
1. **Goal:** `streak()` never throws on orphan/garbage log keys.
2. **Files involved:** Edit `lib/core/data/habits_repository.dart` (`streak()` ~lines 52–72).
3. **What to do:**
   1. Wrap key parsing in a helper like `({int id, String day}?) tryParseLogKey(String key)` returning `null` on bad split / `int.tryParse` failure.
   2. Replace `as int` with `final v = _logs.get(key); if (v is! int) continue;`.
   3. Skip goals missing from `goals` map (deleted habits) instead of crashing.
   4. Document current semantics in a doc comment: “counts days where ANY habit hit goal — see M1, spec to confirm in 3.6.”
4. **Why:** Same “untrusted storage” lesson. `int.parse` throws; `int.tryParse` returns null. Prefer the latter at boundaries.
5. **How to verify:** Manual unit check (throwaway test): insert keys `'badkey'`, `'1|not-a-date'`, `'999|2026-01-01' → 5` into a temp box, call `streak()` — expect a number, no exception.
6. **Estimated time:** 1.5 h.
7. **Dependencies:** 1.1.

### Step 1.3 — Fix ID collisions with `uuid`
1. **Goal:** Every habit gets a collision-proof identity.
2. **Files involved:** Edit `lib/core/data/habit_item.dart` (change `id` type decision), `lib/features/home/presentation/widgets/habit_draft.dart` (`_submit` ~line 62); read `pubspec.yaml:17`.
3. **What to do:**
   1. Decide: **Option A (recommended):** change `HabitItem.id` from `int` (millis) to `String` UUID (`const Uuid().v4()`). Update `toMap/fromMap`, repository key `_k`, `delete/setProgress/update` signatures. **Option B:** keep `int` but combine `millis + random` and loop until unused. Option A is cleaner long-term.
   2. ⚠️ Be careful: changing `id` type is a **breaking storage migration**. In this step, support reading old `int` ids (accept `m['id'] is int → toString()`) but write new `String` ids. Full migration helper lands in 2.2.
   3. If you keep `int`, at minimum use the already-declared `uuid` package or remove it from `pubspec.yaml` to avoid dead deps.
4. **Why:** Concept: *identity ≠ timestamp*. Timestamps collide; UUIDs don’t. This prevents silent overwrites (data loss).
5. **How to verify:** Rapid-fire script/button: create 20 habits in a loop, assert 20 distinct ids and 20 rows in box. `grep -rn "uuid" lib/` now hits.
6. **Estimated time:** 2–3 h (3 h if switching to String).
7. **Dependencies:** 1.1.

### Step 1.4 — Clamp icon/period indexes at the UI boundary
1. **Goal:** Bad indexes show a fallback, never `RangeError`.
2. **Files involved:** Edit `lib/core/constants/constants.dart` (add `safeHabitIcon(int)`, `safePeriod(int)` helpers), `lib/features/home/presentation/views/home_screen.dart:34,95`, `lib/features/habits/presentation/widgets/habit_overview_card.dart:49,77`.
3. **What to do:**
   1. Add helpers, e.g. `IconData safeHabitIcon(int i) => habitIcons[i % habitIcons.length]` — better: `i >= 0 && i < length ? habitIcons[i] : habitIcons[0]`. Same for periods + colors.
   2. Replace all direct `habitIcons[x]` / `periods[x]` call sites.
   3. Add a `debugPrint` or `assert` in debug mode when fallback triggers so you notice bad data.
4. **Why:** Concept: *defend at the boundary*. Repository may return legacy values; UI must never trust array positions blindly.
5. **How to verify:** Temporarily craft a `HabitItem(iconIndex: 99, period: 99)` in a widget test — expect render, no exception.
6. **Estimated time:** 1 h.
7. **Dependencies:** 1.1.

### Step 1.5 — Guard Hive init order (fail fast with message)
1. **Goal:** Constructing the repository before `init()` gives a clear error, not a cryptic `HiveError`.
2. **Files involved:** Edit `lib/core/data/habits_repository.dart` (constructor + `init()`).
3. **What to do:**
   1. Make the constructor private (`HabitsRepository._()`) + a factory that checks `Hive.isBoxOpen('habits') && Hive.isBoxOpen('logs')` and throws `StateError('Call HabitsRepository.init() first')` with that exact message.
   2. Keep `static Future<void> init()` as the single opener.
   3. Do not yet introduce DI — that’s Phase 2. This step only makes the current pattern explicit.
4. **Why:** Concept: *fail fast*. A clear message at construction saves hours vs. a stack trace deep in `forDay`.
5. **How to verify:** New test expects `StateError` when boxes closed; `flutter test` passes when `init()` called first. Manual: comment out `await HabitsRepository.init()` in `main.dart`, run — expect your message.
6. **Estimated time:** 1 h.
7. **Dependencies:** 1.2.

### Step 1.6 — Fix the red widget test (minimal green)
1. **Goal:** CI goes red → green with a truthful test.
2. **Files involved:** Edit `test/widget_test.dart`; read `lib/main.dart`, `lib/features/main_layout.dart`.
3. **What to do:**
   1. In `setUpAll`, call `Hive.initFlutter()` with a temp dir (see `hive_ce_flutter` docs + `path_provider` temp) OR structure `MyApp` to accept an injected repository (preferred, forward-compatible with Phase 2). Minimal path: init Hive in test, open boxes, provide `BlocProvider<HomeCubit>` above `MyApp`, or pump `MainLayout` inside the provider.
   2. Update expectations to English labels: `Today`, `My habits`, `Progress`, `Discover`. Remove the `الرئيسية` assertion.
   3. Keep the test tiny: “renders NavigationBar + 4 destinations, no exception.”
   4. ⚠️ Be careful: widget tests share Hive boxes — always `tearDown` with `Hive.deleteFromDisk()` / unique temp path per run, or tests pollute each other.
4. **Why:** Concept: *test the wiring you ship*. `main()` adds the provider; the test must replicate that wiring.
5. **How to verify:** `flutter test` → All tests passed. `flutter test --coverage` generates `lcov.info` with hits > 0.
6. **Estimated time:** 2 h.
7. **Dependencies:** 1.5.

---

## Phase 2 — Clean Architecture foundations

> Do not add features here. Restructure so features become easy + testable.

### Definition of Done (Phase 2)
- [ ] `domain/` has entities + abstract repo + failures + use cases; `data/` implements the interface
- [ ] Single shared repository instance via DI; no `HabitsRepository()` in UI files
- [ ] Navigation preserved; `flutter analyze` + `flutter test` green
- [ ] Old Hive data still loads (backward compat verified manually)

---

### Step 2.1 — Extract domain entities + failures
1. **Goal:** Pure-Dart domain with no Hive/Flutter imports.
2. **Files involved:** Create `lib/core/domain/entities/habit.dart` (move `HabitItem/HabitProgress/HabitWeek` there or wrap them), `lib/core/domain/entities/user.dart` (just `name`), `lib/core/error/failures.dart` (`StorageFailure`, `NotFoundFailure` with `message`).
3. **What to do:**
   1. Copy classes over, keep `dayKey/lastDays` as domain helpers (they’re pure date logic).
   2. Add `isValid` + `copyWith` to `HabitItem` if missing.
   3. Leave old `core/data/habit_item.dart` as a deprecated re-export (`export '../../domain/entities/habit.dart'`) for one phase, then delete.
4. **Why:** Concept: *dependency rule* — inner layers (domain) know nothing of outer layers (Hive). This lets you unit-test business rules without a device.
5. **How to verify:** `grep -rn "hive\|flutter" lib/core/domain/` returns nothing. `flutter analyze` clean.
6. **Estimated time:** 2 h.
7. **Dependencies:** 1.6.

### Step 2.2 — Define the repository interface + DTO mapping
1. **Goal:** UI depends on an abstraction, Hive lives behind it.
2. **Files involved:** Create `lib/core/domain/repositories/habits_repository.dart` (abstract class with `forDay/setProgress/streak/weeks/all/add/delete/update` returning `Future` or `Either<Failure,T>` — pick one and stick to it), edit `lib/core/data/habits_repository.dart` to `implements` it; create `lib/core/data/datasources/habits_local_datasource.dart` if the file gets >150 lines.
3. **What to do:**
   1. Write the abstract method signatures first (copy current concrete ones).
   2. Make concrete class implement them; move raw `Box` access into datasource, mapping `Map ↔ HabitItem` in one place.
   3. Handle int→String id migration here (read both, write new).
   4. ⚠️ Be careful: changing return types to `Either` ripples through cubits — if that feels big, start with `Future` + throws, then migrate to `Either` in one dedicated commit.
4. **Why:** Concept: *Dependency Inversion* — high-level policy (cubits) should not depend on low-level details (Hive). The interface is the seam that lets you fake storage in tests.
5. **How to verify:** `grep -rn "HabitsRepository()" lib/features/` returns nothing after 2.3; cubits import `domain/repositories/…`, not `data/…`.
6. **Estimated time:** 3 h.
7. **Dependencies:** 2.1.

### Step 2.3 — Add a service locator (single shared instance)
1. **Goal:** One repository, one datasource, injectable cubits.
2. **Files involved:** Add `get_it: ^8.0.0` (or `^7.x` matching Dart 3.13) to `pubspec.yaml`; create `lib/core/di/injection.dart` with `Future<void> configureDependencies()`; edit `lib/main.dart`, `lib/features/habits/presentation/views/habits_screen.dart`.
3. **What to do:**
   1. Register: datasource (lazy singleton) → repository impl as interface → cubits as factories.
   2. `main()` calls `await HabitsRepository.init(); await configureDependencies();` then `BlocProvider(create: (_) => sl<HomeCubit>())`.
   3. `HabitsScreen` reads `sl<HabitsCubit>()` instead of `new HabitsRepository()`.
   4. Keep it tiny — no code-gen (`injectable`) yet.
4. **Why:** Concept: *composition root*. Object graph is built in one place (`main`), not scattered in widgets. Testing = swap registration with a fake.
5. **How to verify:** App launches, both tabs show same data; adding a habit on one tab appears on the other without manual `reload()` hacks (keep the call for now, but data matches). `flutter test` green.
6. **Estimated time:** 2 h.
7. **Dependencies:** 2.2.

### Step 2.4 — Introduce use cases for the core loops
1. **Goal:** Business rules live in named, testable units.
2. **Files involved:** Create `lib/core/domain/usecases/{get_day_habits.dart, toggle_habit.dart, add_habit.dart, get_streak.dart, get_weeks.dart}` (each: `Future<X> call(params)`); edit both cubits to call them.
3. **What to do:**
   1. Each use case takes the abstract repository, does one thing (e.g. `ToggleHabit` computes `0 ↔ goal` and calls `setProgress`).
   2. Cubits become thin: `emit(loading) → await usecase → emit(data) / emit(error)`.
   3. Add a `HomeState.status {initial, loading, loaded, error}` + `errorMessage` field now (UI shows it in Phase 3).
4. **Why:** Concept: *use case = one user intention*. It names the rule (“toggle means…”) so future devs (you in 3 months) find it instantly.
5. **How to verify:** Existing widget test still passes; new unit test calls `AddHabit` on a fake repo and asserts `forDay` contains it.
6. **Estimated time:** 3 h.
7. **Dependencies:** 2.3.

### Step 2.5 — Preserve tabs with `IndexedStack` + refresh `days` window
1. **Goal:** Tab switches keep scroll + always show the current 7-day window.
2. **Files involved:** Edit `lib/features/main_layout.dart` (`body`), `lib/features/habits/cubit/habits_cubit.dart` (`days`).
3. **What to do:**
   1. Replace `body: _pages[i]` with `IndexedStack(index: i, children: _pages)` and hoist `_pages` to a `late final` in `initState` so providers aren’t recreated.
   2. Change `HabitsCubit.days` from `final … = lastDays(7)` to a getter or recompute in `load()` (`days = lastDays(7)` each call).
   3. Verify no duplicate `BlocProvider` creation per switch (add a `print` in `create` temporarily, switch tabs, expect single call).
4. **Why:** Concept: *state preservation*. `IndexedStack` keeps all tabs alive; recreating providers on every switch wastes IO and loses scroll.
5. **How to verify:** Manual: scroll My Habits, switch to Discover and back — scroll offset kept; leave app overnight (or mock clock) — week strip shows today. `flutter analyze` clean.
6. **Estimated time:** 1.5 h.
7. **Dependencies:** 2.3.

---

## Phase 3 — Missing features

### Definition of Done (Phase 3)
- [ ] Edit + delete habit work end-to-end with confirm dialog
- [ ] Username persists across restarts, greeting uses it
- [ ] Partial progress (e.g. 5/8) recordable, not just toggle
- [ ] Progress tab shows real weekly completion + streak; Discover tab shows starter suggestions that add in one tap
- [ ] No `Placeholder`, no dead edit buttons, no “browser” copy

---

### Step 3.1 — Wire edit + delete (finish `showHabitSheet`)
1. **Goal:** Tapping pencil edits; delete asks confirm then cascades logs.
2. **Files involved:** Edit `lib/features/home/presentation/widgets/habit_draft.dart`, `lib/features/habits/presentation/widgets/habit_overview_card.dart`, `lib/features/habits/presentation/views/habits_screen.dart`; add use cases `update_habit.dart`, `delete_habit.dart`.
3. **What to do:**
   1. In `_ShowHabitSheetState.initState`, if `widget.initial != null`, prefill `_name/_goal/_unit/_icon/_period/_color` from it; change submit to preserve `id/createdAt` when editing; add a red “Delete habit” button visible only when `onDelete != null` + a confirm `AlertDialog`.
   2. Pass `onEdit: () => showHabitSheet(context, initial: week.habit, onSave: …, onDelete: …)` and `onView` (push a detail sheet or highlight — simplest: open the same sheet in edit mode).
   3. After update/delete, reload both cubits (or better: expose a shared stream — keep manual reload for now, note the tech debt).
   4. ⚠️ Be careful: `delete` must also delete `logs` prefix (already does) — verify with a test, or orphan rows inflate `streak`.
4. **Why:** Concept: *complete the CRUD loop*. Create-without-update/delete strands user data (cannot fix typos).
5. **How to verify:** Manual: create → edit name/goal → reopen shows new values; delete → disappears from both tabs; `flutter test` new case: delete cascades logs.
6. **Estimated time:** 4 h.
7. **Dependencies:** 2.4.

### Step 3.2 — Persist username (replace `debugPrint`)
1. **Goal:** “Your little space” actually remembers you.
2. **Files involved:** Create `lib/core/data/datasources/settings_datasource.dart` (Hive box `settings`, key `username`) + `lib/core/domain/usecases/{get_username, save_username}.dart`; edit `lib/features/main_layout.dart:57-76`, `lib/features/home/presentation/views/home_screen.dart:52`, `lib/features/home/presentation/widgets/show_name_sheet.dart`.
3. **What to do:**
   1. Open box `settings` in `HabitsRepository.init()` (or a new `SettingsRepository`).
   2. Load name in `HomeCubit` state (`userName`) or a tiny `SettingsCubit`; greeting becomes `'Hello, $name'` with fallback `'Hello, friend'`.
   3. Fix copy: “stay in this browser” → “stay on this device.”
4. **Why:** Concept: *settings are data too* — same repository pattern, different box. Users forgive missing features, not fake ones.
5. **How to verify:** Manual: set name → kill app → relaunch → greeting persists. Widget test asserts greeting contains saved name.
6. **Estimated time:** 2 h.
7. **Dependencies:** 2.4.

### Step 3.3 — Partial progress input (beyond toggle)
1. **Goal:** Record 5/8, not just done/not-done.
2. **Files involved:** Edit `lib/features/home/cubit/home_cubit.dart` (add `setAmount(HabitProgress, int)`), `lib/features/home/presentation/widgets/daily_habit.dart` (add long-press or +/- affordance), `lib/core/domain/usecases/toggle_habit.dart` (keep toggle for quick tap).
3. **What to do:**
   1. Add `Future<void> setAmount(e, amount)` → `repo.setProgress(id, date, amount.clamp(0, goal))` → refresh.
   2. UI: tapping the circle still toggles; tapping the card opens a small bottom sheet/dialog with `- amount +` stepper + Slider (max = goal) + Save. Keep it one file (`lib/features/home/presentation/widgets/amount_sheet.dart`).
   3. Subtitle already handles `done/goal` — verify it now actually appears.
4. **Why:** Concept: *match the model to the gesture*. Quick tap = binary; detail edit = quantity. Habit trackers live or die on low-friction logging.
5. **How to verify:** Manual: set 5/8 → subtitle shows `5/8`, ring counts as not-done; set 8/8 → done. Unit test: `setProgress` clamps negatives to 0 and caps at goal (decide cap spec first).
6. **Estimated time:** 3 h.
7. **Dependencies:** 3.1.

### Step 3.4 — Build the Progress tab (real data, no placeholder)
1. **Goal:** Weekly completion % + streak + per-habit bars.
2. **Files involved:** Edit `lib/features/progress/presentation/views/progress_screen.dart`; create `lib/features/progress/cubit/progress_cubit.dart` + widgets `weekly_chart.dart` (simple `CustomPaint` bars, no new chart package yet).
3. **What to do:**
   1. Reuse `get_weeks` + `get_streak` use cases: state = `{days, weeks, totalDone, totalPossible, streak}`.
   2. UI top: big ring (% this week) + streak pill (reuse `DailySummary`/`ProgressRing`); middle: 7 bars (done/total per day); bottom: per-habit rows with `WeekStrip`.
   3. Wire `WeekCalendar(hasActivity: ...)` here if useful — compute “any done that day.”
4. **Why:** Concept: *reuse, don’t rebuild*. Progress is a different view over the same `weeks()` query — no new storage needed.
5. **How to verify:** Manual: toggle habits today → bars/ring update; empty state shows friendly copy (no crash on divide-by-zero — guard `total == 0`). `flutter test` widget: zero-habits renders empty state.
6. **Estimated time:** 5 h.
7. **Dependencies:** 2.4, 3.3.

### Step 3.5 — Build the Discover tab (starter habits)
1. **Goal:** One-tap templates that respect the existing add flow.
2. **Files involved:** Edit `lib/features/discover/presentation/views/discover_screen.dart`; create `lib/core/constants/starter_habits.dart` (list of ~8 presets: name, iconIndex, goal, unit, period, colorIndex).
3. **What to do:**
   1. Cards with icon + name + “Add” button → constructs `HabitItem` (new UUID) → same `AddHabit` use case → snackbar “Added — see Today.”
   2. Hide/dim presets already added (match by name, case-insensitive).
   3. No backend — static list is fine for v1.
4. **Why:** Concept: *onboarding via content*. New users with zero habits churn; templates give them a first win in 10 seconds.
5. **How to verify:** Manual: fresh install (clear app data) → Discover → Add 2 → they appear Today + My Habits. No duplicates on double-tap (disable button while saving).
6. **Estimated time:** 3 h.
7. **Dependencies:** 2.4.

### Step 3.6 — Lock the streak spec + surface it
1. **Goal:** Decide and document what “streak” means, then implement it.
2. **Files involved:** Edit `lib/core/data/habits_repository.dart` (`streak()`), `lib/core/domain/usecases/get_streak.dart`; add `test/streak_test.dart` (full version in Phase 4).
3. **What to do:**
   1. Choose: **A)** any-habit-done (current), **B)** all-habits-done, **C)** ≥50% of habits or ≥1 “keystone” habit. For a solo tracker, **B** is most honest but harsh for beginners; **C** is a good compromise — pick one and write it in a comment + README line.
   2. Implement + unit tests: empty → 0, today done → 1, yesterday+today → 2, gap → reset, future logs ignored.
   3. ⚠️ Be careful: changing streak semantics will surprise existing testers — note it in release notes.
4. **Why:** Concept: *metrics need definitions*. An undefined streak is a vanity number; a defined one is a contract you can test.
5. **How to verify:** `flutter test test/streak_test.dart` — 5 cases above all pass.
6. **Estimated time:** 2 h.
7. **Dependencies:** 2.4.

### Step 3.7 — Empty states + error states that teach
1. **Goal:** No blank screens, no silent failures.
2. **Files involved:** Edit `home_screen.dart:82-86`, `habits_screen.dart:57-58`, `daily_summary.dart`, plus cubits’ new `status/errorMessage` (from 2.4).
3. **What to do:**
   1. Empty Today: keep copy + add “Browse starters” button → jumps to Discover tab (needs a callback like `onDiscoverTap`).
   2. Error: if cubit `status == error`, show a retry row (`Something didn’t load — Retry`) calling `reload()/load()`.
   3. Convert `DailySummary` + `TitleAndCountWidget` to `StatelessWidget` while here (they hold no state).
4. **Why:** Concept: *empty/error are first-class states*, not afterthoughts. They teach the next action.
5. **How to verify:** Manual: clear data → empty copy + button works; simulate error (throw in fake repo) → retry renders. `flutter analyze` clean.
6. **Estimated time:** 2 h.
7. **Dependencies:** 3.4, 3.5.

---

## Phase 4 — Tests & coverage

> Target: **≥70% line coverage** on `domain + data + cubits`, all widget critical paths, 1 integration flow. No new features in this phase.

### Definition of Done (Phase 4)
- [ ] `flutter test` green, `flutter test --coverage` shows ≥70% on core logic
- [ ] Fakes (not real Hive) used in unit/bloc tests; real Hive only in 1–2 datasource tests with temp dirs
- [ ] CI gate (Phase 6) can rely on this suite

---

### Step 4.1 — Unit tests: entities + helpers + failures
1. **Goal:** Pure logic pinned down.
2. **Files involved:** Create `test/domain/habit_test.dart`, `test/core/day_key_test.dart`.
3. **What to do:**
   1. `dayKey` zero-padding, `lastDays` length/order/ends-today/month-boundary.
   2. `HabitItem` round-trip `toMap→fromMap`, corrupt-map fallbacks, `isValid`, `copyWith`.
   3. `HabitProgress.isDone` boundary (done == goal → true, goal-1 → false).
4. **Why:** Concept: *test the cheapest layer first*. Pure functions need no mocks and catch date bugs that only appear on month edges.
5. **How to verify:** `flutter test test/domain test/core` → all passed.
6. **Estimated time:** 2 h.
7. **Dependencies:** 2.1.

### Step 4.2 — Repository tests with fake Hive (temp boxes)
1. **Goal:** `forDay/streak/weeks/delete-cascade` locked.
2. **Files involved:** Create `test/data/habits_repository_test.dart` (+ `test/test_helpers.dart` for `setUpAll/tearDownAll` temp-dir Hive helpers).
3. **What to do:**
   1. Use `Hive.init('<tempdir>')` (not `initFlutter`) in tests; open/close/delete boxes per test.
   2. Cases: `forDay` filters future-created habits + sorts by period; `setProgress` clamps negatives; `delete` removes logs; `weeks` matrix matches manual logs; `streak` per spec from 3.6.
   3. ⚠️ Be careful: never reuse the app’s real box path in tests — always a `Directory.systemTemp.createTemp()` path.
4. **Why:** Concept: *test against the real adapter once*, then fake it everywhere else. Repository tests are the only place real Hive belongs.
5. **How to verify:** `flutter test test/data/` green; mutate one expectation → test fails (proves it asserts something).
6. **Estimated time:** 3 h.
7. **Dependencies:** 4.1, 2.2.

### Step 4.3 — Cubit/bloc tests with fakes
1. **Goal:** State transitions verified without Hive.
2. **Files involved:** Add `bloc_test: ^9.1.0` + `mocktail: ^1.0.0` to `dev_dependencies`; create `test/features/home_cubit_test.dart`, `test/features/habits_cubit_test.dart`.
3. **What to do:**
   1. Implement `FakeHabitsRepository implements HabitsRepository` (in-memory lists) in `test/test_helpers.dart`.
   2. `blocTest`: initial loads items+streak; `selectTab` filters; `selectDate` normalizes time to midnight; `toggle` flips 0↔goal; `setAmount` clamps.
4. **Why:** Concept: *test behavior, not implementation*. Fakes let you simulate “disk error” by throwing — impossible with real Hive.
5. **How to verify:** `flutter test test/features/` green; coverage on `*_cubit.dart` ≥80%.
6. **Estimated time:** 3 h.
7. **Dependencies:** 4.2.

### Step 4.4 — Widget tests for critical paths
1. **Goal:** User-visible contracts pinned.
2. **Files involved:** Create `test/widgets/{habit_card_test.dart, habit_sheet_test.dart, week_calendar_test.dart, navigation_test.dart}`; rewrite `test/widget_test.dart` as the navigation test.
3. **What to do:**
   1. `HabitCard`: tap circle → `onToggle` called once; done renders check.
   2. `ShowHabitSheet`: empty name → button disabled; `goal: 0` → disabled; valid → `onSave` with correct fields.
   3. `WeekCalendar`: back button shifts week; forward disabled at current week; future day untappable.
   4. Navigation: 4 destinations switch `IndexedStack`, FAB opens sheet, Manage jumps to My Habits.
5. **Why:** Concept: *test the contract, not pixels*. Callbacks + disabled states are the API users feel.
6. **How to verify:** `flutter test test/widgets/` green on a clean checkout (delete `build/`, rerun).
7. **Estimated time:** 4 h.
8. **Dependencies:** 4.3.

### Step 4.5 — One integration flow + coverage gate
1. **Goal:** Prove the whole loop on a real device profile.
2. **Files involved:** Create `integration_test/app_flow_test.dart` (+ `integration_test/` dev dep `integration_test` SDK); edit `pubspec.yaml` if needed.
3. **What to do:**
   1. Flow: launch → add habit via sheet → appears Today → toggle → ring increments → restart (re-pump) → persists.
   2. Run `flutter test integration_test --device-id <emulator>` once locally (not on every commit — too slow for CI gate; CI runs unit/widget only).
   3. Set a local coverage check: `lcov --summary coverage/lcov.info` or `very_good_analysis` coverage script; record % in README.
4. **Why:** Concept: *one E2E beats ten isolated tests* for wiring bugs (DI, Hive init, navigation).
5. **How to verify:** Integration passes on emulator; `flutter test --coverage` ≥70% on `lib/core/**` + `lib/features/**/cubit/**`.
6. **Estimated time:** 3 h.
7. **Dependencies:** 4.4.

---

## Phase 5 — Polish (theme, a11y, l10n, icons, perf)

### Definition of Done (Phase 5)
- [ ] No hardcoded hexes/strings in widgets; single `AppTheme` + `AppStrings`
- [ ] TalkBack/VoiceOver pass on Today + My Habits; 48px targets; 1.3× font-scale clean at 320 dp
- [ ] English + one second locale (e.g. Arabic RTL) render correctly
- [ ] Real launcher icon + splash on Android + iOS
- [ ] `flutter run --profile` shows no jank on tab switch with 50 habits (seed script)

---

### Step 5.1 — Centralize theme + kill magic values
1. **Goal:** One source of truth for color/type/shape.
2. **Files involved:** Edit `lib/core/theme/app_colors.dart` (type `border`/`field`, delete `lll` or rename to `lavenderDeep`), create `lib/core/theme/app_theme.dart` (`ThemeData`, `FilledButton`/`InputDecoration`/`NavigationBar` defaults); sweep `lib/` replacing `Color(0xff…)` + inline `TextStyle`s.
3. **What to do:**
   1. Define `AppTheme.light()` with `colorScheme`, `textTheme` (Manrope), component themes; set `MaterialApp(theme: AppTheme.light())`.
   2. Delete the dead commented block in `segmented_tabs.dart:87-116`.
   3. Keep widget-level overrides only where truly one-off (banner gradient).
4. **Why:** Concept: *design tokens*. Changing primary color should be one line, not eight files.
5. **How to verify:** `grep -rn "0xffEEECF2\|0xffF4F2F8" lib/` returns ≤2 hits (only theme file). Screenshots before/after look identical.
6. **Estimated time:** 3 h.
7. **Dependencies:** 3.7.

### Step 5.2 — Accessibility pass
1. **Goal:** Usable with screen readers + large text + small hands.
2. **Files involved:** Edit `daily_habit.dart` (toggle), `habit_overview_card.dart` (edit), `daily_summary.dart` (ring/streak), `week_strip.dart`/`calender_header.dart` (dots/days).
3. **What to do:**
   1. Wrap toggles in `Semantics(label: 'Mark <name> done', toggled: isDone, button: true)` + `ExcludeSemantics` on decorative icons.
   2. Grow hit areas to 48×48 (`SizedBox` + `IconButton` instead of bare `GestureDetector` where possible) while keeping visuals 30–36.
   3. Test at font-scale 1.3 + 320-dp width; fix `SegmentedTabs` overflow with `SingleChildScrollView(horizontal)` or `FittedBox` if needed.
4. **Why:** Concept: *semantics ≠ visuals*. Sighted size can stay compact; the tap target + spoken label must be generous.
5. **How to verify:** Manual TalkBack/VoiceOver swipe-through announces each habit + state; `flutter test` new a11y cases (tap target ≥48 via `tester.getSize` on semantics node).
6. **Estimated time:** 3 h.
7. **Dependencies:** 5.1.

### Step 5.3 — Localization + RTL (English + Arabic)
1. **Goal:** No hardcoded UI strings; RTL mirrors correctly.
2. **Files involved:** Add `flutter_localizations` SDK + `intl` already present; create `lib/l10n/app_en.arb`, `app_ar.arb`; run `flutter gen-l10n`; edit `lib/main.dart` (`localizationsDelegates`, `supportedLocales`).
3. **What to do:**
   1. Enable `generate: true` in `pubspec.yaml` (`flutter: generate: true`), add `l10n.yaml`.
   2. Move ~40 strings (tabs, headers, sheet labels, empty states, “X of Y habits done”, “day streak”) into ARB; use `AppLocalizations.of(context)!`.
   3. Test Arabic: `flutter run --locale ar` — verify `IndexedStack`, calendar row, banner stack mirror; dates use `DateFormat(..., locale)`.
   4. ⚠️ Be careful: string interpolation with plurals (“1 habit” vs “3 habits”) needs ICU plural syntax in ARB — read the `intl` plural docs once before writing.
4. **Why:** Concept: *externalize strings early*. Retrofitting l10n after 100 hardcoded strings costs 3× more.
5. **How to verify:** Toggle device locale EN↔AR, screenshots of Today/Sheet/Progress all render, no overflow. `flutter analyze` clean.
6. **Estimated time:** 5 h.
7. **Dependencies:** 5.1.

### Step 5.4 — Launcher icons + splash + store name
1. **Goal:** Look like a real app on home screens.
2. **Files involved:** Add `flutter_launcher_icons` + `flutter_native_splash` as `dev_dependencies`; edit `pubspec.yaml` config blocks; `android/app/src/main/AndroidManifest.xml` (`android:label`), `ios/Runner/Info.plist` (`CFBundleDisplayName` already “Bloom Habit Tracker” — verify).
3. **What to do:**
   1. Provide a 1024×1024 source icon (reuse `assets/icons/appBarIcon.png` only if ≥512px — else commission/export one), run `dart run flutter_launcher_icons`, `dart run flutter_native_splash:create`.
   2. Set label to `Bloom` (short) on Android, keep `Bloom Habit Tracker` display name on iOS.
   3. Remove unused `Manrope-VariableFont_wght.ttf` or wire it (don’t ship dead bytes).
4. **Why:** Concept: *first impression is the icon*. Default Flutter icons get rejected in design review and confuse testers with multiple Flutter apps.
5. **How to verify:** `flutter run` fresh install shows new icon + splash on Android + iOS; `ls android/app/src/main/res/mipmap-xxxhdpi/` timestamp updated.
6. **Estimated time:** 2 h.
7. **Dependencies:** 5.1.

### Step 5.5 — Performance + image hygiene
1. **Goal:** 60 fps tab switches with realistic data.
2. **Files involved:** Read `lib/features/home/presentation/views/home_screen.dart:87-103` (nested scroll), `assets/images/banner_img.png`; optional `lib/core/widgets/*`.
3. **What to do:**
   1. Seed 50 habits via a debug script, run `flutter run --profile`, flip tabs, record timeline in DevTools — note jank.
   2. If jank: replace `SingleChildScrollView + ListView(shrinkWrap)` with `CustomScrollView + SliverList`, add `RepaintBoundary` around `ProgressRing`, compress `banner_img.png` (`ls -lh` first — if >500 KB, resize/compress to WebP/PNG).
   3. Do not over-optimize — one profiling pass + one fix is enough for v1.
4. **Why:** Concept: *measure, then cut*. `shrinkWrap` is fine for small lists; slivers win when lists grow.
5. **How to verify:** DevTools frame chart shows <16 ms frames on tab switch; `flutter build apk --release` size noted in README.
6. **Estimated time:** 2 h.
7. **Dependencies:** 5.4.

### Step 5.6 — Rename `calender_header.dart` + tidy dead code
1. **Goal:** Professional file names, zero dead code.
2. **Files involved:** Rename `lib/core/widgets/calender_header.dart` → `calendar_header.dart` (IDE refactor, updates 2 imports); delete `AppColors.lll` or rename; remove `cupertino_icons` if you replace 2 usages with Material icons (or keep + document why).
3. **What to do:**
   1. Use IDE “Rename file + update imports” (not manual find/replace).
   2. Run `flutter analyze` + full test suite immediately after.
3. **Why:** Concept: *broken windows*. Typos in filenames signal “nobody tends this garden” to reviewers.
5. **How to verify:** `grep -rn "calender" lib/ test/` returns nothing. All tests green.
6. **Estimated time:** 30 min.
7. **Dependencies:** 5.1.

---

## Phase 6 — Release readiness

### Definition of Done (Phase 6)
- [ ] `Release Checklist` below fully checked
- [ ] Signed `appbundle` + iOS archive build from clean checkout
- [ ] CI green on `main`, crash reporting verified with a test crash
- [ ] Store listing + privacy policy ready

---

### Step 6.1 — Versioning + changelog + metadata
1. **Goal:** Version means something.
2. **Files involved:** Edit `pubspec.yaml` (`version: 0.9.0+1` → `1.0.0+X` at release), `README.md` (replace “A new Flutter project” with real description + screenshots), create `CHANGELOG.md`.
3. **What to do:**
   1. Adopt semver: breaking storage change (String IDs) → minor/major bump note in CHANGELOG.
   2. Write README: what it does, screenshots (EN+AR), `flutter run/test` instructions, streak definition, privacy note (“data stays on device”).
4. **Why:** Concept: *release notes are a contract*. Reviewers + future-you need to know what changed in streak/IDs.
5. **How to verify:** `flutter pub get` succeeds; README renders on GitHub with images.
6. **Estimated time:** 1.5 h.
7. **Dependencies:** 5.6.

### Step 6.2 — Crash reporting + error plumbing (no `debugPrint` in prod)
1. **Goal:** Production crashes reach you.
2. **Files involved:** Add `firebase_crashlytics` (+ `firebase_core`) OR `sentry_flutter` to `pubspec.yaml`; edit `lib/main.dart` (`runZonedGuarded`, `FlutterError.onError`), `lib/features/main_layout.dart:59` (remove `debugPrint`).
3. **What to do:**
   1. Pick one (Sentry is simpler without Firebase project; Crashlytics needs `google-services.json`/`GoogleService-Info.plist`).
   2. Wire `await SentryFlutter.init(...)` or `Firebase.initializeApp() + Crashlytics`, route cubit errors there.
   3. Replace `debugPrint(name)` with real save (done in 3.2 — verify no `debugPrint` remains via grep).
4. **Why:** Concept: *you cannot fix what you cannot see*. Store builds strip console logs; crash reporters don’t.
5. **How to verify:** Trigger a test crash in debug (`throw StateError('test crash')` behind a debug button, then remove), confirm it appears in dashboard. `grep -rn "debugPrint\|print(" lib/` → nothing (use `debugPrint` only behind `kDebugMode` if needed).
6. **Estimated time:** 3 h.
7. **Dependencies:** 6.1.

### Step 6.3 — Signing + release builds from clean checkout
1. **Goal:** Reproducible signed artifacts.
2. **Files involved:** `android/app/build.gradle` + `android/key.properties` (gitignored), `ios/Runner/*` signing, no code edits.
3. **What to do:**
   1. Android: create upload keystore (`keytool -genkey`), add `key.properties` (never commit — verify `.gitignore` covers it), configure `signingConfigs.release`, run `flutter build appbundle --release`.
   2. iOS: set bundle id (e.g. `com.yourname.bloom`), provisioning profile, run `flutter build ipa --release` (needs macOS + Xcode).
   3. ⚠️ Be careful: losing the upload key = new app listing. Back it up offline + in password manager today.
4. **Why:** Concept: *signing is identity*. Stores trust the key, not your source code.
5. **How to verify:** `ls build/app/outputs/bundle/release/*.aab` exists; `flutter install` of release APK on a real device launches with persisted data.
6. **Estimated time:** 3 h (longer on first iOS signing).
7. **Dependencies:** 6.2.

### Step 6.4 — CI gate (`analyze + test + build`)
1. **Goal:** `main` can never go red silently again.
2. **Files involved:** Create `.github/workflows/ci.yaml` (checkout → setup-flutter → `flutter pub get` → `flutter analyze` → `flutter test --coverage` → `flutter build apk --debug`).
3. **What to do:**
   1. Pin Flutter version (e.g. `3.47.2`) in the workflow.
   2. Add branch protection on `main` requiring CI pass (GitHub settings — document the clicks in README).
   3. Verify by opening a draft PR that intentionally breaks a test → CI fails.
4. **Why:** Concept: *automation beats discipline*. Humans forget to run tests; CI doesn’t.
5. **How to verify:** Green check on `main`, red check on the sabotage PR (then close it).
6. **Estimated time:** 2 h.
7. **Dependencies:** 4.5, 6.1.

### Step 6.5 — Store assets + final manual sweep
1. **Goal:** Submission-ready listing.
2. **Files involved:** (no code) screenshots, feature graphic, privacy policy URL, `CHANGELOG.md`.
3. **What to do:**
   1. Capture EN + AR screenshots (phone + 7″ tablet): Today, My Habits, Progress, Discover, Add sheet.
   2. Write data-safety form: “No data collected, stored on device, no account.”
   3. Host a one-page privacy policy (GitHub Pages is fine) — required even for offline apps.
   4. Final sweep: install release on 2 real devices (different sizes), toggle airplane mode (must work offline), rotate, font-scale max, dark mode (document as unsupported if you didn’t build it — don’t let the store discover it).
4. **Why:** Concept: *release is a checklist, not courage*. Most rejections are metadata, not code.
5. **How to verify:** `Release Checklist` below all checked + recorded build numbers.
6. **Estimated time:** 4 h.
7. **Dependencies:** 6.3, 6.4.

---

## Release Checklist (copy into your release PR)

- [ ] `pubspec.yaml` version bumped (e.g. `1.0.0+2`), `CHANGELOG.md` entry written
- [ ] `flutter analyze` clean on clean checkout
- [ ] `flutter test --coverage` green, coverage ≥70% on logic
- [ ] `flutter build appbundle --release` + `flutter build ipa --release` succeed
- [ ] Signing: `key.properties` gitignored, keystore backed up; iOS provisioning valid
- [ ] Icons + splash verified on Android + iOS home screens
- [ ] EN + AR screenshots, feature graphic, short/long descriptions ready
- [ ] Privacy policy URL live; data-safety form (“no collection”) submitted
- [ ] Crash reporting test crash received in dashboard, then removed
- [ ] Manual sweep: offline, rotation, 320 dp, font-scale 1.3, TalkBack/VoiceOver smoke, fresh install + upgrade (old int-IDs migrate)
- [ ] CI green on `main`, branch protection on

---

## Risk register (steps that most often go wrong)

- **1.3 ID migration** — test upgrade from an old install with `int` ids before shipping. Losing habits on update is a 1-star event.
- **2.2 Either vs throws** — pick one error style for the whole codebase in a single commit; mixing both confuses every later step.
- **3.6 Streak redefinition** — announce the change; users notice streak resets emotionally.
- **5.3 Plurals/RTL** — budget an extra hour for ICU plural syntax and mirrored layouts; do not hand-roll `"${n} habits"`.
- **6.3 Keystore loss** — back up today, not “later.”

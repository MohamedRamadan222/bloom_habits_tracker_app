# Bloom Habit Tracker — Audit Report (Read-Only)

**Date:** 2026-10-20
**Commit audited:** `5ebb31a first in logic` (working tree dirty, see §0)
**Flutter:** 3.47.2 / Dart 3.13.2 / Channel stable
**Mode:** Read-only. No source files were modified to produce this report.

## 0. How this audit was done

Read before writing:

- `pubspec.yaml`, `analysis_options.yaml`, `lib/` (all 24 Dart files, ~2468 LOC), `test/widget_test.dart`, `assets/`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `README.md`
- Git history + dirty working tree (`git log --oneline -20`, `git status --short`, `git diff HEAD --stat`, `git show HEAD:<file>` for deleted files)
- Ran:
  - `flutter analyze` → **No issues found!**
  - `flutter test` → **1/1 FAILED** (see §4 C1)
  - `flutter test --coverage` → `coverage/lcov.info` generated, but all `DA` lines `0` except `main.dart` shell (effective coverage ~0%)

> `flutter analyze` passing does **not** mean the app is correct. It only means there are no static lint errors. The failing test, crash risks, and architecture gaps below are invisible to the analyzer.

Git state at audit time:

- Branch `master`, remote `origin https://github.com/MohamedRamadan222/bloom_habits_tracker_app.git`
- 4 commits: `5ebb31a first in logic`, `3daa842 home ui is done`, `90a60b0`, `61819b7`
- Dirty tree: `M` = modified, `AM` = added+modified in index, `D` = deleted. Notably `lib/core/mock/mock_data.dart` and `lib/features/habits/models/habit.dart` are deleted in working tree but still in `HEAD`. All `lib/core/data/` + cubits are staged-but-uncommitted new files. In short: **logic layer was just added on top of UI and never committed cleanly.**

---

## 1. Project Overview

**What the app does:**
A local-first habit tracker with 4 bottom-nav tabs. Today/Home shows greeting, banner, daily progress ring + streak pill, a 7-day calendar strip, period filter tabs (All/Morning/Afternoon/Evening), and a checkable habit list. My Habits shows cards with a 7-day dot strip. Progress and Discover are placeholders. Habits are created via a bottom sheet (name, icon, daily goal + unit, period, color). Progress is stored per day. A streak counter rewards consecutive days.

**Architecture (claimed vs. actual):**
Claimed Clean Architecture. Actual: a simple **UI + Cubit + concrete Repository + Hive** stack. There is no `domain/` layer (no entities/value objects, no repository interfaces, no use cases/failures), no dependency injection, no router. `lib/core/data/` holds both the model and the Hive implementation. Cubits depend directly on the concrete `HabitsRepository`. Some UI files instantiate `HabitsRepository()` themselves. That is **not** Clean Architecture — it is a pragmatic MVP structure.

**State management:**
`flutter_bloc` Cubits only (no Bloc events):
- `lib/features/home/cubit/home_cubit.dart` — `HomeCubit(HomeState{date,tab,items,streak})`, methods `selectDate/selectTab/add/toggle/reload`
- `lib/features/habits/cubit/habits_cubit.dart` — `HabitsCubit(List<HabitWeek>)`, methods `load/add`, owns `days = lastDays(7)`

One global `HomeCubit` is provided in `lib/main.dart:11-15`. `HabitsScreen` creates its own second `HabitsCubit` + second `HabitsRepository` locally.

**Main packages (`pubspec.yaml:10-20`):**

| Package | Used for | Actually used? |
|---|---|---|
| `flutter_bloc ^9.1.1` | Cubits | Yes |
| `hive_ce ^2.22.0` + `hive_ce_flutter ^2.5.0` | Local boxes `habits` + `logs` | Yes |
| `intl ^0.20.3` | `DateFormat.yMMMM/E` in calendar | Yes |
| `gap ^3.0.1` | Spacing | Yes |
| `lucide_icons_flutter ^3.1.22` | Icons | Yes |
| `cupertino_icons ^1.0.8` | `CupertinoIcons.back/forward` only | Yes, but replaceable |
| `uuid ^4.6.0` | Nothing | **No — unused** |

**Folder structure (short):**

```text
lib/
  main.dart
  core/
    constants/constants.dart      # habitIcons, periods, colors
    data/habit_item.dart          # HabitItem, HabitProgress, HabitWeek, helpers
    data/habits_repository.dart   # Hive CRUD + forDay/streak/weeks
    theme/app_colors.dart
    widgets/ calender_header, custom_header, daily_summary, progress_ring, close_button_sheet
  features/
    main_layout.dart              # Scaffold + AppBar + NavigationBar (4 tabs)
    home/cubit/home_cubit.dart
    home/presentation/views/home_screen.dart
    home/presentation/widgets/{daily_habit, habit_draft, home_banner, segmented_tabs, show_name_sheet, title_and_count_widget}
    habits/cubit/habits_cubit.dart
    habits/presentation/views/habits_screen.dart
    habits/presentation/widgets/{habit_overview_card, week_strip}
    progress/presentation/views/progress_screen.dart  # Placeholder
    discover/presentation/views/discover_screen.dart  # Placeholder
test/widget_test.dart             # 1 stale widget test, failing
assets/{fonts/Manrope, icons/appBarIcon.png, images/banner_img.png}
```

---

## 2. What Is Done

| # | Feature / Module | Files | Status |
|---|---|---|---|
| D1 | App entry + Hive init + global HomeCubit | `lib/main.dart:8-17` | Working |
| D2 | Bottom navigation (Today / My habits / Progress / Discover) + branded AppBar | `lib/features/main_layout.dart:32-133` | Working, English labels |
| D3 | Home header + add-habit entry point | `lib/features/home/presentation/views/home_screen.dart:50-55`, `lib/core/widgets/custom_header.dart` | Working |
| D4 | Banner, daily summary ring + streak pill | `lib/features/home/presentation/widgets/home_banner.dart`, `lib/core/widgets/daily_summary.dart`, `lib/core/widgets/progress_ring.dart` | Working visually |
| D5 | 7-day calendar with past navigation, future-tap blocked | `lib/core/widgets/calender_header.dart:8-236` | Working |
| D6 | Period filter (All/Morning/Afternoon/Evening) | `lib/features/home/presentation/widgets/segmented_tabs.dart`, `lib/features/home/cubit/home_cubit.dart:20-21,59` | Working |
| D7 | Daily habit list with toggle done (0 ↔ goal) | `lib/features/home/presentation/views/home_screen.dart:87-103`, `lib/features/home/presentation/widgets/daily_habit.dart`, `lib/features/home/cubit/home_cubit.dart:66-69` | Working (binary only, no partial) |
| D8 | Add-habit bottom sheet with validation | `lib/features/home/presentation/widgets/habit_draft.dart:40-339` | Working for create only |
| D9 | Hive persistence: `habits` box + `logs` box (`id\|yyyy-MM-dd → amount`) | `lib/core/data/habits_repository.dart:9-13,17,49-50` | Working happy-path |
| D10 | Per-day query + sorting by period/id | `lib/core/data/habits_repository.dart:26-47` | Working |
| D11 | Streak counter + weekly matrix for My Habits | `lib/core/data/habits_repository.dart:52-85` | Runs, semantics questionable (see M1) |
| D12 | My Habits list with overview cards + week dots | `lib/features/habits/presentation/views/habits_screen.dart:44-72`, `lib/features/habits/presentation/widgets/habit_overview_card.dart`, `.../week_strip.dart` | Working read-only |
| D13 | Name sheet UI + avatar button | `lib/features/home/presentation/widgets/show_name_sheet.dart`, `lib/features/main_layout.dart:57-76` | UI renders, does nothing persistent |
| D14 | Manrope fonts + banner/appBar assets wired | `pubspec.yaml:34-50`, `assets/` | Working |

---

## 3. What Is Missing

| # | Missing / Half-built | Evidence |
|---|---|---|
| X1 | **Progress screen** — pure `Placeholder` | `lib/features/progress/presentation/views/progress_screen.dart:13` |
| X2 | **Discover screen** — pure `Placeholder` | `lib/features/discover/presentation/views/discover_screen.dart:13` |
| X3 | **Edit / delete / detail habit** — `HabitOverviewCard(onEdit/onView)` are optional and never passed; `showHabitSheet(initial/onDelete)` params exist but `_ShowHabitSheetState` ignores `initial` and never shows delete; no detail route | `lib/features/habits/presentation/widgets/habit_overview_card.dart:13-14`, `lib/features/habits/presentation/views/habits_screen.dart:63-66`, `lib/features/home/presentation/widgets/habit_draft.dart:10-13,62-78` |
| X4 | **Username persistence** — `showNameSheet(onSave: (name) => debugPrint(name))`, greeting hardcoded `Hello, Alex`, hint `Alex` | `lib/features/main_layout.dart:59`, `lib/features/home/presentation/views/home_screen.dart:52`, `lib/features/home/presentation/widgets/show_name_sheet.dart:125` |
| X5 | **Partial progress** — model supports `done/goal` and subtitle shows `done/goal`, but `HomeCubit.toggle` only writes `0` or `goal`. No stepper/dialog | `lib/features/home/cubit/home_cubit.dart:66-69`, `lib/features/home/presentation/views/home_screen.dart:27-35` |
| X6 | **Clean Architecture layers** — no `domain/` entities, no `HabitsRepository` interface, no use cases, no `Failure` type, no DI (`get_it`), no router (`go_router`) | Whole `lib/` — verified by `glob lib/**/*.dart`, no such files |
| X7 | **Error handling** — no `try/catch` around Hive, no error states in cubits, no `onError`, no user-facing error UI | `lib/core/data/habits_repository.dart`, both cubits |
| X8 | **Tests** — only 1 stale widget test, 0 unit/bloc/integration tests, effective coverage ~0% | `test/widget_test.dart`, `coverage/lcov.info` (all `DA:*,0`) |
| X9 | **Localization / RTL** — all strings hardcoded English, no `l10n`, no `flutter_localizations`, dates use device locale implicitly; test still expects Arabic `الرئيسية` proving a locale pivot was abandoned | `grep -rn "Alex\|Placeholder" lib/`, `test/widget_test.dart:15` |
| X10 | **Reminders/notifications, backup/export, settings, onboarding, search** — expected for a habit tracker, none present | Needs verification: search `lib/` for `notification|alarm|shared_pref|backup` returns nothing |
| X11 | **Release config** — default Flutter launcher icons, `android:label="bloom_habit_tracker"`, `CFBundleName=bloom_habit_tracker`, no `flutter_native_splash` / `flutter_launcher_icons` config, generic `description: A new Flutter project`, `version: 1.0.0+1` premature | `pubspec.yaml:2,5`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist` |
| X12 | **CI / crash reporting / analytics** — no `.github/workflows/`, no `firebase_crashlytics`/`sentry`, no `flutter analyze/test` gate | `ls -a`, `grep -rn "crashlytics\|sentry" pubspec.lock` → nothing |
| X13 | **Calendar activity dots** — `WeekCalendar(hasActivity)` param exists but never passed, so dots are always grey | `lib/core/widgets/calender_header.dart:13,106`, `lib/features/home/presentation/views/home_screen.dart:66-69` |

---

## 4. What Is Wrong

Conventions: `path:line` → what → why it matters → severity.

### Critical

**C1 — The only test always fails + asserts stale Arabic UI. `test/widget_test.dart:7-16`**
What: pumps `const MyApp()` with no `BlocProvider<HomeCubit>`, no `Hive.initFlutter()`, then expects `NavigationDestination ×4` and `find.text('الرئيسية')`. Actual app has English labels (`Today`, `My habits`, …) and requires `HomeCubit` above `HomeScreen`.
Why: CI is permanently red; `flutter test --coverage` reports failure; coverage is meaningless. A beginner may think “tests are broken, ignore them.”
Severity: **Critical**

**C2 — Unsafe Hive deserialization can crash on corrupt/old data. `lib/core/data/habit_item.dart:36-45`, `lib/core/data/habits_repository.dart:33-34,53-61,83`**
What: `HabitItem.fromMap(Map m) => HabitItem(id: m['id'], …)` with no casts, null checks, or defaults. `streak()` does `(e as Map)['id'] as int`, `int.parse(parts[0])`, `(_logs.get(key) as int)`. Any hand-edited box, schema change, or partial write throws `TypeError`/`FormatException`.
Why: Local storage is untrusted input. One bad row bricks launch (`_refresh()` in cubit constructor has no guard).
Severity: **Critical**

### High

**H1 — `Hive.box()` captured in field initializers; fragile init order. `lib/core/data/habits_repository.dart:6-7`, `lib/features/habits/presentation/views/habits_screen.dart:18`, `lib/main.dart:9-13`**
What: `final Box _habits = Hive.box('habits')` runs at `new HabitsRepository()`. If constructed before `HabitsRepository.init()` (easy in tests, background isolates, or a future refactor), Hive throws `HiveError: Box not found`. `HabitsScreen` does `HabitsCubit(HabitsRepository())` inline with no guard.
Why: Works today only by luck of ordering. Makes every widget test require real Hive init.
Severity: **High**

**H2 — Unbounded list indexing crashes on bad data. `lib/features/home/presentation/views/home_screen.dart:34,95`, `lib/features/habits/presentation/widgets/habit_overview_card.dart:49,77`**
What: `habitIcons[e.habit.iconIndex]`, `periods[h.period]` with no range check. `habitIcons` has 6 entries, `periods` 3. A stored `iconIndex: 99` or `period: 5` (old app version, corrupt box) → `RangeError`.
Why: Direct crash from data layer reaching UI. Must clamp/fallback.
Severity: **High**

**H3 — Clean Architecture violation: UI instantiates data layer; cubits depend on concrete class. `lib/features/habits/presentation/views/habits_screen.dart:17-20`, `lib/main.dart:13`, both cubits’ constructors**
What: No abstract `HabitsRepository` interface, no use cases, no DI. `HabitsScreen` imports `core/data/habits_repository.dart` directly.
Why: Untestable (cannot mock), unswappable (cannot move to Supabase/Isar later without touching UI), and contradicts the project’s stated architecture.
Severity: **High**

**H4 — Two repository instances = two sources of truth. `lib/main.dart:13` vs `lib/features/habits/presentation/views/habits_screen.dart:18`**
What: `HomeCubit` and `HabitsCubit` each own a `HabitsRepository`. Sync is manual: `_addHabit` calls `await habits.add(); home.reload()`. Delete/update paths (when built) will forget this. `HabitsCubit.days = lastDays(7)` is frozen at construction and never recomputed, so week window goes stale after midnight.
Why: Subtle stale-UI bugs, double Hive listeners, wasted boxes.
Severity: **High**

**H5 — Millisecond IDs can collide and overwrite habits. `lib/features/home/presentation/widgets/habit_draft.dart:62-78`**
What: `id = DateTime.now().millisecondsSinceEpoch`, `createdAt = same`. Two rapid taps (or same-ms on fast devices) produce identical keys → `_habits.put(id)` silently overwrites. The `uuid` package is declared but never used.
Why: Data loss. IDs must be unique (`Uuid().v4()` or Hive auto-increment), not timestamps.
Severity: **High**

### Medium

**M1 — Streak counts “any habit done” as a full day. `lib/core/data/habits_repository.dart:52-72`**
What: `doneDays` adds a date if *any* log ≥ its goal. Completing 1 of 10 habits extends the streak. Product copy (“X day streak” flame pill) implies a full successful day.
Why: Misleading metric; needs product decision (any vs. all vs. % threshold) + unit test lock-in. ⚠️ Easy to “fix” wrong — confirm spec first.
Severity: **Medium**

**M2 — Dead edit/delete plumbing ships. `lib/features/home/presentation/widgets/habit_draft.dart:10-13,40-52`, `lib/features/habits/presentation/widgets/habit_overview_card.dart:103-124`**
What: `_EditButton(onTap: null)` renders but does nothing; `onView` null; `initial` never hydrates controllers; `onDelete` never rendered.
Why: Dead UI erodes trust; a user taps edit and nothing happens. Either wire it or remove the button until Phase 3.
Severity: **Medium**

**M3 — Identity is fake + copy mentions “browser” on mobile. `lib/features/home/presentation/widgets/show_name_sheet.dart:150-156`, `lib/features/main_layout.dart:59`**
What: Name is `debugPrint`ed and discarded. Description says “stay in this browser. No account needed.” — wrong platform.
Why: Ships a non-functional account affordance; copy confusion on iOS/Android.
Severity: **Medium**

**M4 — Binary toggle discards partial progress. `lib/features/home/cubit/home_cubit.dart:66-69`**
What: `toggle` writes `0` or `goal`. A “drink 8 glasses, did 5” habit cannot record 5 (subtitle code already anticipates `done/goal` but can never show it).
Why: Core habit-tracker loop is incomplete.
Severity: **Medium**

**M5 — Tab switches destroy state. `lib/features/main_layout.dart:22-30,78`**
What: `_pages` getter builds a fresh list every `build`; `body: _pages[i]` (not `IndexedStack`). Switching tabs rebuilds `HabitsScreen` → new `HabitsCubit` → new Hive query + lost scroll position.
Why: Jank + wasted IO; will worsen as lists grow.
Severity: **Medium**

**M6 — No IO error handling anywhere.**
What: `add/delete/setProgress/update` are bare `Hive.put/delete` futures. No `try/catch`, no failure state, `toggle`’s `await` can throw into the framework.
Why: Disk-full / permission / lock errors become unhandled async exceptions.
Severity: **Medium**

**M7 — Hardcoded strings, colors, copy. Examples: `home_screen.dart:52`, `daily_summary.dart:52,85`, `calender_header.dart:146-149`, `app_colors.dart:13` (`lll` unused, `border`/`field` untyped `Color`)**
What: English-only, magic hexes duplicated (`0xffEEECF2` ×8), `AppColors.lll` dead, `SegmentedTabs` dead commented block `:87-116`.
Why: Blocks theming/l10n, hides bugs, litters reviews. `flutter analyze` does not flag unused public statics.
Severity: **Medium**

**M8 — Accessibility + touch targets. `daily_habit.dart:68-86` (30×30 circle), `habit_overview_card.dart:110-123` (36px edit), no `Semantics` anywhere**
What: Check/edit targets below Material 48×48 minimum; no semantic labels for ring, streak, dots.
Why: Fails store accessibility review; hard for motor-impaired users.
Severity: **Medium**

### Low

**L1 — Unused `uuid` dependency. `pubspec.yaml:17`, `grep -rn uuid lib/` → nothing**
Why: Extra download/size/confusion. Either use it for IDs (recommended) or remove it.
Severity: **Low**

**L2 — Needless `StatefulWidget`s. `daily_summary.dart:8`, `title_and_count_widget.dart:7`, `progress_screen.dart:3`, `discover_screen.dart:3`**
Why: Extra boilerplate, misleading (implies state where there is none). Convert to `StatelessWidget`.
Severity: **Low**

**L3 — `late final _controller = TextEditingController(...)` pattern. `show_name_sheet.dart:31`**
Why: Works but unconventional; `late final` with initializer + `dispose` is fragile if refactored to re-init. Prefer plain `late` + `initState` or `final` field. Verify with `flutter analyze` (passes today).
Severity: **Low**

**L4 — Wasted/unwired assets + generic metadata. `assets/fonts/Manrope/Manrope-VariableFont_wght.ttf` present but not declared in `pubspec.yaml:34-50`; `pubspec.yaml:2` description generic; Android label / iOS name `bloom_habit_tracker`**
Why: Ships dead font bytes; store listing looks unfinished.
Severity: **Low**

**L5 — Past-only calendar can strand selection. `calender_header.dart:39,47-60`**
What: `_canGoNext = days.last.isBefore(today)`; `didUpdateWidget` recenters only if selected date not visible. Selecting an older week then adding a habit for today leaves the strip on the old week (by design, but disorienting). Future dates are untappable (`onTap: null`) yet rendered with low contrast.
Why: UX papercut, not a crash. Needs manual verification on small screens for overflow (4-tab `SegmentedTabs` row is tight at 320 dp).
Severity: **Low — needs verification**

**L6 — Mixed-language comments + typo in filename. `habit_item.dart:61` + `HabitWeek.done` Arabic comment, `calender_header.dart` (should be `calendar_…`)**
Why: Hurts onboarding; rename is breaking for imports — do it once with IDE refactor.
Severity: **Low**

---

## 5. Test Coverage Gaps

`flutter test`: **0 passed, 1 failed.** `coverage/lcov.info` lists 24 `SF:` files, virtually all hits `0`.

| Layer | Has tests? | Must add (in priority order) |
|---|---|---|
| `HabitItem` serialization + `dayKey/lastDays` helpers | None | Round-trip `toMap/fromMap`, corrupt-map rejection, `dayKey` zero-padding, `lastDays` ordering/edge (month boundary) |
| `HabitsRepository` | None | `forDay` filtering/sorting, `setProgress` clamping, `delete` cascades logs, `streak` semantics (today/yesterday gap/empty), `weeks` matrix, init-before-use guard |
| `HomeCubit` | None | Initial `_refresh`, `selectDate` normalizes to date-only, `selectTab` filters, `add`→refresh, `toggle` 0↔goal + reload |
| `HabitsCubit` | None | `load` emits weeks, `add`→reload, `days` window freshness |
| Widgets | None (broken) | `HabitCard` toggle callback, `ShowHabitSheet` validation (empty name/goal≤0 disables button), `WeekCalendar` prev/next limits + future untappable, `DailySummary` 0/total edge, `SegmentedTabs` selection |
| Navigation | None | Bottom nav switches tabs, FAB opens sheet, Manage → My Habits tab |
| Golden / accessibility | None | Banner + card goldens (light), `Semantics` checks — optional pre-release |
| Integration | None | Add habit → appears Today + My Habits; toggle → ring + streak update; restart → persisted (Hive) |

> The existing `test/widget_test.dart` must be rewritten, not patched: provide a fake repository + `Hive.initFlutter()` in `setUpAll` or use `Hive.test()` / temp dir, wrap `MyApp` in the real `BlocProvider`, and assert English labels.

---

## 6. Production Readiness Gaps

| Area | Status | Notes / how to verify |
|---|---|---|
| Security | ❌ Plaintext Hive, no encryption, no obfuscation | Verify: open box files under app dir; decide if `hive_ce` encrypted box (`HiveAesCipher`) is needed. Low sensitivity (habit names) but name + routine is personal data. |
| Performance | ⚠️ OK for MVP, risks ahead | `SingleChildScrollView + ListView(shrinkWrap)` fine for <100 habits; re-query on every tab switch (M5) wastes IO. Verify with DevTools + `flutter run --profile`. Images: `banner_img.png` size unchecked (`ls -lh assets/images/`). |
| Accessibility | ❌ No Semantics, small targets, no dynamic-type check | Verify: TalkBack/VoiceOver pass, `flutter test --tags a11y` (to add), font-scale 1.3× manual check. |
| Localization / RTL | ❌ English-only, no `flutter_localizations`, `intl` used only for dates | Verify: `grep -rn "MaterialApp(" lib/main.dart` — no `localizationsDelegates/supportedLocales`. Arabic RTL layout untested. |
| App icons / splash | ❌ Defaults | Verify: `ls android/app/src/main/res/mipmap-*/`, iOS `Assets.xcassets`; label is package name. Add `flutter_launcher_icons` + `flutter_native_splash` (dev-only deps). |
| Permissions | ✅ None needed (local only) | Verify manifest has no extra permissions (true today). Re-verify if notifications added later. |
| Signing / release | ❌ Unverified | Verify: `android/app/build.gradle` signingConfigs, `key.properties` presence (do not commit), `flutter build appbundle --release` dry run, iOS bundle id + provisioning. |
| Crash reporting / logs | ❌ None; `debugPrint` in prod path | Verify: no `firebase_crashlytics`/`sentry` in `pubspec.lock`. Add before store. |
| CI | ❌ No workflow | Verify: `ls .github/workflows/` → missing. Gate `analyze + test --coverage + build apk` |
| Store assets | ❌ None | Screenshots, feature graphic, privacy policy URL (required even for local-only apps), data-safety form. |
| Backup / data loss | ❌ No export; ID collision risk (H5) | Verify by adding 2 habits within same ms (script) — second overwrites first. |

**“Needs verification” list (do not guess):**
1. 320-dp overflow of `SegmentedTabs` + `DailySummary` row — run on small emulator, font-scale 1.3.
2. `Color.toARGB32()` availability on min SDK — `flutter --version` says 3.47, passes analyze; still verify `flutter build apk` on CI.
3. Streak product spec (any vs. all habits) — ask owner, then lock with test.
4. Hive box size/perf at 1k habits — profile, not assumed.

---

## Appendix — raw command outputs (abridged)

```text
$ flutter analyze
Analyzing bloom_habit_tracker...
No issues found! (ran in 7.9s)

$ flutter test
00:01 +0 -1: App starts and renders its navigation [E]
  ProviderNotFoundException: Could not find the correct Provider<HomeCubit> above this HomeScreen Widget
  Expected: null / Actual: ProviderNotFoundException
  Some tests failed.

$ flutter test --coverage
  Same failure. coverage/lcov.info generated with 24 SF entries, LH ~5 (MyApp shell only).
```

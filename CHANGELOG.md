# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-03-01
### Added
- New `time_ago_timestamp` and `time_ago_timestamp_with_overrides` helpers
  that take `gleam_time/timestamp.Timestamp` values. These build on top of
  the existing Unix-based APIs and enable seamless integration with the
  `gleam_time` ecosystem.
- Dependency on `gleam_time` for the new timestamp functions. The classic
  `time_ago_unix*` APIs remain dependency‑free for users who don't need
  them.
- Developer convenience: colored output in the `dev/humanize_dev.gleam`
  playground using a `woof.Custom` formatter.

### Fixed
- `list` behaved incorrectly for two elements (`"ab"`) and failed to
  insert the conjunction before the last element when there were three or
  more items.
- `duration_precise(0)` returned an empty string; now prints "0 seconds".
- Time‑ago locale data did not support languages where the "ago" word is a
  prefix (e.g. French, Spanish); added `ago_prefix: Bool` field and fixed
  built‑in locales accordingly.

## [1.0.1] - 2026-02-21
### Changed
- `percent_ratio` now handles negative numerators and denominators and
  always prints the requested number of decimal places.
- Refactored internal helpers (`pow10`, `pow_int`, `join_*`) to be
  tail-recursive or iterative to avoid stack overflows.

### Fixed
- Added comprehensive tests for signed and large values in
  `percent_ratio`.


## [1.0.0] - 2026-02-07
### Added
- Initial stable release candidate with public API:
  - number, number_with, number_with_opts
  - bytes_decimal, bytes_binary (supports up to YB/YiB)
  - percent, percent_with, percent_ratio
  - duration, duration_precise
  - list, list_with_oxford, list_with_ampersand
  - ordinal
  - time_ago_unix, time_ago_unix_with_overrides, make_locale
- Locale table: built-in locales (it, en, es, fr, de, pt).
- Extensive unit tests covering edge cases, rounding boundaries,
  negative values, percent spacing, and locale overrides.

### Changed
- Rounding promotion logic: numbers/bytes now promote to the next
  unit when rounding overflows (e.g., 999_950 -> 1.0M).
- README updated with examples for edge cases and overrides.

### Fixed
- Ensure percent spacing preserves decimals correctly (e.g. "12.0 %").


# Changelog

All notable changes to this project will be documented in this file.

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


<h1 align="center">humanize</h1>

<p align="center">
  <img src="https://raw.githubusercontent.com/lupodevelop/humanize/main/asset/img/humanize.png" alt="humanize logo" width="160" />
  <br />
  <a href="https://github.com/lupodevelop/humanize/actions/workflows/test.yml"><img src="https://github.com/lupodevelop/humanize/actions/workflows/test.yml/badge.svg" alt="Tests"></a>
  <a href="https://hex.pm/packages/humanize"><img src="https://img.shields.io/hexpm/v/humanize.svg" alt="Hex version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/lupodevelop/humanize.svg" alt="License"></a>
  <a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg" alt="Contributing"></a>
</p>

Small Gleam helpers to make numbers, bytes, durations and lists human-friendly.

## Quick API

| Function | Description |
|---|---|
| `humanize.number/1` | Compact numbers: `1_234` → `"1.2K"` |
| `humanize.number_with/3` | Control decimals and `DecimalSeparator` (`Dot` or `Comma`) |
| `humanize.bytes_decimal/1`, `humanize.bytes_binary/1` | File sizes (1000 vs 1024). Supports up to YB/YiB (decimal and binary, respectively). |
| `humanize.duration/1`, `humanize.duration_precise/1` | Human readable durations |
| `humanize.list/1`, `humanize.list_locale/3`, `humanize.list_with_oxford/1` | Natural language lists |
| `humanize.ordinal/1` | Ordinal suffixes (`1st`, `2nd`, `3rd`, ...) |
| `humanize.time_ago_unix/5` | Humanize a Unix timestamp relative to `now` (locale-aware) |
| `humanize.time_ago_unix_with_overrides/6` | Same as above but accepts runtime locale overrides |
| `humanize.make_locale/6` | Construct a custom locale entry to pass as an override |
| `internals/locales.gleam` | Internal table with built-in locales (`it`, `en`, `es`, `fr`, `de`, `pt`) |

## Examples

```gleam
import humanize

humanize.number(1_234) // "1.2K"
humanize.number_with(1_234_567, 2, humanize.Comma) // "1,23M"

humanize.bytes_decimal(1_536_000) // "1.5 MB"

// Large units
humanize.bytes_decimal(1_000_000_000_000_000) // "1 PB"
humanize.bytes_binary(1_125_899_906_842_624) // "1 PiB"

humanize.duration(125) // "2 minutes"
humanize.duration_precise(125) // "2 minutes, 5 seconds"

humanize.list(["a", "b", "c"]) // "a, b and c"
humanize.list_with_oxford(["a", "b", "c"]) // "a, b, and c"
humanize.list_with_ampersand(["a", "b", "c"]) // "a, b & c"

humanize.ordinal(23) // "23rd"

```

# Time / i18n
```gleam
import humanize

// Basic lookup using built-in locales
humanize.time_ago_unix(1_620_000_000, 1_620_000_360, "en", False, 1) // "6 minutes ago"

// For custom locale examples see the "Locale overrides" section below.

// Edge cases and behaviour near rounding boundaries
humanize.percent_with(12, 1, humanize.Dot, True) // "12.0 %"
humanize.number(999) // "999"
humanize.number(1000) // "1.0K"
humanize.number_with(999_950, 1, humanize.Dot) // promoted to "1.0M"
humanize.bytes_decimal(999) // "999 B"
humanize.bytes_decimal(1000) // "1 KB"
humanize.bytes_decimal(999_950) // promoted to "1.0 MB"

// Override example: future and precise
let my_units = [#(3600, "hX", "hX"), #(60, "minX", "minX"), #(1, "sX", "sX")]
let my_locale = humanize.make_locale("xx", "agoX", "inX", "nowX", " & ", my_units)

// future
humanize.time_ago_unix_with_overrides(1_000_120, 1_000_000, "xx", [my_locale], False, 1) // "inX 2 minX"
// precise
humanize.time_ago_unix_with_overrides(1_000_000 - { 3600 + 120 }, 1_000_000, "xx", [my_locale], True, 2) // "1 hX & 2 minX agoX"
```


### Locale overrides

You can construct custom locale entries and pass them as `overrides` to `time_ago_unix_with_overrides`.

| Parameter | Type | Description |
|---|---:|---|
| `code` | `String` | Identifier code for the locale (e.g. `it-roma`). |
| `ago` | `String` | Suffix for past tense (e.g. `ago`, `fa`). |
| `in_` | `String` | Prefix for future tense (e.g. `in`, `tra`). |
| `nowv` | `String` | Text for the "now" case (e.g. `now`, `adesso`). |
| `conj` | `String` | Conjunction used between units (e.g. ` and `, ` e `, ` & `). |
| `units` | `List(#(Int, String, String))` | List of tuples `(seconds, singular, plural)`, ordered from largest to smallest (years → months → ... → seconds). |

The library helper is:

```gleam
pub fn make_locale(
  code: String,
  ago: String,
  in_: String,
  nowv: String,
  conj: String,
  units: List(#(Int, String, String)),
) -> #(String, LocaleData)
```

Quick example:

```gleam
let my_units = [#(3600, "ora_custom", "ore_custom"), #(60, "minuto_custom", "minuti_custom"), #(1, "secondo_custom", "secondi_custom")]
let my_locale = humanize.make_locale("it-roma", "fa", "tra", "adesso", " e ", my_units)

// Pass the override list to the call
humanize.time_ago_unix_with_overrides(past, now, "it-roma", [my_locale], False, 1)
```

# Percent examples

| Example | Result |
|---|---|
| `humanize.percent(50)` | `"50%"` |
| `humanize.percent_with(12, 1, humanize.Dot, False)` | `"12.0%"` |
| `humanize.percent_ratio(1, 3, 2, humanize.Comma)` | `"33,33%"` |
| `humanize.percent_ratio(1, 6, 1, humanize.Dot)` | `"16.7%"` |

## License

This project is available under the MIT License. See `LICENSE`.

## Development

Run locally:

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

Made with Gleam 💜

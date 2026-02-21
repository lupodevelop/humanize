import gleam/int
import gleam/list as list_mod
import gleam/string
import internals/locales as il

/// Utilities for formatting numbers, bytes, durations, lists, and timestamps
/// in a human-friendly and locale-aware format.
/// Decimal separator selection for formatted numbers.
pub type DecimalSeparator {
  Dot
  Comma
}

/// Options record for number formatting.
pub type NumberOpts {
  NumberOpts(decimals: Int, decimal_sep: DecimalSeparator)
}

fn decimal_sep_from_sep(sep: DecimalSeparator) -> String {
  case sep {
    Dot -> "."
    Comma -> ","
  }
}

// internal tail‑recursive helper for pow10
fn pow10_acc(n: Int, acc: Int) -> Int {
  case n {
    0 -> acc
    _ -> pow10_acc(n - 1, acc * 10)
  }
}

fn pow10(n: Int) -> Int {
  pow10_acc(n, 1)
}

/// Format an integer into a compact human-friendly string.
/// Example: `1234` -> "1.2K".
pub fn number(n: Int) -> String {
  number_with(n, 1, Dot)
}

/// Format an integer using a specific number of decimals and decimal separator.
pub fn number_with(n: Int, decimals: Int, sep: DecimalSeparator) -> String {
  let abs = case n < 0 {
    True -> -n
    False -> n
  }
  let sign = case n < 0 {
    True -> "-"

    False -> ""
  }
  let format_scaled = fn(
    n: Int,
    denom: Int,
    suffix: String,
    decimals: Int,
    sep: DecimalSeparator,
    sign: String,
  ) -> String {
    let mul = pow10(decimals)
    let scaled = { n * mul + denom / 2 } / denom
    let whole = scaled / mul
    let frac = scaled % mul
    case decimals == 0 {
      True -> sign <> int.to_string(whole) <> suffix

      False -> {
        let frac_s = int.to_string(frac)
        let frac_len = string.length(frac_s)
        let frac_padded = case frac_len < decimals {
          True -> {
            let needed = decimals - frac_len
            let zeros = repeat_string(needed, "0")
            zeros <> frac_s
          }

          False -> frac_s
        }
        sign
        <> int.to_string(whole)
        <> decimal_sep_from_sep(sep)
        <> frac_padded
        <> suffix
      }
    }
  }

  case abs >= 1_000_000_000 {
    True -> format_scaled(abs, 1_000_000_000, "B", decimals, sep, sign)

    False ->
      case abs >= 1_000_000 {
        True -> {
          let mul = pow10(decimals)
          let scaled = { abs * mul + 1_000_000 / 2 } / 1_000_000
          case scaled >= 1000 * mul {
            True -> format_scaled(abs, 1_000_000_000, "B", decimals, sep, sign)
            False -> format_scaled(abs, 1_000_000, "M", decimals, sep, sign)
          }
        }

        False ->
          case abs >= 1000 {
            True -> {
              let mul = pow10(decimals)
              let scaled = { abs * mul + 1000 / 2 } / 1000
              case scaled >= 1000 * mul {
                True -> format_scaled(abs, 1_000_000, "M", decimals, sep, sign)
                False -> format_scaled(abs, 1000, "K", decimals, sep, sign)
              }
            }

            False -> int.to_string(n)
          }
      }
  }
}

/// Format an integer using a `NumberOpts` record.
pub fn number_with_opts(n: Int, opts: NumberOpts) -> String {
  case opts {
    NumberOpts(decimals, sep) -> number_with(n, decimals, sep)
  }
}

/// Format bytes using decimal units (base 1000), supports up to Yottabyte (YB).
pub fn bytes_decimal(bytes: Int) -> String {
  bytes_with(
    bytes,
    1000,
    ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"],
    1,
    Dot,
  )
}

/// Format bytes using binary units (base 1024), supports up to Yobibyte (YiB).
pub fn bytes_binary(bytes: Int) -> String {
  bytes_with(
    bytes,
    1024,
    ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"],
    1,
    Dot,
  )
}

// internal tail‑recursive helper for general integer powers
fn pow_int_acc(base: Int, exp: Int, acc: Int) -> Int {
  case exp {
    0 -> acc
    _ -> pow_int_acc(base, exp - 1, acc * base)
  }
}

fn pow_int(base: Int, exp: Int) -> Int {
  pow_int_acc(base, exp, 1)
}

fn repeat_string(n: Int, s: String) -> String {
  join_strings(list_mod.repeat(s, n), "")
}

fn join_strings(xs: List(String), sep: String) -> String {
  case xs {
    [] -> ""
    [a] -> a
    [a, ..rest] ->
      // fold over the remainder to avoid recursion
      list_mod.fold(rest, a, fn(acc: String, x: String) -> String {
        acc <> sep <> x
      })
  }
}

fn join_with_conj(items: List(String), conj_full: String) -> String {
  case items {
    [] -> ""
    [a] -> a
    [a, b] -> a <> conj_full <> b
    [a, ..rest] ->
      list_mod.fold(rest, a, fn(acc: String, x: String) -> String {
        acc <> ", " <> x
      })
  }
}

fn build_parts(
  rem: Int,
  us: List(#(Int, String, String)),
  remaining: Int,
) -> List(String) {
  case remaining <= 0 {
    True -> []

    False ->
      case us {
        [] -> []

        [#(sec, sing, plur), ..rest] ->
          case rem / sec {
            0 -> build_parts(rem, rest, remaining)

            n -> {
              let part = format_unit(n, sing, plur)
              let new_rem = rem - n * sec
              list_mod.append([part], build_parts(new_rem, rest, remaining - 1))
            }
          }
      }
  }
}

/// Localized strings and unit definitions for relative time formatting.
pub type LocaleData {
  LocaleData(
    ago: String,
    in_: String,
    now: String,
    conj: String,
    units: List(#(Int, String, String)),
  )
}

// Convert raw internal data to LocaleData to avoid circular dependencies.
fn raw_to_locale_data(
  raw: #(String, String, String, String, List(#(Int, String, String))),
) -> LocaleData {
  case raw {
    #(ago, in_, nowv, conj, units) -> LocaleData(ago, in_, nowv, conj, units)
  }
}

fn find_locale_raw(
  locale: String,
  list: List(
    #(String, #(String, String, String, String, List(#(Int, String, String)))),
  ),
) -> LocaleData {
  case list {
    [] -> raw_to_locale_data(il.default_raw())

    [#(k, raw), ..rest] ->
      case k == locale {
        True -> raw_to_locale_data(raw)
        False -> find_locale_raw(locale, rest)
      }
  }
}

/// Retrieve the built-in `LocaleData` for a given locale code.
pub fn get_locale_data(locale: String) -> LocaleData {
  find_locale_raw(locale, il.locales_raw())
}

/// Create a custom `LocaleData` entry.
pub fn make_locale(
  code: String,
  ago: String,
  in_: String,
  nowv: String,
  conj: String,
  units: List(#(Int, String, String)),
) -> #(String, LocaleData) {
  #(code, LocaleData(ago, in_, nowv, conj, units))
}

/// Lookup `LocaleData` with custom overrides.
pub fn get_locale_data_with(
  locale: String,
  overrides: List(#(String, LocaleData)),
) -> LocaleData {
  // Search overrides first
  case overrides {
    [] -> find_locale_raw(locale, il.locales_raw())

    [#(k, d), ..rest] ->
      case k == locale {
        True -> d
        False -> get_locale_data_with(locale, rest)
      }
  }
}

fn format_unit(count: Int, singular: String, plural: String) -> String {
  case count == 1 {
    True -> int.to_string(count) <> " " <> singular

    False -> int.to_string(count) <> " " <> plural
  }
}

fn time_ago_from_data(
  data: LocaleData,
  past_seconds: Int,
  now_seconds: Int,
  precise: Bool,
  max_units: Int,
) -> String {
  let delta = now_seconds - past_seconds
  let abs_delta = case delta < 0 {
    True -> -delta

    False -> delta
  }

  let now_str = case data {
    LocaleData(_, _, nowv, _, _) -> nowv
  }

  case abs_delta <= 5 {
    True -> now_str

    False -> {
      let units = case data {
        LocaleData(_, _, _, _, u) -> u
      }
      let needed_units = case precise {
        True -> max_units
        False -> 1
      }

      let parts = build_parts(abs_delta, units, needed_units)

      let core = join_with_conj(parts, data.conj)

      case delta < 0 {
        True -> data.in_ <> " " <> core

        False -> core <> " " <> data.ago
      }
    }
  }
}

/// Format a Unix timestamp relative to `now_seconds` using built-in locales.
pub fn time_ago_unix(
  past_seconds: Int,
  now_seconds: Int,
  locale: String,
  precise: Bool,
  max_units: Int,
) -> String {
  let data = get_locale_data(locale)
  time_ago_from_data(data, past_seconds, now_seconds, precise, max_units)
}

/// Like `time_ago_unix` but accepts a list of runtime overrides.
pub fn time_ago_unix_with_overrides(
  past_seconds: Int,
  now_seconds: Int,
  locale: String,
  overrides: List(#(String, LocaleData)),
  precise: Bool,
  max_units: Int,
) -> String {
  let data = get_locale_data_with(locale, overrides)
  time_ago_from_data(data, past_seconds, now_seconds, precise, max_units)
}

/// Convenience wrapper: accept timestamps in milliseconds instead of seconds.
pub fn time_ago_millis(
  past_millis: Int,
  now_millis: Int,
  locale: String,
  precise: Bool,
  max_units: Int,
) -> String {
  let past = past_millis / 1000
  let now = now_millis / 1000
  time_ago_unix(past, now, locale, precise, max_units)
}

/// Millisecond-based wrapper with overrides.
pub fn time_ago_millis_with_overrides(
  past_millis: Int,
  now_millis: Int,
  locale: String,
  overrides: List(#(String, LocaleData)),
  precise: Bool,
  max_units: Int,
) -> String {
  let past = past_millis / 1000
  let now = now_millis / 1000
  time_ago_unix_with_overrides(past, now, locale, overrides, precise, max_units)
}

fn find_denom_for(
  n: Int,
  base: Int,
  units: List(String),
  idx: Int,
) -> #(Int, String, List(String)) {
  case units {
    [] -> #(1, "B", [])

    [u] -> #(pow_int(base, idx), u, [])

    [u, ..rest] -> {
      let denom = pow_int(base, idx)
      let next = denom * base
      case n < next {
        True -> #(denom, u, rest)

        False -> find_denom_for(n, base, rest, idx + 1)
      }
    }
  }
}

fn promote_if_needed_bytes(
  n: Int,
  base: Int,
  mul: Int,
  denom: Int,
  unit: String,
  rest: List(String),
) -> #(Int, String, List(String)) {
  let scaled = { n * mul + denom / 2 } / denom
  case scaled >= base * mul {
    True ->
      case rest {
        [] -> #(denom, unit, rest)
        [next, ..rest2] -> #(denom * base, next, rest2)
      }

    False -> #(denom, unit, rest)
  }
}

fn bytes_with(
  bytes: Int,
  base: Int,
  units: List(String),
  decimals: Int,
  sep: DecimalSeparator,
) -> String {
  let n = case bytes < 0 {
    True -> -bytes

    False -> bytes
  }
  let sign = case bytes < 0 {
    True -> "-"

    False -> ""
  }

  let #(denom, unit, rest) = find_denom_for(n, base, units, 0)
  let mul = pow10(decimals)

  let #(denom, unit, _rest) =
    promote_if_needed_bytes(n, base, mul, denom, unit, rest)

  let scaled = { n * mul + denom / 2 } / denom
  let whole = scaled / mul
  let frac = scaled % mul

  case decimals == 0 {
    True -> sign <> int.to_string(whole) <> " " <> unit

    False ->
      case frac == 0 {
        True -> sign <> int.to_string(whole) <> " " <> unit

        False -> {
          let frac_s = int.to_string(frac)
          let frac_len = string.length(frac_s)
          let frac_padded = case frac_len < decimals {
            True -> {
              let needed = decimals - frac_len
              let zeros = repeat_string(needed, "0")
              zeros <> frac_s
            }

            False -> frac_s
          }
          sign
          <> int.to_string(whole)
          <> decimal_sep_from_sep(sep)
          <> frac_padded
          <> " "
          <> unit
        }
      }
  }
}

// Percent formatting helpers
/// Format an integer as a percentage string. Uses no decimals by default.
pub fn percent(n: Int) -> String {
  percent_with(n, 0, Dot, False)
}

/// Format a percentage value with custom options.
pub fn percent_with(
  n: Int,
  decimals: Int,
  sep: DecimalSeparator,
  spaced: Bool,
) -> String {
  let formatted = case decimals == 0 {
    True -> int.to_string(n)

    False -> {
      let zeros = repeat_string(decimals, "0")
      int.to_string(n) <> decimal_sep_from_sep(sep) <> zeros
    }
  }
  case spaced {
    True -> formatted <> " %"

    False -> formatted <> "%"
  }
}

/// Compute and format a ratio as a percentage with rounding.
pub fn percent_ratio(
  numerator: Int,
  denominator: Int,
  decimals: Int,
  sep: DecimalSeparator,
) -> String {
  case denominator == 0 {
    True -> "NaN%"

    False -> {
      // Determine the overall sign: a negative numerator or negative
      // denominator (but not both) yields a leading "-".
      let negative_num = numerator < 0
      let negative_den = denominator < 0
      let sign = case negative_num != negative_den {
        True -> "-"
        False -> ""
      }
      let n = case numerator < 0 {
        True -> -numerator
        False -> numerator
      }
      let d = case denominator < 0 {
        True -> -denominator
        False -> denominator
      }

      let mul = pow10(decimals)
      // rounding: add half the denominator before dividing
      let scaled = { n * 100 * mul + { d / 2 } } / d
      let whole = scaled / mul
      let frac = scaled % mul
      case decimals == 0 {
        True -> sign <> int.to_string(whole) <> "%"

        False -> {
          // always show `decimals` digits; pad with zeroes if necessary
          let frac_s = int.to_string(frac)
          let frac_len = string.length(frac_s)
          let frac_padded = case frac_len < decimals {
            True -> {
              let needed = decimals - frac_len
              let zeros = repeat_string(needed, "0")
              zeros <> frac_s
            }
            False -> frac_s
          }
          sign
          <> int.to_string(whole)
          <> decimal_sep_from_sep(sep)
          <> frac_padded
          <> "%"
        }
      }
    }
  }
}

/// Format a duration in seconds into a single largest unit description.
pub fn duration(seconds: Int) -> String {
  case seconds < 60 {
    True ->
      case seconds == 1 {
        True -> "1 second"
        False -> int.to_string(seconds) <> " seconds"
      }

    False ->
      case seconds < 3600 {
        True -> {
          let m = seconds / 60
          case m == 1 {
            True -> "1 minute"
            False -> int.to_string(m) <> " minutes"
          }
        }

        False ->
          case seconds < 86_400 {
            True -> {
              let h = seconds / 3600
              case h == 1 {
                True -> "1 hour"
                False -> int.to_string(h) <> " hours"
              }
            }

            False -> {
              let d = seconds / 86_400
              case d == 1 {
                True -> "1 day"
                False -> int.to_string(d) <> " days"
              }
            }
          }
      }
  }
}

/// Precise duration with multiple units, joined by commas.
pub fn duration_precise(seconds: Int) -> String {
  let d = seconds / 86_400
  let h = { seconds % 86_400 } / 3600
  let m = { seconds % 3600 } / 60
  let s = seconds % 60
  let parts = []
  let parts = case d > 0 {
    True ->
      case d == 1 {
        True -> list_mod.append(parts, ["1 day"])
        False -> list_mod.append(parts, [int.to_string(d) <> " days"])
      }

    False -> parts
  }
  let parts = case h > 0 {
    True ->
      case h == 1 {
        True -> list_mod.append(parts, ["1 hour"])
        False -> list_mod.append(parts, [int.to_string(h) <> " hours"])
      }

    False -> parts
  }
  let parts = case m > 0 {
    True ->
      case m == 1 {
        True -> list_mod.append(parts, ["1 minute"])
        False -> list_mod.append(parts, [int.to_string(m) <> " minutes"])
      }

    False -> parts
  }
  let parts = case s > 0 {
    True ->
      case s == 1 {
        True -> list_mod.append(parts, ["1 second"])
        False -> list_mod.append(parts, [int.to_string(s) <> " seconds"])
      }

    False -> parts
  }
  join_strings(parts, ", ")
}

/// Join a list of strings into a human-readable sentence fragment.
pub fn list(items: List(String)) -> String {
  list_locale(items, "", False)
}

/// Join a list using the Oxford comma when appropriate.
pub fn list_with_oxford(items: List(String)) -> String {
  list_locale(items, "", True)
}

// Convenience: use an ampersand as conjunction (e.g. "a, b & c")
/// Join a list using an ampersand as the final conjunction.
pub fn list_with_ampersand(items: List(String)) -> String {
  list_locale(items, " & ", False)
}

/// Join a list with a custom conjunction and Oxford comma option.
pub fn list_locale(items: List(String), conj: String, oxford: Bool) -> String {
  case items {
    [] -> ""
    [a] -> a
    [a, b] -> a <> conj <> b
    _ -> {
      let conj_full = case conj != "" {
        True -> conj

        False ->
          case oxford {
            True -> ", and "
            False -> " and "
          }
      }
      join_with_conj(items, conj_full)
    }
  }
}

/// Return the English ordinal suffix for an integer (e.g., 1st, 2nd).
pub fn ordinal(n: Int) -> String {
  let abs = case n < 0 {
    True -> -n

    False -> n
  }
  let mod100 = abs % 100
  let mod10 = abs % 10
  let suffix = case mod100 {
    11 -> "th"
    12 -> "th"
    13 -> "th"
    _ ->
      case mod10 {
        1 -> "st"
        2 -> "nd"
        3 -> "rd"
        _ -> "th"
      }
  }
  int.to_string(n) <> suffix
}

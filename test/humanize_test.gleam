import gleam/int
import gleeunit
import humanize

fn pow10(n: Int) -> Int {
  case n {
    0 -> 1
    _ -> 10 * pow10(n - 1)
  }
}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn number_basic_test() {
  assert humanize.number(1234) == "1.2K"
}

pub fn number_with_locale_test() {
  assert humanize.number_with(1_234_567, 2, humanize.Comma) == "1,23M"
}

pub fn number_with_opts_test() {
  assert humanize.number_with_opts(
      1_234_567,
      humanize.NumberOpts(2, humanize.Comma),
    )
    == "1,23M"
}

pub fn bytes_decimal_tests() {
  assert humanize.bytes_decimal(1024) == "1 KB"
  assert humanize.bytes_decimal(1_536_000) == "1.5 MB"
}

pub fn bytes_binary_test() {
  assert humanize.bytes_binary(1024) == "1 KiB"
}

pub fn duration_tests() {
  assert humanize.duration(125) == "2 minutes"
  assert humanize.duration_precise(125) == "2 minutes, 5 seconds"
}

pub fn time_ago_tests() {
  // now
  let now = 1_000_000
  assert humanize.time_ago_unix(now, now, "it", False, 1) == "adesso"

  // past concise
  assert humanize.time_ago_unix(now - 3600, now, "it", False, 1) == "1 ora fa"

  // past precise
  assert humanize.time_ago_unix(now - { 3600 + 120 }, now, "it", True, 2)
    == "1 ora e 2 minuti fa"

  // future
  assert humanize.time_ago_unix(now + 3600, now, "en", False, 1) == "in 1 hour"

  // ratio-like small
  assert humanize.time_ago_unix(now - 3, now, "en", False, 1) == "now"
}

pub fn list_tests() {
  assert humanize.list(["a", "b"]) == "a and b"
  assert humanize.list(["a", "b", "c"]) == "a, b and c"
  assert humanize.list_locale(["a", "b", "c"], " e ", False) == "a, b e c"
  assert humanize.list_with_oxford(["a", "b", "c"]) == "a, b, and c"
  assert humanize.list_with_ampersand(["a", "b", "c"]) == "a, b & c"
}

pub fn percent_tests() {
  assert humanize.percent(50) == "50%"
  assert humanize.percent_with(12, 1, humanize.Dot, False) == "12.0%"
  assert humanize.percent_ratio(1, 2, 0, humanize.Dot) == "50%"
  assert humanize.percent_ratio(1, 3, 2, humanize.Comma) == "33,33%"
}

pub fn ordinal_tests() {
  assert humanize.ordinal(1) == "1st"
  assert humanize.ordinal(2) == "2nd"
  assert humanize.ordinal(11) == "11th"
  assert humanize.ordinal(23) == "23rd"
}

// Edge cases and additional tests
pub fn negative_number_test() {
  assert humanize.number(-1500) == "-1.5K"
}

pub fn negative_bytes_test() {
  assert humanize.bytes_decimal(-1_536_000) == "-1.5 MB"
}

pub fn percent_ratio_denominator_zero_test() {
  assert humanize.percent_ratio(1, 0, 0, humanize.Dot) == "NaN%"
}

pub fn percent_ratio_rounding_test() {
  // 1/6 = 16.666... -> 16.7% when 1 decimal
  assert humanize.percent_ratio(1, 6, 1, humanize.Dot) == "16.7%"
}

pub fn large_bytes_decimal_test() {
  // 1 PB == 10^15
  assert humanize.bytes_decimal(1_000_000_000_000_000) == "1 PB"
  // 1 EB == 10^18
  assert humanize.bytes_decimal(1_000_000_000_000_000_000) == "1 EB"
  // 1 ZB == 10^21
  assert humanize.bytes_decimal(1_000_000_000_000_000_000_000) == "1 ZB"
  // 1 YB == 10^24
  assert humanize.bytes_decimal(1_000_000_000_000_000_000_000_000) == "1 YB"
}

pub fn large_bytes_binary_test() {
  // 1 PiB == 1024^5
  assert humanize.bytes_binary(1_125_899_906_842_624) == "1 PiB"
  // 1 ZiB == 1024^7
  assert humanize.bytes_binary(1_180_591_620_717_411_303_424) == "1 ZiB"
  // 1 YiB == 1024^8
  assert humanize.bytes_binary(1_208_925_819_614_629_174_706_176) == "1 YiB"
}

pub fn make_locale_overrides_test() {
  let now = 1_000_000
  let my_units = [#(3600, "hX", "hX"), #(60, "minX", "minX"), #(1, "sX", "sX")]
  let my_locale =
    humanize.make_locale("xx", "agoX", "inX", "nowX", " & ", my_units)

  // now case (<= 5 seconds)
  assert humanize.time_ago_unix_with_overrides(
      now,
      now,
      "xx",
      [my_locale],
      False,
      1,
    )
    == "nowX"

  // minutes in the past
  assert humanize.time_ago_unix_with_overrides(
      now - 120,
      now,
      "xx",
      [my_locale],
      False,
      1,
    )
    == "2 minX agoX"

  // future
  assert humanize.time_ago_unix_with_overrides(
      now + 120,
      now,
      "xx",
      [my_locale],
      False,
      1,
    )
    == "inX 2 minX"

  // precise with two units
  assert humanize.time_ago_unix_with_overrides(
      now - { 3600 + 120 },
      now,
      "xx",
      [my_locale],
      True,
      2,
    )
    == "1 hX & 2 minX agoX"
}

pub fn percent_spaced_test() {
  assert humanize.percent_with(12, 0, humanize.Dot, True) == "12 %"
  assert humanize.percent_with(12, 1, humanize.Dot, True) == "12.0 %"
}

pub fn number_boundary_tests() {
  // boundaries around 999/1000 and rounding overflow
  assert humanize.number(999) == "999"
  assert humanize.number(1000) == "1.0K"
  assert humanize.number_with(1499, 1, humanize.Dot) == "1.5K"
  // rounding should promote into the next unit when appropriate
  assert humanize.number_with(999_950, 1, humanize.Dot) == "1.0M"
}

pub fn bytes_boundary_tests() {
  assert humanize.bytes_decimal(999) == "999 B"
  assert humanize.bytes_decimal(1000) == "1 KB"
  assert humanize.bytes_decimal(1500) == "1.5 KB"
  // rounding should promote into the next unit when appropriate
  assert humanize.bytes_decimal(999_950) == "1.0 MB"
}

fn pow_int(base: Int, exp: Int) -> Int {
  case exp {
    0 -> 1
    _ -> base * pow_int(base, exp - 1)
  }
}

fn expected_find_denom_from_units(
  n: Int,
  units: List(String),
  idx: Int,
) -> #(Int, String) {
  case units {
    [] -> #(1, "B")

    [u] -> #(pow_int(1000, idx), u)

    [u, ..rest] -> {
      let denom = pow_int(1000, idx)
      let next = denom * 1000
      case n < next {
        True -> #(denom, u)
        False -> expected_find_denom_from_units(n, rest, idx + 1)
      }
    }
  }
}

pub fn expected_find_denom(n: Int, units: List(String)) -> #(Int, String) {
  expected_find_denom_from_units(n, units, 0)
}

fn find_next_unit(units: List(String), target: String) -> String {
  case units {
    [] -> target
    [u, ..rest] ->
      case rest {
        [] -> target
        [next, ..rest2] ->
          case u == target {
            True -> next
            False -> find_next_unit([next, ..rest2], target)
          }
      }
  }
}

pub fn expected_bytes_decimal(n: Int) -> String {
  let units = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
  let #(denom, unit) = expected_find_denom(n, units)
  let mul = pow10(1)
  let scaled = { n * mul + denom / 2 } / denom

  // Promote if rounding would carry into the next unit
  let #(denom, unit) = case scaled >= 1000 * mul {
    True -> {
      let next_unit = find_next_unit(units, unit)
      #(denom * 1000, next_unit)
    }

    False -> #(denom, unit)
  }

  let scaled2 = { n * mul + denom / 2 } / denom
  let whole = scaled2 / mul
  let frac = scaled2 % mul

  case frac == 0 {
    True -> int.to_string(whole) <> " " <> unit
    False -> int.to_string(whole) <> "." <> int.to_string(frac) <> " " <> unit
  }
}

pub fn check_all(xs: List(Int)) -> Bool {
  case xs {
    [] -> True
    [a, ..rest] ->
      case humanize.bytes_decimal(a) == expected_bytes_decimal(a) {
        True -> check_all(rest)
        False -> False
      }
  }
}

pub fn bytes_property_monotonicity_test() {
  // sample values across ranges up to YiB
  let samples = [
    0,
    1,
    2,
    999,
    1000,
    1500,
    999_950,
    1_000_000,
    1_500_000,
    1_000_000_000,
    1_000_000_000_000,
    1_000_000_000_000_000,
    1_000_000_000_000_000_000,
    1_000_000_000_000_000_000_000,
    1_000_000_000_000_000_000_000_000,
  ]

  assert check_all(samples)
}

pub fn first_mismatch(xs: List(Int)) -> Int {
  case xs {
    [] -> -1
    [a, ..rest] ->
      case humanize.bytes_decimal(a) == expected_bytes_decimal(a) {
        True -> first_mismatch(rest)
        False -> a
      }
  }
}

pub fn bytes_property_find_mismatch_test() {
  let samples = [
    0,
    1,
    2,
    999,
    1000,
    1500,
    999_950,
    1_000_000,
    1_500_000,
    1_000_000_000,
    1_000_000_000_000,
    1_000_000_000_000_000,
    1_000_000_000_000_000_000,
    1_000_000_000_000_000_000_000,
    1_000_000_000_000_000_000_000_000,
  ]
  assert first_mismatch(samples) == -1
}

// Locale structural tests: plurals, future/past with built-ins
pub fn locale_structure_tests() {
  let now = 1_000_000
  // French: future/past and plurals
  assert humanize.time_ago_unix(now - 7200, now, "fr", False, 1)
    == "il y a 2 heures"
  assert humanize.time_ago_unix(now + 3600, now, "fr", False, 1)
    == "dans 1 heure"

  // Ensure overrides do not interfere for other locale codes
  let my_units = [#(3600, "hX", "hX"), #(60, "minX", "minX"), #(1, "sX", "sX")]
  let my_locale =
    humanize.make_locale("zz", "agoZ", "inZ", "nowZ", " & ", my_units)
  // call with a different code should still use built-in en
  assert humanize.time_ago_unix_with_overrides(
      now + 3600,
      now,
      "en",
      [my_locale],
      False,
      1,
    )
    == "in 1 hour"
}

pub fn time_millis_wrapper_test() {
  let past_millis = 1_000_000 * 1000
  let now_millis = 1_000_360 * 1000
  assert humanize.time_ago_millis(past_millis, now_millis, "en", False, 1)
    == humanize.time_ago_unix(1_000_000, 1_000_360, "en", False, 1)
}

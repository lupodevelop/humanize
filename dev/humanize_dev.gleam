/// Dev playground — run with `gleam dev`
///
/// Exercises every public function of the humanize library and logs the
/// results through woof so you can visually verify the output during
/// development.
import gleam/list
import gleam/option
import gleam/string
import gleam/time/timestamp
import humanize
import woof

pub fn main() {
  // ── Configure logger ──────────────────────────────────────────────
  woof.configure(woof.Config(
    level: woof.Debug,
    format: woof.Custom(dev_format),
    colors: woof.Auto,
  ))

  woof.info("humanize dev playground started", [])

  // ── Numbers ───────────────────────────────────────────────────────
  demo_numbers()

  // ── Bytes ─────────────────────────────────────────────────────────
  demo_bytes()

  // ── Duration ──────────────────────────────────────────────────────
  demo_duration()

  // ── Lists ─────────────────────────────────────────────────────────
  demo_lists()

  // ── Ordinals ──────────────────────────────────────────────────────
  demo_ordinals()

  // ── Percentages ───────────────────────────────────────────────────
  demo_percent()

  // ── Time ago ──────────────────────────────────────────────────────
  demo_time_ago()

  // ── Time ago  (gleam_time Timestamp) ─────────────────────────────
  demo_time_ago_timestamp()

  woof.info("all demos completed", [])
}

// ─── Number formatting ────────────────────────────────────────────────

fn demo_numbers() {
  let log = woof.new("number")

  log
  |> woof.log(woof.Info, "number/1  — compact with 1 decimal (Dot)", [])

  log_each(
    log,
    [0, 42, 999, 1000, 1234, 999_999, 1_000_000, 1_234_567_890],
    fn(n) { humanize.number(n) },
  )

  log
  |> woof.log(woof.Info, "number_with/3  — 2 decimals + Comma", [])

  log_each(
    log,
    [0, 42, 999, 1000, 1234, 999_999, 1_000_000, 1_234_567_890],
    fn(n) { humanize.number_with(n, 2, humanize.Comma) },
  )

  // Negative
  log
  |> woof.log(woof.Debug, "negative: " <> humanize.number(-1500), [
    woof.int_field("input", -1500),
  ])
}

// ─── Byte formatting ──────────────────────────────────────────────────

fn demo_bytes() {
  let log = woof.new("bytes")

  log |> woof.log(woof.Info, "bytes_decimal/1  — base 1000", [])
  log_each(
    log,
    [0, 512, 1000, 1024, 1_536_000, 1_073_741_824, 1_000_000_000_000_000],
    fn(n) { humanize.bytes_decimal(n) },
  )

  log |> woof.log(woof.Info, "bytes_binary/1  — base 1024", [])
  log_each(
    log,
    [0, 512, 1000, 1024, 1_536_000, 1_073_741_824, 1_000_000_000_000_000],
    fn(n) { humanize.bytes_binary(n) },
  )

  // Negative bytes
  log
  |> woof.log(woof.Debug, "negative: " <> humanize.bytes_decimal(-1_536_000), [
    woof.int_field("input", -1_536_000),
  ])
}

// ─── Duration ─────────────────────────────────────────────────────────

fn demo_duration() {
  let log = woof.new("duration")

  log |> woof.log(woof.Info, "duration/1  — largest unit only", [])
  log_each(log, [0, 1, 45, 60, 125, 3600, 3661, 86_400, 90_061], fn(n) {
    humanize.duration(n)
  })

  log |> woof.log(woof.Info, "duration_precise/1  — all units", [])
  log_each(log, [0, 1, 45, 60, 125, 3600, 3661, 86_400, 90_061], fn(n) {
    humanize.duration_precise(n)
  })
}

// ─── Lists ────────────────────────────────────────────────────────────

fn demo_lists() {
  let log = woof.new("list")

  log |> woof.log(woof.Info, "list/1  — natural language join", [])
  log |> woof.log(woof.Debug, humanize.list([]), [woof.field("input", "[]")])
  log
  |> woof.log(woof.Debug, humanize.list(["alpha"]), [
    woof.field("input", "[alpha]"),
  ])
  log
  |> woof.log(woof.Debug, humanize.list(["alpha", "beta"]), [
    woof.field("input", "[alpha, beta]"),
  ])
  log
  |> woof.log(woof.Debug, humanize.list(["alpha", "beta", "gamma"]), [
    woof.field("input", "[alpha, beta, gamma]"),
  ])

  log |> woof.log(woof.Info, "list_with_oxford/1  — Oxford comma", [])
  log
  |> woof.log(
    woof.Debug,
    humanize.list_with_oxford(["alpha", "beta", "gamma"]),
    [],
  )

  log |> woof.log(woof.Info, "list_with_ampersand/1  — & separator", [])
  log
  |> woof.log(
    woof.Debug,
    humanize.list_with_ampersand(["alpha", "beta", "gamma"]),
    [],
  )

  log |> woof.log(woof.Info, "list_locale/3  — custom conjunction", [])
  log
  |> woof.log(
    woof.Debug,
    humanize.list_locale(["uno", "due", "tre"], " e ", False),
    [],
  )
}

// ─── Ordinals ─────────────────────────────────────────────────────────

fn demo_ordinals() {
  let log = woof.new("ordinal")
  log |> woof.log(woof.Info, "ordinal/1  — English ordinal suffixes", [])
  log_each(log, [1, 2, 3, 4, 11, 12, 13, 21, 22, 23, 100, 111, 112, 113], fn(n) {
    humanize.ordinal(n)
  })
}

// ─── Percentages ──────────────────────────────────────────────────────

fn demo_percent() {
  let log = woof.new("percent")

  log |> woof.log(woof.Info, "percent/1  — simple", [])
  log
  |> woof.log(woof.Debug, humanize.percent(50), [woof.int_field("input", 50)])
  log
  |> woof.log(woof.Debug, humanize.percent(100), [woof.int_field("input", 100)])

  log |> woof.log(woof.Info, "percent_with/4  — decimals + spacing", [])
  log
  |> woof.log(woof.Debug, humanize.percent_with(12, 1, humanize.Dot, False), [
    woof.field("opts", "1 dec, Dot, no space"),
  ])
  log
  |> woof.log(woof.Debug, humanize.percent_with(12, 1, humanize.Dot, True), [
    woof.field("opts", "1 dec, Dot, spaced"),
  ])

  log |> woof.log(woof.Info, "percent_ratio/4  — from fraction", [])
  log
  |> woof.log(woof.Debug, humanize.percent_ratio(1, 3, 2, humanize.Comma), [
    woof.field("fraction", "1/3"),
    woof.field("opts", "2 dec, Comma"),
  ])
  log
  |> woof.log(woof.Debug, humanize.percent_ratio(1, 6, 1, humanize.Dot), [
    woof.field("fraction", "1/6"),
    woof.field("opts", "1 dec, Dot"),
  ])

  // Edge case: division by zero
  log
  |> woof.log(
    woof.Warning,
    "denominator=0 → " <> humanize.percent_ratio(1, 0, 0, humanize.Dot),
    [],
  )
}

// ─── Time ago ─────────────────────────────────────────────────────────

fn demo_time_ago() {
  let log = woof.new("time_ago")
  let now = 1_000_000

  log |> woof.log(woof.Info, "time_ago_unix/5  — built-in locales", [])

  // English
  log
  |> woof.log(
    woof.Debug,
    "[en] " <> humanize.time_ago_unix(now - 3600, now, "en", False, 1),
    [woof.field("locale", "en"), woof.field("delta", "-1h")],
  )
  log
  |> woof.log(
    woof.Debug,
    "[en] " <> humanize.time_ago_unix(now + 7200, now, "en", False, 1),
    [woof.field("locale", "en"), woof.field("delta", "+2h future")],
  )

  // Italian
  log
  |> woof.log(
    woof.Debug,
    "[it] " <> humanize.time_ago_unix(now - 120, now, "it", False, 1),
    [woof.field("locale", "it"), woof.field("delta", "-2min")],
  )
  log
  |> woof.log(
    woof.Debug,
    "[it] " <> humanize.time_ago_unix(now - { 3600 + 120 }, now, "it", True, 2),
    [woof.field("locale", "it"), woof.field("delta", "-1h2min precise")],
  )

  // French
  log
  |> woof.log(
    woof.Debug,
    "[fr] " <> humanize.time_ago_unix(now - 7200, now, "fr", False, 1),
    [woof.field("locale", "fr"), woof.field("delta", "-2h")],
  )

  // Spanish
  log
  |> woof.log(
    woof.Debug,
    "[es] " <> humanize.time_ago_unix(now - 86_400, now, "es", False, 1),
    [woof.field("locale", "es"), woof.field("delta", "-1d")],
  )

  // German
  log
  |> woof.log(
    woof.Debug,
    "[de] " <> humanize.time_ago_unix(now - 172_800, now, "de", False, 1),
    [woof.field("locale", "de"), woof.field("delta", "-2d")],
  )

  // Portuguese
  log
  |> woof.log(
    woof.Debug,
    "[pt] " <> humanize.time_ago_unix(now + 3600, now, "pt", False, 1),
    [woof.field("locale", "pt"), woof.field("delta", "+1h future")],
  )

  // "now" threshold
  log
  |> woof.log(
    woof.Debug,
    "[en] " <> humanize.time_ago_unix(now - 3, now, "en", False, 1),
    [woof.field("locale", "en"), woof.field("delta", "-3s → now")],
  )

  // Custom locale override
  log
  |> woof.log(woof.Info, "time_ago_unix_with_overrides/6  — custom locale", [])

  let my_units = [
    #(3600, "ora_custom", "ore_custom"),
    #(60, "minuto_custom", "minuti_custom"),
    #(1, "secondo_custom", "secondi_custom"),
  ]
  let my_locale =
    humanize.make_locale(
      "it-custom",
      "fa",
      "tra",
      "adesso",
      " e ",
      False,
      my_units,
    )

  log
  |> woof.log(
    woof.Debug,
    "[it-custom] "
      <> humanize.time_ago_unix_with_overrides(
      now - 3720,
      now,
      "it-custom",
      [my_locale],
      True,
      2,
    ),
    [woof.field("locale", "it-custom"), woof.field("delta", "-1h2min precise")],
  )

  // Millis wrapper
  log |> woof.log(woof.Info, "time_ago_millis/5  — millisecond wrapper", [])
  let past_ms = { now - 360 } * 1000
  let now_ms = now * 1000
  log
  |> woof.log(
    woof.Debug,
    "[en] " <> humanize.time_ago_millis(past_ms, now_ms, "en", False, 1),
    [
      woof.int_field("past_ms", past_ms),
      woof.int_field("now_ms", now_ms),
    ],
  )

  // Verify consistency: millis == unix
  let unix_result = humanize.time_ago_unix(now - 360, now, "en", False, 1)
  let millis_result = humanize.time_ago_millis(past_ms, now_ms, "en", False, 1)
  case unix_result == millis_result {
    True ->
      log
      |> woof.log(woof.Debug, "millis/unix consistency: OK", [])
    False ->
      log
      |> woof.log(woof.Warning, "millis/unix mismatch!", [
        woof.field("unix", unix_result),
        woof.field("millis", millis_result),
      ])
  }
}

// ─── Time ago (gleam_time Timestamp) ─────────────────────────────────

fn demo_time_ago_timestamp() {
  let log = woof.new("time_ago_ts")
  let now_ts = timestamp.system_time()
  let #(now_s, _) = timestamp.to_unix_seconds_and_nanoseconds(now_ts)

  log
  |> woof.log(woof.Info, "time_ago_timestamp/5  — gleam_time Timestamp", [])

  // 1 hour ago — English
  log
  |> woof.log(
    woof.Debug,
    "[en] "
      <> humanize.time_ago_timestamp(
      timestamp.from_unix_seconds(now_s - 3600),
      now_ts,
      "en",
      False,
      1,
    ),
    [woof.field("delta", "-1h")],
  )

  // 2 hours ago — French
  log
  |> woof.log(
    woof.Debug,
    "[fr] "
      <> humanize.time_ago_timestamp(
      timestamp.from_unix_seconds(now_s - 7200),
      now_ts,
      "fr",
      False,
      1,
    ),
    [woof.field("delta", "-2h")],
  )

  // 25h 1m 1s ago — Italian precise
  log
  |> woof.log(
    woof.Debug,
    "[it] "
      <> humanize.time_ago_timestamp(
      timestamp.from_unix_seconds(now_s - 90_061),
      now_ts,
      "it",
      True,
      3,
    ),
    [woof.field("delta", "-25h1min1s precise")],
  )

  // 1 hour in the future — Spanish
  log
  |> woof.log(
    woof.Debug,
    "[es] "
      <> humanize.time_ago_timestamp(
      timestamp.from_unix_seconds(now_s + 3600),
      now_ts,
      "es",
      False,
      1,
    ),
    [woof.field("delta", "+1h future")],
  )
}

// ─── Helpers ──────────────────────────────────────────────────────────

fn log_each(log, samples: List(Int), formatter: fn(Int) -> String) {
  case samples {
    [] -> Nil
    [n, ..rest] -> {
      log
      |> woof.log(woof.Debug, formatter(n), [woof.int_field("input", n)])
      log_each(log, rest, formatter)
    }
  }
}

/// Custom formatter 
/// Formatter woof.Custom: usa woof.Entry e woof.level_name.
/// I messaggi Debug (= valori risultato) vengono evidenziati in bold cyan;
/// gli altri livelli mantengono il colore standard del prefisso livello.
fn dev_format(entry: woof.Entry) -> String {
  let reset = "\u{001B}[0m"

  let lvl_color = case entry.level {
    woof.Debug -> "\u{001B}[2;37m"
    woof.Info -> "\u{001B}[34m"
    woof.Warning -> "\u{001B}[33m"
    woof.Error -> "\u{001B}[1;31m"
  }

  let level_str =
    lvl_color
    <> "["
    <> string.uppercase(woof.level_name(entry.level))
    <> "]"
    <> reset

  let ns_prefix = case entry.namespace {
    option.Some(n) -> n <> ": "
    option.None -> ""
  }

  // Debug = valore risultato umanizzato → bold cyan
  let msg = case entry.level {
    woof.Debug -> "\u{001B}[1;36m" <> entry.message <> reset
    _ -> entry.message
  }

  let header = level_str <> " " <> entry.timestamp <> " " <> ns_prefix <> msg

  case entry.fields {
    [] -> header
    fields ->
      header
      <> "\n"
      <> string.join(
        list.map(fields, fn(f) { "  " <> f.0 <> ": " <> f.1 }),
        "\n",
      )
  }
}

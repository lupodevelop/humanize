/// Internal localization data for built-in locales.
///
/// Data is stored as raw tuples to avoid circular dependencies with
/// the public `LocaleData` type.
///
/// Tuple layout:
///   #(ago, in_, now, conj, ago_prefix, units)
///
/// `ago_prefix` — when `True` the "ago" word is placed **before** the time
/// core (e.g. FR "il y a 2 heures", ES "hace 1 día").  When `False` it goes
/// **after** (e.g. EN "1 hour ago", IT "1 ora fa").
///
/// Built-in locales mapping.
pub fn locales_raw() -> List(
  #(
    String,
    #(String, String, String, String, Bool, List(#(Int, String, String))),
  ),
) {
  [
    #(
      "it",
      #("fa", "tra", "adesso", " e ", False, [
        #(31_536_000, "anno", "anni"),
        #(2_592_000, "mese", "mesi"),
        #(86_400, "giorno", "giorni"),
        #(3600, "ora", "ore"),
        #(60, "minuto", "minuti"),
        #(1, "secondo", "secondi"),
      ]),
    ),
    #(
      "en",
      #("ago", "in", "now", " and ", False, [
        #(31_536_000, "year", "years"),
        #(2_592_000, "month", "months"),
        #(86_400, "day", "days"),
        #(3600, "hour", "hours"),
        #(60, "minute", "minutes"),
        #(1, "second", "seconds"),
      ]),
    ),
    #(
      "es",
      #("hace", "en", "ahora", " y ", True, [
        #(31_536_000, "año", "años"),
        #(2_592_000, "mes", "meses"),
        #(86_400, "día", "días"),
        #(3600, "hora", "horas"),
        #(60, "minuto", "minutos"),
        #(1, "segundo", "segundos"),
      ]),
    ),
    #(
      "fr",
      #("il y a", "dans", "maintenant", " et ", True, [
        #(31_536_000, "an", "ans"),
        #(2_592_000, "mois", "mois"),
        #(86_400, "jour", "jours"),
        #(3600, "heure", "heures"),
        #(60, "minute", "minutes"),
        #(1, "seconde", "secondes"),
      ]),
    ),
    #(
      "de",
      #("vor", "in", "jetzt", " und ", True, [
        #(31_536_000, "Jahr", "Jahre"),
        #(2_592_000, "Monat", "Monate"),
        #(86_400, "Tag", "Tage"),
        #(3600, "Stunde", "Stunden"),
        #(60, "Minute", "Minuten"),
        #(1, "Sekunde", "Sekunden"),
      ]),
    ),
    #(
      "pt",
      #("há", "em", "agora", " e ", True, [
        #(31_536_000, "ano", "anos"),
        #(2_592_000, "mês", "meses"),
        #(86_400, "dia", "dias"),
        #(3600, "hora", "horas"),
        #(60, "minuto", "minutos"),
        #(1, "segundo", "segundos"),
      ]),
    ),
  ]
}

/// Fallback locale data (English).
pub fn default_raw() -> #(
  String,
  String,
  String,
  String,
  Bool,
  List(#(Int, String, String)),
) {
  #("ago", "in", "now", " and ", False, [
    #(31_536_000, "year", "years"),
    #(2_592_000, "month", "months"),
    #(86_400, "day", "days"),
    #(3600, "hour", "hours"),
    #(60, "minute", "minutes"),
    #(1, "second", "seconds"),
  ])
}

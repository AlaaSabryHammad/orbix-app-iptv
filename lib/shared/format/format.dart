import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n.dart';
import '../../data/core/failures.dart';

/// Formatting shared by every screen. Numbers, times and sizes always use
/// Western digits (spec: "Western digits for times and channel numbers"),
/// so NumberFormat is pinned to `en` even in Arabic.
abstract final class Fmt {
  static final _count = NumberFormat.decimalPattern('en');

  /// 1284 → "1,284".
  static String count(int n) => _count.format(n);

  /// 4404019 → "4.2 MB".
  static String bytes(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
    if (b < 1024 * 1024 * 1024) return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(b / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
  }

  /// 8280 s → "2h 18m" («2 س 18 د»); 2940 s → "49 min" («49 دقيقة»).
  static String runtime(AppLocalizations l, Duration d) {
    final h = d.inHours, m = d.inMinutes % 60;
    if (h == 0) return l.minutesShort(m);
    if (m == 0) return l.durationHours(h);
    // English pads ("1h 05m"); Arabic doesn't («1 س 5 د»).
    return l.durationHoursMinutes(h, l.localeName == 'en' ? m.toString().padLeft(2, '0') : '$m');
  }

  /// "18 min left" / «متبقٍ 18 دقيقة».
  static String left(AppLocalizations l, Duration d) => l.timeLeft(runtime(l, d));

  /// 20:30 (24 h, local time).
  static String clock(DateTime t) => DateFormat.Hm('en').format(t.toLocal());

  /// "20:30–22:30" — wrapped in a left-to-right isolate (U+2066…U+2069):
  /// inside Arabic text the bidi algorithm would otherwise show the two
  /// times swapped («22:30–20:30»).
  static String range(DateTime a, DateTime b) => '\u2066${clock(a)}–${clock(b)}\u2069';

  /// 1:12:44 / 34:52 — player and resume positions.
  static String position(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  /// "02 Feb 2027" (localized month name).
  static String date(BuildContext context, DateTime d) =>
      DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode).format(d.toLocal());

  /// "2 h ago", "Yesterday", "12 Sep".
  static String relative(BuildContext context, DateTime? t, {DateTime? now}) {
    final l = context.l10n;
    if (t == null) return l.lastUsedNever;
    final n = now ?? DateTime.now();
    final diff = n.difference(t);
    if (diff.inMinutes < 1) return l.justNow;
    if (diff.inHours < 1) return l.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24 && n.day == t.day) return l.hoursAgo(diff.inHours);
    if (diff.inDays < 2) return l.yesterday;
    if (diff.inDays < 7) return l.daysAgo(diff.inDays);
    return DateFormat('d MMM', Localizations.localeOf(context).languageCode).format(t);
  }
}

/// User-facing text for a failure (States 06–10 copy).
String describeFailure(BuildContext context, OrbixFailure f) {
  final l = context.l10n;
  return switch (f) {
    OfflineFailure() => l.errorOfflineBody,
    HostNotFoundFailure() => l.errorHostNotFound,
    ConnectionRefusedFailure() => l.errorRefused,
    ServerTimeoutFailure(:final host) => l.errorTimeoutBody(host ?? '—'),
    ServerErrorFailure(:final statusCode) => l.errorServer(statusCode),
    AccessDeniedFailure(:final statusCode) => l.errorAccessDenied(statusCode),
    InvalidCredentialsFailure() => l.errorCredentials,
    AccountExpiredFailure() => l.errorExpiredShort,
    AccountDisabledFailure(:final status) => l.errorDisabled(status),
    NotIptvServerFailure() => l.errorNotIptv,
    InvalidPlaylistFailure() => l.errorPlaylist,
    InvalidGuideFailure() => l.errorGuide,
    TlsFailure() => l.errorTls,
    CancelledFailure() || UnknownFailure() => l.errorUnknown,
  };
}

/// Technical one-liner under an error ("DNS lookup failed · host:8080").
String? failureDetail(OrbixFailure f) => switch (f) {
      HostNotFoundFailure(:final host) => 'DNS lookup failed${host == null ? '' : ' · $host'}',
      ConnectionRefusedFailure(:final host) => 'Connection refused${host == null ? '' : ' · $host'}',
      ServerTimeoutFailure(:final host) => 'Timed out after 10 s${host == null ? '' : ' · $host'}',
      ServerErrorFailure(:final statusCode) => 'HTTP $statusCode',
      AccessDeniedFailure(:final statusCode) => 'HTTP $statusCode',
      NotIptvServerFailure(:final detail) || InvalidPlaylistFailure(:final detail) || InvalidGuideFailure(:final detail) => detail,
      _ => null,
    };

import 'dart:convert';

/// Secrets of one account. Never stored in the database — only in
/// [CredentialStore] (Android Keystore-backed encryption).
sealed class AccountCredentials {
  const AccountCredentials();

  Map<String, Object?> toJson();

  static AccountCredentials fromJson(Map<String, Object?> json) => switch (json['type']) {
        'xtream' => XtreamCredentials(
            serverUrl: json['serverUrl']! as String,
            username: json['username']! as String,
            password: json['password']! as String,
            epgUrl: json['epgUrl'] as String?,
          ),
        'playlist' => PlaylistCredentials(
            playlistUrl: json['playlistUrl'] as String?,
            filePath: json['filePath'] as String?,
            epgUrl: json['epgUrl'] as String?,
            headerEpgUrls: [...?(json['headerEpgUrls'] as List?)?.whereType<String>()],
          ),
        final t => throw FormatException('Unknown credential type $t'),
      };

  String encode() => jsonEncode(toJson());

  static AccountCredentials decode(String raw) => fromJson((jsonDecode(raw) as Map).cast<String, Object?>());

  /// Optional user-supplied XMLTV URL (may embed credentials too).
  String? get epgUrl;

  /// The same login with a different user EPG URL (Settings › EPG sources).
  AccountCredentials withEpgUrl(String? url) => switch (this) {
        final XtreamCredentials c => XtreamCredentials(serverUrl: c.serverUrl, username: c.username, password: c.password, epgUrl: url),
        final PlaylistCredentials c => PlaylistCredentials(playlistUrl: c.playlistUrl, filePath: c.filePath, epgUrl: url, headerEpgUrls: c.headerEpgUrls),
      };
}

/// Xtream Codes login.
class XtreamCredentials extends AccountCredentials {
  XtreamCredentials({required String serverUrl, required this.username, required this.password, this.epgUrl})
      : serverUrl = normalizeServerUrl(serverUrl);

  /// Normalised base URL, e.g. `http://line.provider.tv:8080` (no trailing slash).
  final String serverUrl;
  final String username;
  final String password;
  @override
  final String? epgUrl;

  Uri get baseUri => Uri.parse(serverUrl);

  /// `host:port` for display ("line.yourprovider.tv:8080").
  String get displayHost => baseUri.hasPort ? '${baseUri.host}:${baseUri.port}' : baseUri.host;

  /// Recognises an Xtream M3U link pasted into the M3U field —
  /// `http://host:port/get.php?username=u&password=p&type=m3u_plus` — so the
  /// account can use the richer Xtream API instead.
  static XtreamCredentials? tryFromPlaylistUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.path.endsWith('get.php')) return null;
    final u = uri.queryParameters['username'];
    final p = uri.queryParameters['password'];
    if (u == null || p == null || u.isEmpty) return null;
    return XtreamCredentials(serverUrl: uri.replace(query: '').toString(), username: u, password: p);
  }

  @override
  Map<String, Object?> toJson() => {'type': 'xtream', 'serverUrl': serverUrl, 'username': username, 'password': password, 'epgUrl': epgUrl};
}

/// M3U playlist from a URL, or a local file copied into app storage.
class PlaylistCredentials extends AccountCredentials {
  const PlaylistCredentials({this.playlistUrl, this.filePath, this.epgUrl, this.headerEpgUrls = const []})
      : assert(playlistUrl != null || filePath != null);

  final String? playlistUrl;
  final String? filePath;

  /// User-entered guide URL.
  @override
  final String? epgUrl;

  /// Guides advertised by the playlist header (`url-tvg`) — they often carry
  /// the same credentials as the playlist URL, so they live here too.
  final List<String> headerEpgUrls;

  PlaylistCredentials withHeaderEpgUrls(List<String> urls) =>
      PlaylistCredentials(playlistUrl: playlistUrl, filePath: filePath, epgUrl: epgUrl, headerEpgUrls: urls);

  bool get isFile => filePath != null;

  /// Host only — playlist URLs usually embed the username and password.
  String? get displayHost {
    final u = playlistUrl == null ? null : Uri.tryParse(playlistUrl!);
    if (u == null) return null;
    return u.hasPort ? '${u.host}:${u.port}' : u.host;
  }

  @override
  Map<String, Object?> toJson() =>
      {'type': 'playlist', 'playlistUrl': playlistUrl, 'filePath': filePath, 'epgUrl': epgUrl, 'headerEpgUrls': headerEpgUrls};
}

/// Accepts what users type: `line.tv:8080`, `http://line.tv:8080/`,
/// `http://line.tv/player_api.php?username=…`, a panel under a sub-path…
/// and returns `scheme://host[:port][/path]` without trailing slash or
/// Xtream endpoint file.
String normalizeServerUrl(String input) {
  var s = input.trim();
  if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(s)) s = 'http://$s';
  final uri = Uri.parse(s);
  var path = uri.path;
  for (final file in const ['player_api.php', 'get.php', 'xmltv.php', 'panel_api.php']) {
    if (path.endsWith(file)) path = path.substring(0, path.length - file.length);
  }
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return Uri(scheme: uri.scheme.toLowerCase(), host: uri.host, port: uri.hasPort ? uri.port : null, path: path).toString();
}

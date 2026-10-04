import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// Everything that can go wrong talking to a provider, classified so the UI
/// can show the matching designed state (States.dc.html 06–10).
sealed class OrbixFailure implements Exception {
  const OrbixFailure();

  /// Classifies [error] (Dio, socket, TLS, parsing…) into a failure.
  factory OrbixFailure.from(Object error, {Uri? uri}) {
    if (error is OrbixFailure) return error;
    final host = uri == null ? null : _hostPort(uri);
    if (error is DioException) {
      final u = error.requestOptions.uri;
      final h = host ?? _hostPort(u);
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.transformTimeout =>
          ServerTimeoutFailure(h),
        DioExceptionType.badCertificate => TlsFailure(h),
        DioExceptionType.cancel => const CancelledFailure(),
        DioExceptionType.badResponse => _fromStatus(error.response?.statusCode ?? 0, h),
        DioExceptionType.connectionError || DioExceptionType.unknown => _fromLowLevel(error.error ?? error, h),
      };
    }
    return _fromLowLevel(error, host);
  }
}

String _hostPort(Uri u) => u.hasPort ? '${u.host}:${u.port}' : u.host;

OrbixFailure _fromStatus(int status, String? host) => switch (status) {
      401 || 403 => AccessDeniedFailure(status),
      404 => const NotIptvServerFailure('HTTP 404'),
      >= 500 => ServerErrorFailure(status, host),
      _ => NotIptvServerFailure('HTTP $status'),
    };

OrbixFailure _fromLowLevel(Object e, String? host) {
  if (e is OrbixFailure) return e;
  if (e is TimeoutException) return ServerTimeoutFailure(host);
  if (e is HandshakeException || e is TlsException) return TlsFailure(host);
  if (e is SocketException) {
    final msg = e.message.toLowerCase();
    final os = e.osError;
    final code = os?.errorCode;
    final osMsg = os?.message.toLowerCase() ?? '';
    if (msg.contains('failed host lookup') || osMsg.contains('no address associated') || osMsg.contains('nodename nor servname')) {
      return HostNotFoundFailure(host ?? e.address?.host);
    }
    // ENETUNREACH (101) / ENETDOWN (100): no usable network at all.
    if (code == 101 || code == 100 || osMsg.contains('network is unreachable')) return const OfflineFailure();
    // ECONNREFUSED (111) / EHOSTUNREACH (113): host known but not answering.
    if (code == 111 || code == 113 || osMsg.contains('refused')) return ConnectionRefusedFailure(host);
    if (osMsg.contains('timed out')) return ServerTimeoutFailure(host);
    return ConnectionRefusedFailure(host);
  }
  if (e is FormatException) return NotIptvServerFailure(e.message);
  if (e is HttpException) return NotIptvServerFailure(e.message);
  return UnknownFailure(e);
}

/// No network at all (States 06).
final class OfflineFailure extends OrbixFailure {
  const OfflineFailure();
}

/// DNS lookup failed — wrong URL, or the device is offline (States 10).
/// Phase 7 tells the two apart with connectivity status.
final class HostNotFoundFailure extends OrbixFailure {
  const HostNotFoundFailure(this.host);
  final String? host;
}

/// Host resolved but refused / unreachable — wrong port, server down.
final class ConnectionRefusedFailure extends OrbixFailure {
  const ConnectionRefusedFailure(this.host);
  final String? host;
}

/// "Server isn't responding" (States 07).
final class ServerTimeoutFailure extends OrbixFailure {
  const ServerTimeoutFailure(this.host);
  final String? host;
}

/// Provider returned 5xx (States 07).
final class ServerErrorFailure extends OrbixFailure {
  const ServerErrorFailure(this.statusCode, this.host);
  final int statusCode;
  final String? host;
}

/// 401 / 403 — often a blocked user agent or IP, not bad credentials.
final class AccessDeniedFailure extends OrbixFailure {
  const AccessDeniedFailure(this.statusCode);
  final int statusCode;
}

/// Xtream `auth: 0` — "Username or password is incorrect" (States 09).
final class InvalidCredentialsFailure extends OrbixFailure {
  const InvalidCredentialsFailure();
}

/// Provider reports the subscription ended (States 08).
final class AccountExpiredFailure extends OrbixFailure {
  const AccountExpiredFailure(this.expiresAt);
  final DateTime? expiresAt;
}

/// Banned / disabled by the provider.
final class AccountDisabledFailure extends OrbixFailure {
  const AccountDisabledFailure(this.status);
  final String status;
}

/// Answered, but not like an IPTV server (HTML page, 404, garbage JSON).
final class NotIptvServerFailure extends OrbixFailure {
  const NotIptvServerFailure(this.detail);
  final String detail;
}

/// Downloaded, but not an M3U playlist.
final class InvalidPlaylistFailure extends OrbixFailure {
  const InvalidPlaylistFailure(this.detail);
  final String detail;
}

/// Downloaded, but not XMLTV.
final class InvalidGuideFailure extends OrbixFailure {
  const InvalidGuideFailure(this.detail);
  final String detail;
}

final class TlsFailure extends OrbixFailure {
  const TlsFailure(this.host);
  final String? host;
}

final class CancelledFailure extends OrbixFailure {
  const CancelledFailure();
}

final class UnknownFailure extends OrbixFailure {
  const UnknownFailure(this.error);
  final Object error;

  @override
  String toString() => 'UnknownFailure($error)';
}

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/failures.dart';

class DownloadResult {
  const DownloadResult(this.bytes, this.latency);

  final Uint8List bytes;

  /// Time to response headers — "Server reachable · 118 ms".
  final Duration latency;
}

/// Downloads playlists / guides with latency and byte progress.
class PlaylistLoader {
  PlaylistLoader(this._dio);

  final Dio _dio;

  /// [onHeaders] fires once the server answered (with the latency);
  /// [onBytes] reports received / total (total -1 when unknown).
  Future<DownloadResult> download(
    String url, {
    Map<String, String>? headers,
    void Function(Duration latency)? onHeaders,
    void Function(int received, int total)? onBytes,
    CancelToken? cancel,
  }) async {
    final uri = Uri.parse(url);
    final sw = Stopwatch()..start();
    try {
      final r = await _dio.getUri<ResponseBody>(
        uri,
        options: Options(responseType: ResponseType.stream, headers: headers),
        cancelToken: cancel,
      );
      final latency = sw.elapsed;
      onHeaders?.call(latency);
      final body = r.data!;
      final total = body.contentLength;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in body.stream) {
        builder.add(chunk);
        onBytes?.call(builder.length, total);
      }
      return DownloadResult(builder.takeBytes(), latency);
    } catch (e) {
      throw OrbixFailure.from(e, uri: uri);
    }
  }

  /// Streams [url] straight to [file] (large XMLTV guides).
  Future<Duration> downloadToFile(
    String url,
    File file, {
    void Function(int received, int total)? onBytes,
    CancelToken? cancel,
  }) async {
    final uri = Uri.parse(url);
    final sw = Stopwatch()..start();
    try {
      await _dio.downloadUri(uri, file.path, cancelToken: cancel, onReceiveProgress: onBytes);
      return sw.elapsed;
    } catch (e) {
      if (await file.exists()) await file.delete();
      throw OrbixFailure.from(e, uri: uri);
    }
  }
}

/// Local playlists ("Choose a local file") are copied into app storage so the
/// account keeps working after the original file moves.
abstract final class PlaylistFiles {
  static Future<Directory> _dir() async {
    final d = Directory('${(await getApplicationSupportDirectory()).path}/playlists');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  /// Copies [source] and returns the stored path.
  static Future<String> import(File source, {required String name}) async {
    final target = File('${(await _dir()).path}/$name.m3u');
    await source.copy(target.path);
    return target.path;
  }

  /// Stores picked bytes (Android content URIs have no file path).
  static Future<String> importBytes(List<int> bytes, {required String name}) async {
    final target = File('${(await _dir()).path}/$name.m3u');
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  }

  static Future<Uint8List> read(String path) async {
    try {
      return await File(path).readAsBytes();
    } on FileSystemException catch (e) {
      throw InvalidPlaylistFailure('Playlist file unavailable: ${e.message}');
    }
  }
}

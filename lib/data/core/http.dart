import 'package:dio/dio.dart';

/// Default user agent. Some providers filter by UA; a per-account override
/// arrives with the playback settings (Phase 4/5).
const orbixUserAgent = 'Orbix/1.0 (Android; IPTV player)';

/// "Server isn't responding — didn't answer within 10 seconds" (States 07).
const connectTimeout = Duration(seconds: 10);

/// Full catalogs (tens of MB of JSON) and guides can take a while.
const receiveTimeout = Duration(seconds: 90);

Dio createDio({String userAgent = orbixUserAgent}) => Dio(
      BaseOptions(
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {'User-Agent': userAgent, 'Accept': '*/*'},
        followRedirects: true,
        maxRedirects: 5,
        // Bodies are decoded by our own parsers (in isolates).
        responseType: ResponseType.bytes,
      ),
    );

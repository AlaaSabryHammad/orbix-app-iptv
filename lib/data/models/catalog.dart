/// Source-neutral catalog models. Xtream and M3U both parse into these (in
/// background isolates — they are plain, sendable data), and the catalog
/// repository writes them to the database.
library;

enum ContentKind { live, movie, series }

class CatalogCategory {
  const CatalogCategory({required this.id, required this.kind, required this.name, this.sortIndex = 0, this.isAdult = false});

  final String id;
  final ContentKind kind;
  final String name;
  final int sortIndex;
  final bool isAdult;
}

class CatalogChannel {
  const CatalogChannel({
    required this.id,
    required this.name,
    this.number,
    this.logo,
    this.categoryId,
    this.epgId,
    this.streamUrl,
    this.headers,
    this.catchupDays = 0,
    this.sortIndex = 0,
    this.addedAt,
  });

  final String id;
  final String name;
  final int? number;
  final String? logo;
  final String? categoryId;

  /// XMLTV channel id (tvg-id / epg_channel_id), normalised lower-case.
  final String? epgId;

  /// Direct URL (M3U). Xtream URLs are built from credentials at play time.
  final String? streamUrl;

  /// Per-stream HTTP headers (`#EXTVLCOPT:http-user-agent=…`, `|Referer=…`).
  final Map<String, String>? headers;
  final int catchupDays;
  final int sortIndex;
  final DateTime? addedAt;
}

class CatalogMovie {
  const CatalogMovie({
    required this.id,
    required this.name,
    this.poster,
    this.rating,
    this.year,
    this.addedAt,
    this.categoryId,
    this.containerExt,
    this.streamUrl,
    this.sortIndex = 0,
  });

  final String id;
  final String name;
  final String? poster;

  /// 0–10.
  final double? rating;
  final int? year;
  final DateTime? addedAt;
  final String? categoryId;
  final String? containerExt;
  final String? streamUrl;
  final int sortIndex;
}

class CatalogSeries {
  const CatalogSeries({
    required this.id,
    required this.name,
    this.cover,
    this.backdrop,
    this.plot,
    this.rating,
    this.year,
    this.genre,
    this.updatedAt,
    this.categoryId,
    this.sortIndex = 0,
  });

  final String id;
  final String name;
  final String? cover;
  final String? backdrop;
  final String? plot;
  final double? rating;
  final int? year;
  final String? genre;
  final DateTime? updatedAt;
  final String? categoryId;
  final int sortIndex;
}

class CatalogEpisode {
  const CatalogEpisode({
    required this.id,
    required this.seriesId,
    required this.season,
    required this.episode,
    required this.title,
    this.containerExt,
    this.streamUrl,
    this.durationSecs,
    this.plot,
    this.still,
    this.airDate,
  });

  final String id;
  final String seriesId;
  final int season;
  final int episode;
  final String title;
  final String? containerExt;
  final String? streamUrl;
  final int? durationSecs;
  final String? plot;
  final String? still;
  final DateTime? airDate;
}

/// A whole parsed catalog (M3U import) or one section of it (Xtream sync).
class CatalogSnapshot {
  const CatalogSnapshot({
    this.categories = const [],
    this.channels = const [],
    this.movies = const [],
    this.series = const [],
    this.episodes = const [],
    this.epgUrls = const [],
  });

  final List<CatalogCategory> categories;
  final List<CatalogChannel> channels;
  final List<CatalogMovie> movies;
  final List<CatalogSeries> series;
  final List<CatalogEpisode> episodes;

  /// Guide URLs advertised by the playlist header (`url-tvg`, `x-tvg-url`).
  final List<String> epgUrls;
}

/// Movie details (Xtream `get_vod_info`).
class MovieDetails {
  const MovieDetails({
    required this.id,
    this.name,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.durationSecs,
    this.backdrop,
    this.poster,
    this.trailerYoutubeId,
    this.releaseDate,
    this.rating,
    this.tmdbId,
    this.containerExt,
  });

  final String id;
  final String? name;
  final String? plot;
  final String? cast;
  final String? director;
  final String? genre;
  final int? durationSecs;
  final String? backdrop;
  final String? poster;
  final String? trailerYoutubeId;
  final String? releaseDate;
  final double? rating;
  final String? tmdbId;
  final String? containerExt;
}

class SeasonInfo {
  const SeasonInfo({required this.number, this.name, this.episodeCount, this.cover, this.overview});

  final int number;
  final String? name;
  final int? episodeCount;
  final String? cover;
  final String? overview;
}

/// Series details with all episodes (Xtream `get_series_info`).
class SeriesDetails {
  const SeriesDetails({
    required this.series,
    required this.seasons,
    required this.episodes,
    this.cast,
    this.director,
    this.trailerYoutubeId,
  });

  final CatalogSeries series;
  final List<SeasonInfo> seasons;
  final List<CatalogEpisode> episodes;
  final String? cast;
  final String? director;
  final String? trailerYoutubeId;
}

/// One programme as delivered by a guide source.
class GuideEntry {
  const GuideEntry({required this.channelId, required this.start, required this.stop, required this.title, this.description, this.category, this.image});

  /// Normalised (lower-case) XMLTV channel id.
  final String channelId;
  final DateTime start;
  final DateTime stop;
  final String title;
  final String? description;
  final String? category;

  /// Programme artwork URL, when the guide has one.
  final String? image;
}

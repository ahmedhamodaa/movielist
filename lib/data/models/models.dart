// ==================== models.dart ====================
class AccountDetails {
  final int id;
  final String username;
  final String name;
  final bool includeAdult;
  final String iso6391;
  final String iso31661;
  final Avatar avatar;

  AccountDetails({
    required this.id,
    required this.username,
    required this.name,
    required this.includeAdult,
    required this.iso6391,
    required this.iso31661,
    required this.avatar,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    return AccountDetails(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      includeAdult: json['include_adult'] ?? false,
      iso6391: json['iso_639_1'] ?? '',
      iso31661: json['iso_3166_1'] ?? '',
      avatar: Avatar.fromJson(json['avatar'] ?? {}),
    );
  }
}

class Avatar {
  final Gravatar gravatar;
  final Tmdb tmdb;

  Avatar({required this.gravatar, required this.tmdb});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      gravatar: Gravatar.fromJson(json['gravatar'] ?? {}),
      tmdb: Tmdb.fromJson(json['tmdb'] ?? {}),
    );
  }
}

class Gravatar {
  final String hash;

  Gravatar({required this.hash});

  factory Gravatar.fromJson(Map<String, dynamic> json) {
    return Gravatar(hash: json['hash'] ?? '');
  }

  String getAvatarUrl() {
    return 'https://www.gravatar.com/avatar/$hash';
  }
}

class Tmdb {
  final String? avatarPath;

  Tmdb({this.avatarPath});

  factory Tmdb.fromJson(Map<String, dynamic> json) {
    return Tmdb(avatarPath: json['avatar_path']);
  }
}

class Movie {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final String? releaseDate;
  final List<int>? genreIds;

  Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.releaseDate,
    this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: json['vote_average']?.toDouble(),
      releaseDate: json['release_date'],
      genreIds: json['genre_ids']?.cast<int>(),
    );
  }

  String getPosterUrl() {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String getBackdropUrl() {
    if (backdropPath == null) return '';
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }
}

class TVShow {
  final int id;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final String? firstAirDate;
  final List<int>? genreIds;

  TVShow({
    required this.id,
    required this.name,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.firstAirDate,
    this.genreIds,
  });

  factory TVShow.fromJson(Map<String, dynamic> json) {
    return TVShow(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: json['vote_average']?.toDouble(),
      firstAirDate: json['first_air_date'],
      genreIds: json['genre_ids']?.cast<int>(),
    );
  }

  String getPosterUrl() {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String getBackdropUrl() {
    if (backdropPath == null) return '';
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }
}

class MediaItem {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final String? releaseDate;
  final String mediaType; // 'movie' or 'tv'

  MediaItem({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.releaseDate,
    required this.mediaType,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final mediaType = json['media_type'] ?? 'movie';
    return MediaItem(
      id: json['id'] ?? 0,
      title: mediaType == 'movie'
          ? (json['title'] ?? '')
          : (json['name'] ?? ''),
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: json['vote_average']?.toDouble(),
      releaseDate: mediaType == 'movie'
          ? json['release_date']
          : json['first_air_date'],
      mediaType: mediaType,
    );
  }

  String getPosterUrl() {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String getBackdropUrl() {
    if (backdropPath == null) return '';
    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }
}

class MovieList {
  final int id;
  final String name;
  final String? description;
  final int itemCount;
  final String? posterPath;
  final String? backdropPath;
  final String? createdAt;
  final String? updatedAt;

  MovieList({
    required this.id,
    required this.name,
    this.description,
    required this.itemCount,
    this.posterPath,
    this.backdropPath,
    this.createdAt,
    this.updatedAt,
  });

  factory MovieList.fromJson(Map<String, dynamic> json) {
    return MovieList(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      itemCount: json['item_count'] ?? 0,
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  String getPosterUrl() {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}

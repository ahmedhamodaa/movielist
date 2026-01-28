// ==================== tmdb_service.dart ====================
import 'package:http/http.dart' as http;
import 'package:movielist/data/models/models.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TmdbService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = '5da32c959748bb97a3096aa04cff2956';
  static const String bearerToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1ZGEzMmM5NTk3NDhiYjk3YTMwOTZhYTA0Y2ZmMjk1NiIsIm5iZiI6MTc0NzI1NzY5Ny4wNiwic3ViIjoiNjgyNTA5NjFkZGY2ZDk5OTljYWQ5ZjE3Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.1oI-Mf8zDT7r5xroUeI0d-s8hWRWJvB3Q1lyJSQHjhw';

  // Login user and get session ID
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Step 1: Get request token
      final tokenUrl = Uri.parse('$baseUrl/authentication/token/new');
      final tokenResponse = await http.get(
        tokenUrl,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (tokenResponse.statusCode != 200) {
        return {'success': false, 'message': 'Failed to get token'};
      }

      final tokenData = json.decode(tokenResponse.body);
      final requestToken = tokenData['request_token'];

      // Step 2: Validate request token with login credentials
      final validateUrl = Uri.parse(
        '$baseUrl/authentication/token/validate_with_login',
      );
      final validateResponse = await http.post(
        validateUrl,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
          'request_token': requestToken,
        }),
      );

      if (validateResponse.statusCode != 200) {
        final error = json.decode(validateResponse.body);
        return {
          'success': false,
          'message': error['status_message'] ?? 'Invalid credentials',
        };
      }

      // Step 3: Create session
      final sessionUrl = Uri.parse('$baseUrl/authentication/session/new');
      final sessionResponse = await http.post(
        sessionUrl,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'request_token': requestToken}),
      );

      if (sessionResponse.statusCode == 200) {
        final sessionData = json.decode(sessionResponse.body);
        final sessionId = sessionData['session_id'];
        await saveSessionId(sessionId);
        return {'success': true, 'session_id': sessionId};
      }

      return {'success': false, 'message': 'Failed to create session'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get account details
  Future<AccountDetails?> getAccountDetails(String sessionId) async {
    try {
      final url = Uri.parse('$baseUrl/account?session_id=$sessionId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AccountDetails.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // Save session ID locally
  Future<void> saveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tmdb_session_id', sessionId);
  }

  // Get saved session ID
  Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tmdb_session_id');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final sessionId = await getSessionId();
    return sessionId != null;
  }

  // Logout and delete session
  Future<bool> logout() async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return false;

      final url = Uri.parse('$baseUrl/authentication/session');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'session_id': sessionId}),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tmdb_session_id');

      return response.statusCode == 200;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  // Search movies and TV shows
  Future<Map<String, List<dynamic>>> search(
    String query, {
    int page = 1,
  }) async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return {'movies': [], 'tv': []};

      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        '$baseUrl/search/multi?query=$encodedQuery&page=$page&include_adult=false',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        final movies = <Movie>[];
        final tvShows = <TVShow>[];

        for (var item in results) {
          if (item['media_type'] == 'movie') {
            movies.add(Movie.fromJson(item));
          } else if (item['media_type'] == 'tv') {
            tvShows.add(TVShow.fromJson(item));
          }
        }

        return {'movies': movies, 'tv': tvShows};
      }
      return {'movies': [], 'tv': []};
    } catch (e) {
      print('Search error: $e');
      return {'movies': [], 'tv': []};
    }
  }

  // Get popular movies
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/movie/popular?page=$page');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get popular movies error: $e');
      return [];
    }
  }

  // Get popular TV shows
  Future<List<TVShow>> getPopularTVShows({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/tv/popular?page=$page');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => TVShow.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get popular TV shows error: $e');
      return [];
    }
  }

  // Get top rated movies
  Future<List<Movie>> getTopRatedMovies({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/movie/top_rated?page=$page');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get top rated movies error: $e');
      return [];
    }
  }

  // Get top rated TV shows
  Future<List<TVShow>> getTopRatedTVShows({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/tv/top_rated?page=$page');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => TVShow.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get top rated TV shows error: $e');
      return [];
    }
  }

  // Get upcoming movies
  Future<List<Movie>> getUpcomingMovies({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/movie/upcoming?page=$page');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get upcoming movies error: $e');
      return [];
    }
  }

  // Get airing today TV shows
  Future<List<TVShow>> getAiringTodayTVShows({int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/tv/airing_today?page=$page');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => TVShow.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get airing today TV shows error: $e');
      return [];
    }
  }

  // Get movies by genre
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    try {
      final url = Uri.parse(
        '$baseUrl/discover/movie?with_genres=$genreId&sort_by=popularity.desc&page=$page',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get movies by genre error: $e');
      return [];
    }
  }

  // Get TV shows by genre
  Future<List<TVShow>> getTVShowsByGenre(int genreId, {int page = 1}) async {
    try {
      final url = Uri.parse(
        '$baseUrl/discover/tv?with_genres=$genreId&sort_by=popularity.desc&page=$page',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => TVShow.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get TV shows by genre error: $e');
      return [];
    }
  }

  // Get account ID
  Future<int?> getAccountId() async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return null;

      final accountDetails = await getAccountDetails(sessionId);
      return accountDetails?.id;
    } catch (e) {
      print('Get account ID error: $e');
      return null;
    }
  }

  // Add movie to favorites
  Future<bool> addMovieToFavorites(int movieId, bool favorite) async {
    try {
      final sessionId = await getSessionId();
      final accountId = await getAccountId();
      if (sessionId == null || accountId == null) return false;

      final url = Uri.parse(
        '$baseUrl/account/$accountId/favorite?session_id=$sessionId',
      );
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'media_type': 'movie',
          'media_id': movieId,
          'favorite': favorite,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Add movie to favorites error: $e');
      return false;
    }
  }

  // Add TV show to favorites
  Future<bool> addTVShowToFavorites(int tvId, bool favorite) async {
    try {
      final sessionId = await getSessionId();
      final accountId = await getAccountId();
      if (sessionId == null || accountId == null) return false;

      final url = Uri.parse(
        '$baseUrl/account/$accountId/favorite?session_id=$sessionId',
      );
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'media_type': 'tv',
          'media_id': tvId,
          'favorite': favorite,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Add TV show to favorites error: $e');
      return false;
    }
  }

  // Get favorite movies
  Future<List<Movie>> getFavoriteMovies({int page = 1}) async {
    try {
      final sessionId = await getSessionId();
      final accountId = await getAccountId();
      if (sessionId == null || accountId == null) return [];

      final url = Uri.parse(
        '$baseUrl/account/$accountId/favorite/movies?session_id=$sessionId&page=$page',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get favorite movies error: $e');
      return [];
    }
  }

  // Get favorite TV shows
  Future<List<TVShow>> getFavoriteTVShows({int page = 1}) async {
    try {
      final sessionId = await getSessionId();
      final accountId = await getAccountId();
      if (sessionId == null || accountId == null) return [];

      final url = Uri.parse(
        '$baseUrl/account/$accountId/favorite/tv?session_id=$sessionId&page=$page',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => TVShow.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get favorite TV shows error: $e');
      return [];
    }
  }

  // Check if movie is favorited
  Future<bool> isMovieFavorited(int movieId) async {
    try {
      final favorites = await getFavoriteMovies();
      return favorites.any((movie) => movie.id == movieId);
    } catch (e) {
      return false;
    }
  }

  // Check if TV show is favorited
  Future<bool> isTVShowFavorited(int tvId) async {
    try {
      final favorites = await getFavoriteTVShows();
      return favorites.any((show) => show.id == tvId);
    } catch (e) {
      return false;
    }
  }

  // Create a new list
  Future<MovieList?> createList(
    String name,
    String? description,
    String language,
  ) async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return null;

      final url = Uri.parse('$baseUrl/list?session_id=$sessionId');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'description': description ?? '',
          'language': language,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return MovieList(
          id: data['list_id'] ?? 0,
          name: name,
          description: description,
          itemCount: 0,
        );
      }
      return null;
    } catch (e) {
      print('Create list error: $e');
      return null;
    }
  }

  // Get user's lists
  Future<List<MovieList>> getLists({int page = 1}) async {
    try {
      final sessionId = await getSessionId();
      final accountId = await getAccountId();
      if (sessionId == null || accountId == null) return [];

      final url = Uri.parse(
        '$baseUrl/account/$accountId/lists?session_id=$sessionId&page=$page',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((json) => MovieList.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get lists error: $e');
      return [];
    }
  }

  // Get list details
  Future<Map<String, dynamic>?> getListDetails(int listId) async {
    try {
      final url = Uri.parse('$baseUrl/list/$listId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Get list details error: $e');
      return null;
    }
  }

  // Add item to list
  Future<bool> addItemToList(int listId, int mediaId, String mediaType) async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return false;

      final url = Uri.parse(
        '$baseUrl/list/$listId/add_item?session_id=$sessionId',
      );
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'media_id': mediaId}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Add item to list error: $e');
      return false;
    }
  }

  // Remove item from list
  Future<bool> removeItemFromList(int listId, int mediaId) async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return false;

      final url = Uri.parse(
        '$baseUrl/list/$listId/remove_item?session_id=$sessionId',
      );
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'media_id': mediaId}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Remove item from list error: $e');
      return false;
    }
  }

  // Update list
  Future<bool> updateList(
    int listId,
    String? name,
    String? description,
    String? language,
  ) async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return false;

      final url = Uri.parse('$baseUrl/list/$listId?session_id=$sessionId');
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (language != null) body['language'] = language;

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Update list error: $e');
      return false;
    }
  }

  // Delete list
  Future<bool> deleteList(int listId) async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return false;

      final url = Uri.parse('$baseUrl/list/$listId?session_id=$sessionId');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Delete list error: $e');
      return false;
    }
  }

  // Get movie details
  Future<Movie?> getMovieDetails(int movieId) async {
    try {
      final url = Uri.parse('$baseUrl/movie/$movieId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Movie.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Get movie details error: $e');
      return null;
    }
  }

  // Get TV show details
  Future<TVShow?> getTVShowDetails(int tvId) async {
    try {
      final url = Uri.parse('$baseUrl/tv/$tvId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TVShow.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Get TV show details error: $e');
      return null;
    }
  }
}

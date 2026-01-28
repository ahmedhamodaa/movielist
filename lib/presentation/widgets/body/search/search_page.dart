import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/data/models/models.dart';
import 'package:movielist/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:movielist/presentation/widgets/body/details/movie_detail_screen.dart';
import 'package:movielist/presentation/widgets/body/details/tv_detail_screen.dart';
import 'package:movielist/services/tmdb_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TmdbService _tmdbService = TmdbService();
  final TextEditingController _searchController = TextEditingController();

  // Track favorites
  Set<int> _favoritedMovieIds = {};
  Set<int> _favoritedTVShowIds = {};
  Set<int> _loadingFavoriteIds = {};

  List<Movie> _searchMovies = [];
  List<TVShow> _searchTVShows = [];
  bool _isSearching = false;
  String? _errorMessage;

  // Category data
  List<Movie> _categoryMovies = [];
  List<TVShow> _categoryTVShows = [];
  bool _isLoadingCategory = false;
  String? _selectedCategoryTitle;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final favoriteMovies = await _tmdbService.getFavoriteMovies();
      final favoriteTVShows = await _tmdbService.getFavoriteTVShows();

      if (mounted) {
        setState(() {
          _favoritedMovieIds = favoriteMovies.map((movie) => movie.id).toSet();
          _favoritedTVShowIds = favoriteTVShows
              .map((tvShow) => tvShow.id)
              .toSet();
        });
      }
    } catch (e) {
      debugPrint('Failed to load favorites: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchMovies = [];
        _searchTVShows = [];
        _selectedCategoryTitle = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _selectedCategoryTitle = null;
    });

    try {
      final results = await _tmdbService.search(query);

      if (mounted) {
        setState(() {
          _searchMovies = results['movies'] as List<Movie>;
          _searchTVShows = results['tv'] as List<TVShow>;
        });

        await _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Search failed. Please try again.';
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchMovies = [];
      _searchTVShows = [];
      _selectedCategoryTitle = null;
    });
  }

  Future<void> _loadCategory(
    String title,
    Future<List<dynamic>> Function() loader,
    bool isMovie,
  ) async {
    setState(() {
      _isLoadingCategory = true;
      _selectedCategoryTitle = title;
      _isSearching = false;
      _searchMovies = [];
      _searchTVShows = [];
      _errorMessage = null;
    });

    try {
      final results = await loader();

      if (mounted) {
        setState(() {
          if (isMovie) {
            _categoryMovies = results as List<Movie>;
            _categoryTVShows = [];
          } else {
            _categoryTVShows = results as List<TVShow>;
            _categoryMovies = [];
          }
          _isLoadingCategory = false;
        });

        await _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCategory = false;
          _errorMessage = 'Failed to load content. Please try again.';
        });
      }
    }
  }

  Future<void> _toggleFavoriteMovie(Movie movie) async {
    final movieId = movie.id;
    final isFavorited = _favoritedMovieIds.contains(movieId);

    setState(() => _loadingFavoriteIds.add(movieId));

    final success = await _tmdbService.addMovieToFavorites(
      movieId,
      !isFavorited,
    );

    if (mounted) {
      setState(() => _loadingFavoriteIds.remove(movieId));

      if (success) {
        setState(() {
          if (isFavorited) {
            _favoritedMovieIds.remove(movieId);
          } else {
            _favoritedMovieIds.add(movieId);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFavorited ? 'Removed from favorites' : 'Added to favorites',
              ),
              backgroundColor: isFavorited ? Colors.red : Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update favorites'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleFavoriteTVShow(TVShow tvShow) async {
    final tvShowId = tvShow.id;
    final isFavorited = _favoritedTVShowIds.contains(tvShowId);

    setState(() => _loadingFavoriteIds.add(tvShowId));

    final success = await _tmdbService.addTVShowToFavorites(
      tvShowId,
      !isFavorited,
    );

    if (mounted) {
      setState(() => _loadingFavoriteIds.remove(tvShowId));

      if (success) {
        setState(() {
          if (isFavorited) {
            _favoritedTVShowIds.remove(tvShowId);
          } else {
            _favoritedTVShowIds.add(tvShowId);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFavorited ? 'Removed from favorites' : 'Added to favorites',
              ),
              backgroundColor: isFavorited ? Colors.red : Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update favorites'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CustomAppBar(
          title: const Text('Search & Discover'),
          floating: true,
          height: 144,
          pinned: true,
          snap: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(88),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      _performSearch(value);
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search movies and TV shows...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: (_isSearching || _selectedCategoryTitle != null)
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
            ),
          ),
        ),
        // Error Message
        if (_errorMessage != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Content
        if (_isLoadingCategory)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_isSearching)
          _buildSearchResultsSlivers()
        else if (_selectedCategoryTitle != null)
          _buildCategoryResultsSlivers()
        else
          _buildCategoryGrid(),
      ],
    );
  }

  Widget _buildSearchResultsSlivers() {
    if (_searchMovies.isEmpty && _searchTVShows.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        if (_searchMovies.isNotEmpty)
          _buildSection('Movies', _searchMovies, true),
        if (_searchTVShows.isNotEmpty)
          _buildSection('TV Shows', _searchTVShows, false),
      ]),
    );
  }

  Widget _buildCategoryResultsSlivers() {
    if (_categoryMovies.isEmpty && _categoryTVShows.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No content found')),
      );
    }

    final items = _categoryMovies.isNotEmpty
        ? _categoryMovies
        : _categoryTVShows;
    final isMovie = _categoryMovies.isNotEmpty;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Text(
              _selectedCategoryTitle!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildGridItemCard(items[index], isMovie);
            }, childCount: items.length),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {
        'title': 'Top Rated Movies',
        'icon': Icons.star,
        'color': Colors.amber,
        'loader': () => _tmdbService.getTopRatedMovies(),
        'isMovie': true,
      },
      {
        'title': 'Popular Movies',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'loader': () => _tmdbService.getPopularMovies(),
        'isMovie': true,
      },
      {
        'title': 'Top Rated TV Shows',
        'icon': Icons.tv,
        'color': Colors.purple,
        'loader': () => _tmdbService.getTopRatedTVShows(),
        'isMovie': false,
      },
      {
        'title': 'Popular TV Shows',
        'icon': Icons.trending_up,
        'color': Colors.blue,
        'loader': () => _tmdbService.getPopularTVShows(),
        'isMovie': false,
      },
      {
        'title': 'Upcoming Movies',
        'icon': Icons.upcoming,
        'color': Colors.green,
        'loader': () => _tmdbService.getUpcomingMovies(),
        'isMovie': true,
      },
      {
        'title': 'Airing Today',
        'icon': Icons.live_tv,
        'color': Colors.red,
        'loader': () => _tmdbService.getAiringTodayTVShows(),
        'isMovie': false,
      },
      {
        'title': 'Action Movies',
        'icon': Icons.sports_martial_arts,
        'color': Colors.deepOrange,
        'loader': () => _tmdbService.getMoviesByGenre(28),
        'isMovie': true,
      },
      {
        'title': 'Comedy Movies',
        'icon': Icons.sentiment_very_satisfied,
        'color': Colors.yellow[700]!,
        'loader': () => _tmdbService.getMoviesByGenre(35),
        'isMovie': true,
      },
      {
        'title': 'Horror Movies',
        'icon': Icons.nightlight,
        'color': Colors.grey[800]!,
        'loader': () => _tmdbService.getMoviesByGenre(27),
        'isMovie': true,
      },
      {
        'title': 'Drama TV Shows',
        'icon': Icons.theater_comedy,
        'color': Colors.indigo,
        'loader': () => _tmdbService.getTVShowsByGenre(18),
        'isMovie': false,
      },
      {
        'title': 'Sci-Fi Movies',
        'icon': Icons.rocket_launch,
        'color': Colors.cyan,
        'loader': () => _tmdbService.getMoviesByGenre(878),
        'isMovie': true,
      },
      {
        'title': 'Animation',
        'icon': Icons.animation,
        'color': Colors.pink,
        'loader': () => _tmdbService.getMoviesByGenre(16),
        'isMovie': true,
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              _loadCategory(
                category['title'] as String,
                category['loader'] as Future<List<dynamic>> Function(),
                category['isMovie'] as bool,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (category['color'] as Color).withOpacity(0.8),
                    (category['color'] as Color).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (category['color'] as Color).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: categories.length),
      ),
    );
  }

  Widget _buildSection(String title, List items, bool isMovie) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildItemCard(items[index], isMovie);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildItemCard(dynamic item, bool isMovie) {
    final posterUrl = isMovie
        ? (item as Movie).getPosterUrl()
        : (item as TVShow).getPosterUrl();
    final title = isMovie ? (item as Movie).title : (item as TVShow).name;
    final voteAverage = isMovie
        ? (item as Movie).voteAverage
        : (item as TVShow).voteAverage;
    final itemId = isMovie ? (item as Movie).id : (item as TVShow).id;

    final isFavorited = isMovie
        ? _favoritedMovieIds.contains(itemId)
        : _favoritedTVShowIds.contains(itemId);
    final isLoadingFavorite = _loadingFavoriteIds.contains(itemId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isMovie
                ? MovieDetailScreen(movie: item as Movie)
                : TVDetailScreen(tvShow: item as TVShow),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: 160,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: posterUrl.isNotEmpty
                        ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.lightGrey,
                                child: Icon(
                                  Icons.movie,
                                  size: 60,
                                  color: AppColors.darkGery,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 200,
                            color: AppColors.lightGrey,
                            child: Icon(
                              Icons.movie,
                              size: 60,
                              color: AppColors.darkGery,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (voteAverage != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        voteAverage.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 10,
            top: 2,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.darkGery.withValues(alpha: 0.65),
                foregroundColor: AppColors.white,
              ),
              onPressed: isLoadingFavorite
                  ? null
                  : () async {
                      if (isMovie) {
                        await _toggleFavoriteMovie(item as Movie);
                      } else {
                        await _toggleFavoriteTVShow(item as TVShow);
                      }
                    },
              icon: isLoadingFavorite
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isFavorited ? Icons.favorite : Icons.favorite_border),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItemCard(dynamic item, bool isMovie) {
    final posterUrl = isMovie
        ? (item as Movie).getPosterUrl()
        : (item as TVShow).getPosterUrl();
    final title = isMovie ? (item as Movie).title : (item as TVShow).name;
    final voteAverage = isMovie
        ? (item as Movie).voteAverage
        : (item as TVShow).voteAverage;
    final itemId = isMovie ? (item as Movie).id : (item as TVShow).id;

    final isFavorited = isMovie
        ? _favoritedMovieIds.contains(itemId)
        : _favoritedTVShowIds.contains(itemId);
    final isLoadingFavorite = _loadingFavoriteIds.contains(itemId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isMovie
                ? MovieDetailScreen(movie: item as Movie)
                : TVDetailScreen(tvShow: item as TVShow),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: posterUrl.isNotEmpty
                        ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.lightGrey,
                                child: Icon(
                                  Icons.movie,
                                  size: 60,
                                  color: AppColors.darkGery,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.lightGrey,
                            child: Icon(
                              Icons.movie,
                              size: 60,
                              color: AppColors.darkGery,
                            ),
                          ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.darkGery.withValues(
                          alpha: 0.65,
                        ),
                      ),
                      iconSize: 20,
                      padding: EdgeInsets.zero,

                      onPressed: isLoadingFavorite
                          ? null
                          : () async {
                              if (isMovie) {
                                await _toggleFavoriteMovie(item as Movie);
                              } else {
                                await _toggleFavoriteTVShow(item as TVShow);
                              }
                            },
                      icon: isLoadingFavorite
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  if (voteAverage != null)
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

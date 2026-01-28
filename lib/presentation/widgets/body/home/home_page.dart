import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/data/models/models.dart';
import 'package:movielist/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:movielist/presentation/widgets/body/details/movie_detail_screen.dart';
import 'package:movielist/presentation/widgets/body/details/tv_detail_screen.dart';
import 'package:movielist/services/tmdb_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TmdbService _tmdbService = TmdbService();

  // Track favorites for movies and TV shows separately
  Set<int> _favoritedMovieIds = {};
  Set<int> _favoritedTVShowIds = {};
  Set<int> _loadingFavoriteIds = {};

  List<Movie> _popularMovies = [];
  List<TVShow> _popularTVShows = [];
  List<TVShow> _topTVShows = [];
  List<Movie> _topMovies = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPopularContent();
  }

  Future<void> _loadPopularContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final popularMovies = await _tmdbService.getPopularMovies();
      final popularTvShows = await _tmdbService.getPopularTVShows();
      final topTvShows = await _tmdbService.getTopRatedTVShows();
      final topMovies = await _tmdbService.getTopRatedMovies();

      if (mounted) {
        setState(() {
          _popularMovies = popularMovies;
          _popularTVShows = popularTvShows;
          _topTVShows = topTvShows;
          _topMovies = topMovies;
          _isLoading = false;
        });

        // Load favorites after content is loaded
        await _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load content. Please try again.';
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    try {
      // Fetch all favorite movies and TV shows at once
      final favoriteMovies = await _tmdbService.getFavoriteMovies();
      final favoriteTVShows = await _tmdbService.getFavoriteTVShows();

      if (mounted) {
        setState(() {
          // Extract IDs from the favorite lists
          _favoritedMovieIds = favoriteMovies.map((movie) => movie.id).toSet();
          _favoritedTVShowIds = favoriteTVShows
              .map((tvShow) => tvShow.id)
              .toSet();
        });
      }
    } catch (e) {
      // Silently fail - favorites will just not be highlighted
      debugPrint('Failed to load favorites: $e');
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
    super.build(context);
    return CustomScrollView(
      slivers: [
        CustomAppBar(
          floating: true,
          title: SvgPicture.asset('assets/icon/movielist.svg', height: 18),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_rounded),
              color: AppColors.white,
              iconSize: 26,
            ),
          ],
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
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _buildPopularContentSlivers(),
      ],
    );
  }

  Widget _buildPopularContentSlivers() {
    return SliverList(
      delegate: SliverChildListDelegate([
        _buildSection('Popular Movies', _popularMovies, true),
        _buildSection('Popular TV Shows', _popularTVShows, false),
        _buildSection('Top Rated Movies', _topMovies, true),
        _buildSection('Top Rated TV Shows', _topTVShows, false),
      ]),
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
                iconSize: 20,
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
}

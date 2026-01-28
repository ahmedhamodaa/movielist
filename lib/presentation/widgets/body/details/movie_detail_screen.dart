// ==================== movie_detail_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/data/models/models.dart';
import 'package:movielist/presentation/widgets/body/lists_screen.dart';
import 'package:movielist/services/tmdb_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TmdbService _tmdbService = TmdbService();
  Movie? _movieDetails;
  bool _isLoading = true;
  bool _isFavorited = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
    _checkFavoriteStatus();
  }

  Future<void> _loadMovieDetails() async {
    setState(() => _isLoading = true);
    final details = await _tmdbService.getMovieDetails(widget.movie.id);
    setState(() {
      _movieDetails = details ?? widget.movie;
      _isLoading = false;
    });
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorited = await _tmdbService.isMovieFavorited(widget.movie.id);
    setState(() => _isFavorited = isFavorited);
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isLoadingFavorite = true);
    final success = await _tmdbService.addMovieToFavorites(
      widget.movie.id,
      !_isFavorited,
    );
    if (success) {
      setState(() {
        _isFavorited = !_isFavorited;
        _isLoadingFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorited ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: _isFavorited ? Colors.green : Colors.red,
        ),
      );
    } else {
      setState(() => _isLoadingFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addToList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListsScreen(movieId: widget.movie.id, mediaType: 'movie'),
      ),
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to list'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movieDetails ?? widget.movie;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: movie.backdropPath != null
                        ? Image.network(
                            movie.getBackdropUrl(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: Colors.grey[800]);
                            },
                          )
                        : Container(color: Colors.grey[800]),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: movie.posterPath != null
                                  ? Image.network(
                                      movie.getPosterUrl(),
                                      width: 120,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 120,
                                              height: 180,
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.movie,
                                                size: 60,
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      width: 120,
                                      height: 180,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.movie, size: 60),
                                    ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (movie.releaseDate != null) ...[
                                    SizedBox(height: 8),
                                    Text(
                                      movie.releaseDate!.split('-')[0],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.lightGrey,
                                      ),
                                    ),
                                  ],
                                  if (movie.voteAverage != null) ...[
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${movie.voteAverage!.toStringAsFixed(1)}/10',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoadingFavorite
                                    ? null
                                    : _toggleFavorite,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFavorited
                                      ? AppColors.primaryColor.withValues(
                                          alpha: 0.1,
                                        )
                                      : AppColors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isFavorited
                                    ? Icon(
                                        Icons.favorite,
                                        size: 32,
                                        color: AppColors.primaryColor,
                                      )
                                    : Icon(Icons.favorite_border, size: 32),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addToList,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 32,
                                  color: AppColors.darkColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (movie.overview != null &&
                            movie.overview!.isNotEmpty) ...[
                          SizedBox(height: 24),
                          Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            movie.overview!,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppColors.lightGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ==================== tv_detail_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/data/models/models.dart';
import 'package:movielist/presentation/widgets/body/lists_screen.dart';
import 'package:movielist/services/tmdb_service.dart';

class TVDetailScreen extends StatefulWidget {
  final TVShow tvShow;

  TVDetailScreen({required this.tvShow});

  @override
  _TVDetailScreenState createState() => _TVDetailScreenState();
}

class _TVDetailScreenState extends State<TVDetailScreen> {
  final TmdbService _tmdbService = TmdbService();
  TVShow? _tvShowDetails;
  bool _isLoading = true;
  bool _isFavorited = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadTVShowDetails();
    _checkFavoriteStatus();
  }

  Future<void> _loadTVShowDetails() async {
    setState(() => _isLoading = true);
    final details = await _tmdbService.getTVShowDetails(widget.tvShow.id);
    setState(() {
      _tvShowDetails = details ?? widget.tvShow;
      _isLoading = false;
    });
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorited = await _tmdbService.isTVShowFavorited(widget.tvShow.id);
    setState(() => _isFavorited = isFavorited);
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isLoadingFavorite = true);
    final success = await _tmdbService.addTVShowToFavorites(
      widget.tvShow.id,
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
            ListsScreen(movieId: widget.tvShow.id, mediaType: 'tv'),
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
    final tvShow = _tvShowDetails ?? widget.tvShow;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: tvShow.backdropPath != null
                        ? Image.network(
                            tvShow.getBackdropUrl(),
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
                              child: tvShow.posterPath != null
                                  ? Image.network(
                                      tvShow.getPosterUrl(),
                                      width: 120,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 120,
                                              height: 180,
                                              color: Colors.grey[300],
                                              child: Icon(Icons.tv, size: 60),
                                            );
                                          },
                                    )
                                  : Container(
                                      width: 120,
                                      height: 180,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.tv, size: 60),
                                    ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tvShow.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (tvShow.firstAirDate != null) ...[
                                    SizedBox(height: 8),
                                    Text(
                                      tvShow.firstAirDate!.split('-')[0],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.lightGrey,
                                      ),
                                    ),
                                  ],
                                  if (tvShow.voteAverage != null) ...[
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
                                          '${tvShow.voteAverage!.toStringAsFixed(1)}/10',
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
                                      : Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isFavorited
                                    ? Icon(
                                        size: 32,
                                        Icons.favorite,
                                        color: AppColors.primaryColor,
                                      )
                                    : Icon(
                                        Icons.favorite_border,
                                        size: 32,
                                        // color: AppColors.primaryColor,
                                      ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _addToList,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Icon(
                                  size: 32,
                                  Icons.add,
                                  color: AppColors.darkColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (tvShow.overview != null &&
                            tvShow.overview!.isNotEmpty) ...[
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
                            tvShow.overview!,
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

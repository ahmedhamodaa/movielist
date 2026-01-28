// ==================== favorites_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/data/models/models.dart';
import 'package:movielist/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:movielist/presentation/widgets/body/details/movie_detail_screen.dart';
import 'package:movielist/presentation/widgets/body/details/tv_detail_screen.dart';
import 'package:movielist/services/tmdb_service.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  final TmdbService _tmdbService = TmdbService();
  List<Movie> _favoriteMovies = [];
  List<TVShow> _favoriteTVShows = [];
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final movies = await _tmdbService.getFavoriteMovies();
    final tvShows = await _tmdbService.getFavoriteTVShows();
    setState(() {
      _favoriteMovies = movies;
      _favoriteTVShows = tvShows;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CustomAppBar(
              floating: true,
              snap: true,
              pinned: true,
              height: 120,

              title: Text('My Favorites'),
              bottom: TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 4,
                    color: AppColors.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  insets: EdgeInsets.symmetric(horizontal: 24),
                ),
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(24),
                controller: _tabController,
                tabs: [
                  Tab(text: 'Movies (${_favoriteMovies.length})'),
                  Tab(text: 'TV Shows (${_favoriteTVShows.length})'),
                ],
              ),
            ),
          ];
        },
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [_buildMoviesList(), _buildTVShowsList()],
              ),
      ),
    );
  }

  Widget _buildMoviesList() {
    if (_favoriteMovies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No favorite movies yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _favoriteMovies.length,
        itemBuilder: (context, index) {
          final movie = _favoriteMovies[index];
          return _buildMovieCard(movie);
        },
      ),
    );
  }

  Widget _buildTVShowsList() {
    if (_favoriteTVShows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No favorite TV shows yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _favoriteTVShows.length,
        itemBuilder: (context, index) {
          final tvShow = _favoriteTVShows[index];
          return _buildTVShowCard(tvShow);
        },
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        ).then((_) => _loadFavorites());
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: movie.posterPath != null
                    ? Image.network(
                        movie.getPosterUrl(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.movie,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 200,
                        color: Colors.grey[300],
                        child: Icon(Icons.movie, size: 60, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.voteAverage != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          movie.voteAverage!.toStringAsFixed(1),
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTVShowCard(TVShow tvShow) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TVDetailScreen(tvShow: tvShow),
          ),
        ).then((_) => _loadFavorites());
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: tvShow.posterPath != null
                    ? Image.network(
                        tvShow.getPosterUrl(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.tv, size: 60, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        width: 200,
                        color: Colors.grey[300],
                        child: Icon(Icons.tv, size: 60, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tvShow.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tvShow.voteAverage != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          tvShow.voteAverage!.toStringAsFixed(1),
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

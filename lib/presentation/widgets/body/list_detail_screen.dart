// ==================== list_detail_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:movielist/data/models/models.dart';
import 'package:movielist/presentation/widgets/body/create_list_screen.dart';
import 'package:movielist/presentation/widgets/body/details/movie_detail_screen.dart';
import 'package:movielist/presentation/widgets/body/details/tv_detail_screen.dart';
import 'package:movielist/services/tmdb_service.dart';

class ListDetailScreen extends StatefulWidget {
  final MovieList list;

  ListDetailScreen({required this.list});

  @override
  _ListDetailScreenState createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final TmdbService _tmdbService = TmdbService();
  List<MediaItem> _items = [];
  bool _isLoading = false;
  MovieList? _listDetails;

  @override
  void initState() {
    super.initState();
    _loadListDetails();
  }

  Future<void> _loadListDetails() async {
    setState(() => _isLoading = true);
    final details = await _tmdbService.getListDetails(widget.list.id);
    if (details != null) {
      setState(() {
        _listDetails = MovieList.fromJson(details);
        final results = details['items'] as List?;
        _items =
            results?.map((json) => MediaItem.fromJson(json)).toList() ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeItem(MediaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Item'),
        content: Text('Remove "${item.title}" from this list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _tmdbService.removeItemFromList(
        widget.list.id,
        item.id,
      );
      if (success) {
        _loadListDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Item removed'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove item'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateListScreen(existingList: _listDetails ?? widget.list),
      ),
    );
    if (result == true) {
      _loadListDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _listDetails ?? widget.list;

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editList,
            tooltip: 'Edit list',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'This list is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (list.description != null && list.description!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Text(
                      list.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadListDetails,
                    child: GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _buildItemCard(item);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildItemCard(MediaItem item) {
    return GestureDetector(
      onTap: () {
        if (item.mediaType == 'movie') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(
                movie: Movie(
                  id: item.id,
                  title: item.title,
                  overview: item.overview,
                  posterPath: item.posterPath,
                  backdropPath: item.backdropPath,
                  voteAverage: item.voteAverage,
                  releaseDate: item.releaseDate,
                ),
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TVDetailScreen(
                tvShow: TVShow(
                  id: item.id,
                  name: item.title,
                  overview: item.overview,
                  posterPath: item.posterPath,
                  backdropPath: item.backdropPath,
                  voteAverage: item.voteAverage,
                  firstAirDate: item.releaseDate,
                ),
              ),
            ),
          );
        }
      },
      onLongPress: () => _removeItem(item),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: item.posterPath != null
                        ? Image.network(
                            item.getPosterUrl(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  item.mediaType == 'movie'
                                      ? Icons.movie
                                      : Icons.tv,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              item.mediaType == 'movie'
                                  ? Icons.movie
                                  : Icons.tv,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.mediaType == 'movie' ? 'Movie' : 'TV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.voteAverage != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          item.voteAverage!.toStringAsFixed(1),
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

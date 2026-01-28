// ==================== lists_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/data/models/models.dart';
import 'package:movielist/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:movielist/presentation/widgets/body/create_list_screen.dart';
import 'package:movielist/presentation/widgets/body/favorites/custom_floating_button.dart';
import 'package:movielist/presentation/widgets/body/favorites/favorites_screen.dart';
import 'package:movielist/presentation/widgets/body/favorites/list_item.dart';
import 'package:movielist/presentation/widgets/body/list_detail_screen.dart';
import 'package:movielist/services/tmdb_service.dart';

class ListsScreen extends StatefulWidget {
  final int? movieId;
  final String? mediaType; // 'movie' or 'tv'

  ListsScreen({this.movieId, this.mediaType});

  @override
  _ListsScreenState createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TmdbService _tmdbService = TmdbService();
  List<MovieList> _lists = [];
  bool _isLoading = false;
  bool _isOperating = false; // Track delete/add operations

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() => _isLoading = true);
    try {
      final lists = await _tmdbService.getLists();
      if (mounted) {
        setState(() {
          _lists = lists;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load lists: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToSelectedList(MovieList list) async {
    if (widget.movieId == null || widget.mediaType == null) return;

    setState(() => _isOperating = true);
    try {
      final success = await _tmdbService.addItemToList(
        list.id,
        widget.movieId!,
        widget.mediaType!,
      );

      if (mounted) {
        setState(() => _isOperating = false);
        if (success) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add to list'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isOperating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createNewList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateListScreen()),
    );
    if (result == true && mounted) {
      _loadLists();
    }
  }

  Future<void> _deleteList(MovieList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete List'),
        content: Text('Are you sure you want to delete "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isOperating = true);
      try {
        final success = await _tmdbService.deleteList(list.id);
        if (mounted) {
          setState(() => _isOperating = false);
          if (success) {
            _loadLists();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('List deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete list'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isOperating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting list: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isSelectionMode = widget.movieId != null && widget.mediaType != null;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: CustomFloatingButton(onPressed: _createNewList),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CustomAppBar(
                title: Text(isSelectionMode ? 'Select a List' : 'My Lists'),
                height: 78,
              ),
              CupertinoSliverRefreshControl(onRefresh: _loadLists),
              if (_isLoading)
                SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_lists.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list,
                          size: 80,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No lists yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first list to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // First item is the Favorites card
                        if (index == 0) {
                          return _buildFavoritesCard(isSelectionMode);
                        }
                        // Subsequent items are user lists
                        final list = _lists[index - 1];
                        return _buildListCard(list, isSelectionMode);
                      },
                      childCount: _lists.length + 1, // +1 for Favorites card
                    ),
                  ),
                ),
            ],
          ),
          // Loading overlay for operations
          if (_isOperating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritesCard(bool isSelectionMode) {
    return ListItem(
      onTap: _isOperating
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
      title: Text('Favorites'),
      subTitle: Text('Your favorite movies and TV shows'),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.favorite, color: Colors.white),
      ),
      // trailing: Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildListCard(MovieList list, bool isSelectionMode) {
    return ListItem(
      onPressed: !isSelectionMode && !_isOperating
          ? () => _deleteList(list)
          : null,
      onTap: _isOperating
          ? null
          : isSelectionMode
          ? () => _addToSelectedList(list)
          : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListDetailScreen(list: list),
                ),
              );
              if (mounted) {
                _loadLists();
              }
            },
      title: Text(list.name),
      subTitle: Text('${list.itemCount} items'),
      leading: list.posterPath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                list.getPosterUrl(),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[300],
                    child: Icon(Icons.list, color: AppColors.darkGery),
                  );
                },
              ),
            )
          : Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.list, color: AppColors.primaryColor),
            ),
      // trailing: !isSelectionMode && !_isOperating
      //     ? IconButton(
      //         icon: Icon(Icons.delete_outline, color: Colors.red),
      //         onPressed: () => _deleteList(list),
      //       )
      //     : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/core/utils/app_styles.dart';
import 'package:movielist/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:movielist/presentation/widgets/body/favorites/custom_floating_button.dart';
import 'package:movielist/presentation/widgets/body/favorites/list_item.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: CustomFloatingButton(),
      body: CustomScrollView(
        slivers: [
          CustomAppBar(title: Text('Favorites'), height: 78),
          SliverPadding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListItem(),
                childCount: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

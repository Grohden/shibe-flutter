import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shibe_flutter/ui.dart';
import 'package:shibe_flutter/api/graphql_api.dart';

class AnimalPicturesGrid extends StatelessWidget {
  const AnimalPicturesGrid({
    Key? key,
    required this.onTap,
    required this.loading,
    required this.pictures,
    required this.controller
  }) : super(key: key);

  final Function(SimplePictureMixin) onTap;
  final bool loading;
  final ScrollController controller;
  final List<SimplePictureMixin> pictures;

  SliverChildBuilderDelegate _buildGridDelegate() {
    return SliverChildBuilderDelegate((context, index) {
      final item = pictures[index];

      return SimpleCard(
        onTap: () => onTap(item),
        child: CachedNetworkImage(
          imageUrl: item.url,
          imageBuilder: (context, imageProvider) {
            return Hero(
              tag: item.id,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          // if you see this image you probably need to run flutter with
          // --web-renderer html
          // https://github.com/flutter/flutter/issues/73109#issuecomment-814143539
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/not_found.png',
            fit: BoxFit.cover,
          ),
          fit: BoxFit.cover,
        ),
      );
    }, childCount: pictures.length);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          delegate: _buildGridDelegate(),
        ),
        // Bottom loader
        if (loading)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  padding: const EdgeInsets.only(
                    top: 42.0,
                    bottom: 24.0,
                  ),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              },
              childCount: 1,
            ),
          )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shibe_flutter/api/graphql_api.dart';
import 'package:shibe_flutter/client.dart';
import 'package:shibe_flutter/scenes/screens/animal_picture_details.dart';
import 'package:shibe_flutter/ui/mixins/paginated_loadable.dart';
import 'package:shibe_flutter/ui/widgets/organisms/animal_pictures_grid.dart';

class TagPicturesScreen extends StatefulWidget {
  const TagPicturesScreen({
    Key? key,
    required this.userId,
    required this.tagId,
    required this.tagName,
  }) : super(key: key);

  static void navigateWithSimpleTag({
    required BuildContext context,
    required String userId,
    required SimpleTagMixin tag,
  }) {
    TagPicturesScreen.navigate(
      context: context,
      userId: userId,
      tagId: tag.id,
      tagName: tag.name,
    );
  }

  static void navigate({
    required BuildContext context,
    required String userId,
    required String tagId,
    required String tagName,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagPicturesScreen(
          userId: userId,
          tagId: tagId,
          tagName: tagName,
        ),
      ),
    );
  }

  final String userId;
  final String tagId;
  final String tagName;

  @override
  State<TagPicturesScreen> createState() => _TagPicturesScreenState();
}

class _TagPicturesScreenState extends State<TagPicturesScreen>
    with PaginatedLoadable<SimplePictureMixin, TagPicturesScreen> {
  EndPageInfoMixin? _endPage;

  void _openPicturePage(SimplePictureMixin picture) {
    AnimalPicturesDetailsScreen.navigateWithSimplePicture(
      context: context,
      userId: widget.userId,
      picture: picture,
    );
  }

  @override
  Future<Iterable<SimplePictureMixin>?> fetchNextPage() async {
    final photosQuery = AnimalPicturesByUserTagQuery(
      variables: AnimalPicturesByUserTagArguments(
        userId: widget.userId,
        tagId: widget.tagId,
        first: 10,
        after: _endPage?.endCursor,
      ),
    );

    final response = await client.execute(photosQuery);
    final data = response.data?.animalPicturesByUserTag;
    final pageInfo = data?.pageInfo;

    if (pageInfo?.endCursor != null) {
      _endPage = pageInfo;
    }

    return data?.nodes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tagName),
      ),
      body: AnimalPicturesGrid(
        onTap: _openPicturePage,
        loading: loading,
        pictures: list,
        controller: bottomScrollController,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shibe_flutter/api/graphql_api.graphql.dart';
import 'package:shibe_flutter/client.dart';
import 'package:shibe_flutter/scenes/screens/tag_pictures.dart';

class TagListing extends StatefulWidget {
  const TagListing({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  State<TagListing> createState() => _TagListingState();
}

class _TagListingState extends State<TagListing> {
  bool _loading = true;
  final List<SimpleTagMixin> _tags = [];

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  void _fetchTags() async {
    setState(() {
      _loading = true;
    });

    final photosQuery = TagsByUserQuery(
      variables: TagsByUserArguments(userId: widget.userId),
    );

    final response = await client.execute(photosQuery);

    setState(() {
      final data = response.data?.tagsByUser;

      if (data != null) {
        // we could avoid mutability here
        // but I see no good reason for that now
        _tags.addAll(data);
      }

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Center(
        child: Wrap(
          spacing: 14,
          runSpacing: 8,
          children: _tags.map((tag) {
            return InkWell(
              onTap: () {
                TagPicturesScreen.navigateWithSimpleTag(
                  context: context,
                  userId: widget.userId,
                  tag: tag,
                );
              },
              child: Chip(
                visualDensity: VisualDensity.comfortable,
                label: Text(tag.name),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

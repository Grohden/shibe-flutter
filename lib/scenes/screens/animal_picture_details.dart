import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shibe_flutter/api/graphql_api.dart';
import 'package:shibe_flutter/client.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shibe_flutter/enum_utils.dart';

class AnimalPicturesDetailsScreen extends StatefulWidget {
  const AnimalPicturesDetailsScreen({
    Key? key,
    required this.pictureId,
    required this.userId,
    required this.pictureURL,
  }) : super(key: key);

  static void navigateWithSimplePicture({
    required BuildContext context,
    required String userId,
    required SimplePictureMixin picture,
  }) {
    AnimalPicturesDetailsScreen.navigate(
      context: context,
      userId: userId,
      pictureId: picture.id,
      pictureURL: picture.url,
    );
  }

  static void navigate({
    required BuildContext context,
    required String pictureId,
    required String userId,
    required String pictureURL, // for hero
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalPicturesDetailsScreen(
          pictureId: pictureId,
          userId: userId,
          pictureURL: pictureURL,
        ),
      ),
    );
  }

  final String pictureId;
  final String pictureURL;
  final String userId;

  @override
  AnimalPicturesDetailsScreenState createState() =>
      AnimalPicturesDetailsScreenState();
}

class AnimalPicturesDetailsScreenState
    extends State<AnimalPicturesDetailsScreen> {
  var _loading = false;
  late TextEditingController _controller;

  Animal? _animalType;

  // Here we only care about the name
  final Map<String, String?> _tags = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_handleAddTag);
    _loadDetails();
  }

  void _handleAddTag() {
    final text = _controller.text;
    if (text.endsWith(" ") && text.trim().isNotEmpty) {
      final created = text.trim().toLowerCase();

      setState(() {
        _tags[created] = null;
        _controller.clear();
      });

      final mutation = RegisterUserTagMutation(
        variables: RegisterUserTagArguments(
          tagInput: RegisterTagInput(
            userId: widget.userId,
            pictureId: widget.pictureId,
            name: created,
          ),
        ),
      );

      client.execute(mutation).then((response) {
        final tag = response.data?.registerUserTag?.tag;
        if(tag == null) {
          return;
        }

        _tags[tag.name] = tag.id;
      }).catchError((err) {
        print(err);
      });
    }
  }

  void _handleDeleteTag(MapEntry<String, String?> tag) {
    setState(() {
      _tags.remove(tag.key);
    });

    final id = tag.value;
    if (id == null) {
      return;
    }

    final mutation = DeleteUserPictureTagMutation(
      variables: DeleteUserPictureTagArguments(
        pictureId: widget.pictureId,
        tagId: id,
      ),
    );

    client.execute(mutation).catchError((err) {
      print(err);
    });
  }

  void _loadDetails() async {
    setState(() {
      _loading = true;
    });

    final query = UserAnimalPictureDetailsQuery(
      variables: UserAnimalPictureDetailsArguments(
        pictureId: widget.pictureId,
        userId: "1",
      ),
    );

    final response = await client.execute(query);

    setState(() {
      _loading = false;
      final data = response.data;
      if (data != null) {
        _animalType = data.animalPicturesById.animalType;
        for (var tag in data.userTagsByAnimalPicture) {
          _tags[tag.name] = tag.id;
        }
      }
    });
  }

  Widget _buildPhotoView(String url, String tag) {
    return PhotoView(
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, event) {
        final progress = event?.expectedTotalBytes == null
            ? null
            : (event!.cumulativeBytesLoaded / event.expectedTotalBytes!);

        return Center(
          child: CircularProgressIndicator(value: progress),
        );
      },
      maxScale: PhotoViewComputedScale.contained * 2.5,
      minScale: PhotoViewComputedScale.contained,
      heroAttributes: PhotoViewHeroAttributes(tag: tag),
      imageProvider: CachedNetworkImageProvider(url),
    );
  }

  Widget _buildDetails() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final theme = Theme.of(context).textTheme;
    final textStyle = theme.bodyText1!.copyWith(
      color: Colors.black,
    );

    // if (_tags.isEmpty) {
    //   return Center(
    //     child: Text(
    //       "Wow, such no tags, much empty!",
    //       style: theme.displayMedium,
    //       textAlign: TextAlign.center,
    //     ),
    //   );
    // }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 3,
          child: Center(
            child: Text(
              'Oh, wow! A nice ${animalHumanReadable(_animalType, defaultValue: "picture")}!',
              style: theme.headline4,
            ),
          ),
        ),
        Flexible(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Tags ',
                    style: textStyle,
                    children: [
                      TextSpan(
                        text: '(separate with spaces)',
                        style:
                            TextStyle(color: textStyle.color!.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: _tags.entries.map((tag) {
                    return Chip(
                      label: Text(tag.key),
                      deleteIcon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onDeleted: () => _handleDeleteTag(tag),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 2,
                child: _buildPhotoView(widget.pictureURL, widget.pictureId),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  color: Colors.grey[100],
                  width: double.infinity,
                  child: _buildDetails(),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            // color: endPartColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BackButton(
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

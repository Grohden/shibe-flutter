import 'package:flutter/material.dart';
import 'package:shibe_flutter/enum_utils.dart';
import 'package:shibe_flutter/scenes/screens/animal_picture_details.dart';
import 'package:shibe_flutter/api/graphql_api.dart';
import 'package:shibe_flutter/client.dart';
import 'package:shibe_flutter/ui/mixins/paginated_loadable.dart';
import 'package:shibe_flutter/ui/widgets/organisms/animal_pictures_grid.dart';

class AnimalListing extends StatefulWidget {
  const AnimalListing({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  State<AnimalListing> createState() => _AnimalListingState();
}

class _AnimalListingState extends State<AnimalListing>
    with PaginatedLoadable<SimplePictureMixin, AnimalListing> {
  Animal _animalType = Animal.shibes;

  void _changeAnimalType(Animal? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _animalType = value;
      list = [];
    });
    fetchMore();
  }

  @override
  Future<List<SimplePictureMixin>?> fetchNextPage() async {
    final mutation = RegisterNewPicturesMutation(
      variables: RegisterNewPicturesArguments(
        count: 25,
        animalType: _animalType,
      ),
    );

    final response = await client.execute(mutation);

    return response.data?.registerAnimalPictures?.animalPictures;
  }

  void _openPicturePage(SimplePictureMixin picture) {
    AnimalPicturesDetailsScreen.navigateWithSimplePicture(
      context: context,
      userId: widget.userId,
      picture: picture,
    );
  }

  Future<void> _askOption() async {
    final selected = await showDialog<Animal>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select an animal type'),
          children: knownAnimals().map<Widget>((value) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, value),
              child: Text(value.name),
            );
          }).toList(),
        );
      },
    );


    switch (selected) {
      case null:
        break;
      default:
        _changeAnimalType(selected);
        break;
    }
  }

  IconData _currentIcon() {
    switch (_animalType) {
      case Animal.birds:
        return Icons.flutter_dash;
      case Animal.cats:
        return Icons.cruelty_free;
      case Animal.shibes:
      case Animal.artemisUnknown:
        return Icons.pets;
    }
  }

  Widget _buildIcon() {
    return IconButton(
      icon: Icon(_currentIcon()),
      onPressed: _askOption,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listing ${animalHumanReadable(_animalType)}s'),
        centerTitle: true,
        actions: [_buildIcon()],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: AnimalPicturesGrid(
              onTap: _openPicturePage,
              loading: loading,
              pictures: list,
              controller: bottomScrollController,
            ),
          ),
        ],
      ),
    );
  }
}

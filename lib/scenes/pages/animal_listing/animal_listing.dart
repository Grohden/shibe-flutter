import 'package:flutter/material.dart';
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

  Widget _buildDropdown() {
    return DropdownButton<Animal>(
      value: _animalType,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: _changeAnimalType,
      items: Animal.values.map<DropdownMenuItem<Animal>>((value) {
        return DropdownMenuItem<Animal>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildDropdown(),
        Expanded(
          child: AnimalPicturesGrid(
            onTap: _openPicturePage,
            loading: loading,
            pictures: list,
            controller: bottomScrollController,
          ),
        ),
      ],
    );
  }
}

import 'package:shibe_flutter/api/graphql_api.dart' show Animal;

String animalHumanReadable(Animal? type, { String defaultValue = 'Unknown' }) {
  switch (type) {
    case Animal.birds:
      return "birdo";
    case Animal.cats:
      return "catto";
    case Animal.shibes:
      return "doggo";
    default:
      return defaultValue;
  }
}

Iterable<Animal> knownAnimals() {
  return Animal.values.where((element) => element != Animal.artemisUnknown);
}

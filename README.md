# shibe-flutter

A presentation flutter project

## Description

This project was made to demonstrate how we're able to easily
make a type/query safe application using graphql

This app consumes any backend that respects the committed graphql schema
and essentially allow us to:

* Consume photos from [shibe.online](https://shibe.online/)
* Add our own tags to the photos (e.g. "dog", "cat", "puppy")
* View tags and their registered photos

## Running

* Use a compatible backend (recommended: [shibe-rails](https://github.com/Grohden/shibe-rails))
* Be sure `lib/client.dart` is pointing to your valid host (avoid localhost if in emulators/devices)
* Deploy your schema to `lib/schema.graphql`
* Run `flutter pub run build_runner build` and if it works
* Run `flutter run --web-renderer html`(1) 

1 - https://github.com/flutter/flutter/issues/71619

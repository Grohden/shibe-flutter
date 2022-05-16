
DateTime fromGraphQLISO8601DateTimeToDartDateTime(String date) {
    return DateTime.parse(date);
}

String fromDartDateTimeToGraphQLISO8601DateTime(DateTime date) {
    return date.toIso8601String();
}

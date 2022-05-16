import 'package:flutter/material.dart';
import 'package:shibe_flutter/ui/listeners/bottom_reach.dart';

mixin PaginatedLoadable<T, S extends StatefulWidget> on State<S> {
  late ScrollController bottomScrollController;
  List<T> list = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchMore();

    bottomScrollController = ScrollController()
      ..onBottomReach(
        fetchMore,
        sensitivity: 200.0,
        throttleDuration: const Duration(milliseconds: 500),
      );
  }

  void fetchMore() async {
    if (loading) {
      return;
    }

    setState(() {
      loading = true;
    });
    final result = await fetchNextPage();
    if (result != null) {
      setState(() {
        list.addAll(result);
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<Iterable<T>?> fetchNextPage();
}

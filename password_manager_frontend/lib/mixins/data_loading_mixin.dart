import 'package:flutter/material.dart';

mixin DataLoadingMixin <T extends StatefulWidget> on State<T> {
  Future<void> loadData<T>({
    required Future<List<T>> Function() fetchData,
    required void Function(List<T>) onDataLoaded,
    required BuildContext context,
    required String errorMessage,
  }) async {
    try {
      final data = await fetchData();
      if (!mounted) return;
      onDataLoaded(data);
    } catch (e) {
      if (!mounted) return;
      print('Ошибка при загрузке данных: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
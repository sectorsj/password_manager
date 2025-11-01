import 'package:flutter/material.dart';

mixin DeleteItemMixin<T extends StatefulWidget> on State<T> {
  Future<void> deleteItem({
    required Future<void> Function() deleteFunction,
    required Future<void> Function() onItemDeleted,
    required BuildContext context,
    required String errorMessage,
  }) async {
    try {
      await deleteFunction();
      await onItemDeleted();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Элемент успешно удален')),
      );
    } catch (e) {
      print('Ошибка при удалении элемента: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
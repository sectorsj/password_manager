import 'package:flutter/material.dart';

mixin AddItemMixin<T extends StatefulWidget> on State<T> {
  Future<void> addItem({
    required BuildContext context,
    required Widget Function() buildForm,
    required Future<void> Function() onItemAdded,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => buildForm()),
    );
    await onItemAdded();
  }
}
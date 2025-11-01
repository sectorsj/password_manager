import 'package:flutter/material.dart';

mixin DetailsDialogMixin<T extends StatefulWidget> on State<T> {
  void showDetailsDialog({
    required BuildContext context,
    required String title,
    required List<Widget> details,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: details,
          ),
          actions: [
            TextButton(
              child: const Text('Закрыть'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
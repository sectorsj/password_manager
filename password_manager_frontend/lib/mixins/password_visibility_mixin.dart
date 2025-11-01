import 'package:flutter/material.dart';

mixin PasswordVisibilityMixin<T extends StatefulWidget> on State<T> {
  final Map<int, bool> showPasswordMap = {};
  final Map<int, String> decryptedPasswords = {};

  Future<void> togglePasswordVisibility({
    required int index,
    required Future<String> Function() fetchPassword,
    required BuildContext context,
  }) async {
    final isVisible = showPasswordMap[index] ?? false;

    if (!isVisible && !decryptedPasswords.containsKey(index)) {
      try {
        final decrypted = await fetchPassword();
        if (!mounted) return;
        setState(() {
          decryptedPasswords[index] = decrypted;
          showPasswordMap[index] = true;
        });
      } catch (e) {
        if (!mounted) return;
        print('Ошибка при расшифровке пароля: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось расшифровать пароль')),
        );
      }
    } else {
      if (!mounted) return;
      setState(() {
        showPasswordMap[index] = !isVisible;
      });
    }
  }
}
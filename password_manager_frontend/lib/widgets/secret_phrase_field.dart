import 'package:flutter/material.dart';

/// Виджет ПоляВводаСекретнойФразы
class SecretPhraseField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  const SecretPhraseField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
  });

  @override
  _SecretPhraseFieldState createState() => _SecretPhraseFieldState();
}

class _SecretPhraseFieldState extends State<SecretPhraseField> {
  bool _isObscured = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility: Icons.visibility_off
            ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      ),
      validator: widget.validator,
    );
  }
}
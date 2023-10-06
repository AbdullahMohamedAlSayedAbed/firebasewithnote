import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.keyboardType = TextInputType.text, required this.controller,this.obscureText=false, this.validator,
  });
 final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      obscureText: obscureText,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(90),
              borderSide: const BorderSide(color: Colors.grey)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(90),
              borderSide: const BorderSide(color: Colors.grey))),
    );
  }
}

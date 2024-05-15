import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  final TextEditingController con;
  final bool isPassword;
  final String text;
  final IconData logo;
  const Field({
    super.key,
    required this.con,
    required this.isPassword,
    required this.text,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: con,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: text,
          prefixIcon: Icon(logo, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}

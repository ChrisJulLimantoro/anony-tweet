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
    Brightness theme = MediaQuery.of(context).platformBrightness;
    return Container(
      // height: 48,
      width: 350,
      decoration: BoxDecoration(
        color: theme == Brightness.dark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: con,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: text,
          hintStyle: TextStyle(
            color: theme == Brightness.dark ? Colors.white : Colors.grey[800],
          ),
          prefixIcon: Icon(
            logo,
            color: theme == Brightness.dark ? Colors.white : Colors.grey[800],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
        ),
        cursorHeight: Checkbox.width,
      ),
    );
  }
}

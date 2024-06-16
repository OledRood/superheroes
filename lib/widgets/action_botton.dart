import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class ActionBotton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ActionBotton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
            color: SuperheroesColors.blue,
            borderRadius: BorderRadius.circular(8)),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
              fontSize: 14,
              color: SuperheroesColors.text,
              fontWeight: FontWeight.w700,),
        ),
      ),
    );
  }
}

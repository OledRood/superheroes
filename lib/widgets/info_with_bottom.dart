import 'package:flutter/cupertino.dart';

import '../resources/superheroes_colors.dart';
import '../resources/superherous_image.dart';
import 'action_botton.dart';

class InfoWithButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String assetImage;
  final double imageHeight;
  final double imageWidth;
  final double imageTopPadding;
  final VoidCallback onTap;

  const InfoWithButton(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.buttonText,
      required this.assetImage,
      required this.imageHeight,
      required this.imageWidth,
      required this.imageTopPadding,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 108,
                width: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SuperheroesColors.blue,
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: imageTopPadding),
                  child: Image.asset(
                    assetImage,
                    height: imageHeight,
                    width: imageWidth,
                  ))
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
                color: SuperheroesColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 32),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle.toUpperCase(),
            style: TextStyle(
                color: SuperheroesColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 16),
          ),
          const SizedBox(height: 20),
          ActionBotton(
            onTap: onTap,
            text: buttonText,
          )
        ],
      ),
    );
  }
}

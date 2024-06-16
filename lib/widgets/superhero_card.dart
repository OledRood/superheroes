import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superherous_image.dart';

import '../blocs/main_bloc.dart';
import '../model/alignment_info.dart';

class SuperheroCard extends StatelessWidget {
  final SuperheroInfo superheroInfo;
  final VoidCallback onTap;

  const SuperheroCard({
    Key? key,
    required this.superheroInfo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            height: 70,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: SuperheroesColors.indigo,
            ),
            child: Row(
                children: [
                _AvatarWidget(superheroInfo: superheroInfo),
            const SizedBox(width: 12),
            NameAndRealNameWidget(superheroInfo: superheroInfo),
            if(superheroInfo.alignmentInfo != null) AlignmentWidget(
        alignmentInfo: superheroInfo.alignmentInfo!)],
    )
    ,
    )
    ,
    );
  }
}

class AlignmentWidget extends StatelessWidget {
  final AlignmentInfo alignmentInfo;

  const AlignmentWidget({super.key, required this.alignmentInfo});

  @override
  Widget build(BuildContext context) {
    return RotatedBox(quarterTurns: 1,
      child: Container(padding: EdgeInsets.symmetric(vertical: 6), color: alignmentInfo.color,
        alignment: Alignment.center,
        child: Text(alignmentInfo.name.toUpperCase(), style: TextStyle(
          color: SuperheroesColors.text,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
        ),
      ),
    );
  }
}

class NameAndRealNameWidget extends StatelessWidget {
  const NameAndRealNameWidget({
    super.key,
    required this.superheroInfo,
  });

  final SuperheroInfo superheroInfo;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              superheroInfo.name.toUpperCase(),
              style: TextStyle(
                  color: SuperheroesColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
            Text(
              superheroInfo.realName,
              style: TextStyle(
                  color: SuperheroesColors.text,
                  fontWeight: FontWeight.w400,
                  fontSize: 14),
            )
          ],
        ));
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    super.key,
    required this.superheroInfo,
  });

  final SuperheroInfo superheroInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white24,
      height: 70,
      width: 70,
      child: CachedNetworkImage(
          errorWidget:
              (BuildContext context, String url, dynamic error) {
            return Center(
                child: Image.asset(
                  SuperheroesImage.unknown,
                  height: 62,
                  width: 20,
                ));
          },
          progressIndicatorBuilder: (BuildContext context, String url,
              DownloadProgress progress) {
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(
                  color: Color(0xff00BCD4),
                  value: progress.progress,
                ),
                height: 24,
                width: 24,
              ),
            );
          },
          imageUrl: superheroInfo.image,
          height: 70,
          width: 70,
          fit: BoxFit.cover),
    );
  }
}

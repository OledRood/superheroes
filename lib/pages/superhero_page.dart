import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/blocs/superhero_bloc.dart';
import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:http/http.dart' as http;

import '../model/server_image.dart';
import '../model/superhero.dart';
import '../resources/superhero_icons.dart';
import '../widgets/action_botton.dart';

class SuperheroPage extends StatefulWidget {
  final http.Client? client;
  final String id;

  SuperheroPage({super.key, this.client, required this.id});

  @override
  _SuperheroPageState createState() => _SuperheroPageState();
}

class _SuperheroPageState extends State<SuperheroPage> {
  late SuperheroBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = SuperheroBloc(client: widget.client, id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SuperheroContentPage(),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class SuperheroContentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);
    return StreamBuilder<Superhero>(
        stream: bloc.observeSuperhero(),
        builder: (context, snapshot) {
          print('${snapshot.data}');
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          print('234');
          final superhero = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SuperheroAppBar(superhero: superhero),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    if (superhero.powerstats.isNotNull())
                      PowerstatsWidget(powerstats: superhero.powerstats),
                    BiographyWidget(biography: superhero.biography),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class SuperheroAppBar extends StatelessWidget {
  const SuperheroAppBar({
    super.key,
    required this.superhero,
  });

  final Superhero superhero;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      //Можно проскроливать вверх
      stretch: true,
      // Всегда сверху оставался
      pinned: true,
      //когда вниз скролим то картинка выезжает
      floating: true,
      expandedHeight: 348,
      backgroundColor: SuperheroesColors.background,
      centerTitle: true,
      actions: [
        FavoriteButton()
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: superhero.image.url,
          fit: BoxFit.cover,
        ),
        title: Text(
          "${superhero.name}       ",
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: SuperheroesColors.text),
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);

    return StreamBuilder<bool>(
        stream: bloc.observeIsFavorite(),
        initialData: false,
        builder: (context, snapshot) {
          final favorite =
              !snapshot.hasData || snapshot.data == null || snapshot.data!;
          return GestureDetector(
            onTap: () =>
                favorite ? bloc.removeFromFavorite() : bloc.addToFavorite(),
            child: Container(
                height: 52,
                width: 52,
                alignment: Alignment.center,
                child: Image.asset(
                  favorite
                      ? SuperheroIcons.starFilled
                      : SuperheroIcons.starEmpty,
                  height: 32,
                  width: 32,
                )),
          );
        });
  }
}

class PowerstatsWidget extends StatelessWidget {
  final Powerstats powerstats;

  const PowerstatsWidget({super.key, required this.powerstats});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text(
            "Powerstats".toUpperCase(),
            style: TextStyle(
                color: SuperheroesColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 18),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: 'Intelligence',
                  value: powerstats.intelligencePercent,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: 'Strength',
                  value: powerstats.strengthPercent,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: 'Speed',
                  value: powerstats.speedPercent,
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: 'Durability',
                  value: powerstats.durabilityPercent,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: 'Power',
                  value: powerstats.powerPercent,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: PowerstatWidget(
                  name: 'Combat',
                  value: powerstats.combatPercent,
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            )
          ],
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}

class PowerstatWidget extends StatelessWidget {
  final String name;
  final double value;

  const PowerstatWidget({super.key, required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ArcWidget(
          value: value,
          color: calculateColorByValue(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 17.0),
          child: Text(
            '${(value * 100).toInt()}',
            style: TextStyle(
              color: calculateColorByValue(),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 44.0),
          child: Text(
            name.toUpperCase(),
            style: TextStyle(
              color: SuperheroesColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Color calculateColorByValue() {
    if (value <= 0.5) {
      return Color.lerp(Colors.red, Colors.orangeAccent, value / 0.5)!;
    } else {
      return Color.lerp(
          Colors.orangeAccent, Colors.green, (value - 0.5) / 0.5)!;
    }

    return Colors.green;
  }
}

class ArcWidget extends StatelessWidget {
  final double value;
  final Color color;

  const ArcWidget({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArcCustomPainter(value, color),
      size: Size(66, 33),
    );
  }
}

class ArcCustomPainter extends CustomPainter {
  final double value;
  final Color color;

  ArcCustomPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    final backgroundPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    canvas.drawArc(rect, pi, pi, false, backgroundPaint);
    canvas.drawArc(rect, pi, pi * value, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ArcCustomPainter) {
      return oldDelegate.value != value && oldDelegate.color != color;
    }
    return true;
  }
}

class BiographyWidget extends StatelessWidget {
  final Biography biography;

  const BiographyWidget({super.key, required this.biography});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Text(biography.toJson().toString(),
          style: TextStyle(color: SuperheroesColors.text)),
    );
  }
}

import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/model/server_image.dart';


import 'package:json_annotation/json_annotation.dart';

part 'superhero.g.dart';

@JsonSerializable()
class Superhero {
  final String name;
  final String id;
  final Biography biography;
  final ServerImage image;
  final Powerstats powerstats;


  Superhero({required this.name, required this.id, required this.biography, required this.image, required this.powerstats});

  factory Superhero.fromJson(final Map<String, dynamic> json) =>
      _$SuperheroFromJson(json);

  Map<String, dynamic> toJson() => _$SuperheroToJson(this);
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/superhero.dart';
import 'package:superheroes/pages/main_page.dart';

class SuperheroBloc {
  final String id;
  http.Client? client;
  final superheroSubject = BehaviorSubject<Superhero>();
  StreamSubscription? getFromFavoriteSubscription;
  StreamSubscription? requestSubscription;
  StreamSubscription? addToFavoriteSubscription;
  StreamSubscription? removeFromFavoriteSubscription;

  SuperheroBloc({
    this.client,
    required this.id,
  }) {
    getFromFavorites();
  }

  void requestSuperhero() {
    print("requestSuperhero");
    requestSubscription?.cancel();
    requestSubscription = request().asStream().listen((superhero) {
      superheroSubject.add(superhero);
    }, onError: (error, stackTrace) {
      print("Error in requestSuperhero: $error");
    });
  }

  Future<Superhero> request() async {
    // await Future.delayed(Duration(seconds: 2));
    final token = dotenv.env["SUPERHERO_TOKEN"]!;
    //если client == null, создаем новый и присваеваем переменную, если нет то просто используем что имеем
    final response = await (client ??= http.Client())
        .get(Uri.parse("https://superheroapi.com/api/$token/$id"));
    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException(message: "Server error happened");
    }
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException(message: "Client error happened");
    }
    final decoded = json.decode(response.body);
    if (decoded['response'] == 'success') {
      return Superhero.fromJson(decoded);
    } else if (decoded['response'] == 'error') {
      throw ApiException(message: "Client error happened");
    }
    throw Exception("Unknown error happened");

    // сортируем данные списка полученного где имя совпадает с текстом
    // return SuperheroInfo.mocked
    //     .where((superheroInfo) =>
    //         superheroInfo.name.toLowerCase().contains(text.toLowerCase()))
    //     .toList();
  }

  Stream<Superhero> observeSuperhero() => superheroSubject;

  void getFromFavorites() {
    getFromFavoriteSubscription?.cancel();
    getFromFavoriteSubscription = FavoriteSuperheroesStorage.getInstans()
        .getSuperhero(id)
        .asStream()
        .listen((superhero) {
      if (superhero != null) {
        superheroSubject.add(superhero);
      }
      requestSuperhero();
    }, onError: (error, stackTrace) {
      print("Error in addToFavorite: $error");
    });
  }

  void addToFavorite() {
    final superhero = superheroSubject.valueOrNull;
    if (superhero == null) {
      print("Error: superhero is null while shouldn't be");
      return;
    }
    addToFavoriteSubscription?.cancel();
    addToFavoriteSubscription = FavoriteSuperheroesStorage.getInstans()
        .addToFavorites(superhero)
        .asStream()
        .listen((event) {
      print("Added to favorites: $event");
    }, onError: (error, stackTrace) {
      print("Error in addToFavorite: $error");
    });
  }

  void removeFromFavorite() {
    final superhero = superheroSubject.valueOrNull;
    if (superhero == null) {
      print("Error: superhero is null while shouldn't be");
      return;
    }
    removeFromFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription = FavoriteSuperheroesStorage.getInstans()
        .removeFromFavorites(id)
        .asStream()
        .listen((event) {
      print("remove from favorites: $event");
    }, onError: (error, stackTrace) {
      print("Error in removeFromFavorite: $error");
    });
  }

  Stream<bool> observeIsFavorite() =>
      FavoriteSuperheroesStorage.getInstans().observeIsFavorite(id);

  void dispose() {
    client?.close();
    requestSubscription?.cancel();
    superheroSubject.close();
    addToFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription?.cancel();
    getFromFavoriteSubscription?.cancel();
  }
}

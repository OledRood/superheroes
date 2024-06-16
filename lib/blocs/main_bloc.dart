import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/superhero.dart';
import 'package:superheroes/pages/main_page.dart';

import '../model/alignment_info.dart';

class MainBloc {
  static const minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final searchSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubjects = BehaviorSubject<String>.seeded('');

  StreamSubscription? removeFromFavoriteSubscription;

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  http.Client? client;

  //Добавляем изначальную позицию
  MainBloc({this.client}) {
    textSubscription =
        Rx.combineLatest2<String, List<Superhero>, MainPageStateInfo>(
                currentTextSubjects
                    .distinct()
                    .debounceTime(Duration(milliseconds: 500)),
                FavoriteSuperheroesStorage.getInstans()
                    .observeFavoriteSuperheroes(),
                (searchText, favorites) =>
                    MainPageStateInfo(searchText, favorites.isNotEmpty))
            .listen((value) {
      print('Changed');
      searchSubscription?.cancel();
      if (value.searchText.isEmpty) {
        if (value.haveFavorites) {
          stateSubject.add(MainPageState.favorites);
        } else {
          stateSubject.add(MainPageState.noFavorites);
        }
      } else if (value.searchText.length < minSymbols) {
        stateSubject.add(MainPageState.minSymbols);
      } else {
        searchForSuperheroes(value.searchText);
      }
    });
  }

  void removeFromFavorites(final String id) {
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

  void searchForSuperheroes(final text) {
    stateSubject.add(MainPageState.loading);
    searchSubscription?.cancel();
    searchSubscription = search(text).asStream().listen((searchResults) {
      if (searchResults.isEmpty) {
        stateSubject.add(MainPageState.nothingFound);
      } else {
        print('search for superheroes');
        searchSuperheroesSubject.add(searchResults);
        stateSubject.add(MainPageState.searchResults);
      }
    }, onError: (error, stackTrace) {
      print(error);
      stateSubject.add(MainPageState.loadingError);
    });
  }

  void retry() {
    final currentText = currentTextSubjects.value;
    searchForSuperheroes(currentText);
  }

  Stream<List<SuperheroInfo>> observeFavoritesSuperheroes() =>
      FavoriteSuperheroesStorage.getInstans().observeFavoriteSuperheroes().map(
          (superheroes) => superheroes
              .map((superhero) => SuperheroInfo.fromSuperhero(superhero))
              .toList());

  Stream<List<SuperheroInfo>> observeSearchSuperheroes() =>
      searchSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    // await Future.delayed(Duration(seconds: 2));
    final token = dotenv.env["SUPERHERO_TOKEN"]!;
    //если client == null, создаем новый и присваеваем переменную, если нет то просто используем что имеем
    final response = await (client ??= http.Client())
        .get(Uri.parse("https://superheroapi.com/api/$token/search/$text"));
    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException(message: "Server error happened");
    }
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException(message: "Client error happened");
    }
    final decoded = json.decode(response.body);
    if (decoded['response'] == 'success') {
      final List<dynamic> results = decoded['results'];
      final List<Superhero> superheroes = results
          .map((rawSuperhero) => Superhero.fromJson(rawSuperhero))
          .toList();
      final List<SuperheroInfo> found = superheroes.map((superhero) {
        return SuperheroInfo.fromSuperhero(superhero);
      }).toList();
      return found;
    } else if (decoded['response'] == 'error') {
      if (decoded['error'] == 'character with given name not found') {
        return [];
      }
      throw ApiException(message: "Client error happened");
    }
    throw Exception("Unknown error happened");

    // сортируем данные списка полученного где имя совпадает с текстом
    // return SuperheroInfo.mocked
    //     .where((superheroInfo) =>
    //         superheroInfo.name.toLowerCase().contains(text.toLowerCase()))
    //     .toList();
  }

  Stream<MainPageState> observeMainPageState() => stateSubject;

  // void removeFavorites() {
  //   final currentFavorites = favoritesSuperheroesSubject.value;
  //   if (currentFavorites.isEmpty) {
  //     favoritesSuperheroesSubject.add(SuperheroInfo.mocked);
  //   } else {
  //     favoritesSuperheroesSubject
  //         .add(currentFavorites.sublist(0, currentFavorites.length - 1));
  //   }
  // }

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];
    stateSubject.sink.add(nextState);
  }

  void updateText(final String? text) {
    currentTextSubjects.add(text ?? "");
  }

  void dispose() {
    searchSuperheroesSubject.close();
    currentTextSubjects.close();
    client?.close();
    stateSubject.close();
    removeFromFavoriteSubscription?.cancel();
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites,
}

class SuperheroInfo {
  final String id;
  final String name;
  final String realName;
  final String image;
  final AlignmentInfo? alignmentInfo;


  const SuperheroInfo(
      {required this.id,
      required this.name,
      required this.realName,
      required this.image, this.alignmentInfo});

  factory SuperheroInfo.fromSuperhero(final Superhero superhero) {
    return SuperheroInfo(
      alignmentInfo: superhero.biography.alignmentInfo,
        id: superhero.id,
        name: superhero.name,
        realName: superhero.biography.fullName,
        image: superhero.image.url,
      );
  }

  @override
  String toString() {
    return 'SuperheroInfo{id: $id, name: $name, realName: $realName, image: $image}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuperheroInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          realName == other.realName &&
          image == other.image;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ realName.hashCode ^ image.hashCode;

  static const mocked = [
    SuperheroInfo(
        id: "70",
        name: "Batman",
        realName: "Bruce Wayne",
        image:
            "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg"),
    SuperheroInfo(
        id: "732",
        name: "Ironman",
        realName: "Tony Stark",
        image: "https://www.superherodb.com/pictures2/portraits/10/100/85.jpg"),
    SuperheroInfo(
        id: "687",
        name: "Venom",
        realName: "Eddie Brock",
        image: "https://www.superherodb.com/pictures2/portraits/10/100/22.jpg"),
  ];
}

class MainPageStateInfo {
  final String searchText;
  final bool haveFavorites;

  const MainPageStateInfo(this.searchText, this.haveFavorites);

  @override
  String toString() {
    return 'MainPageStateInfo{searchText: $searchText, haveFavorites: $haveFavorites}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainPageStateInfo &&
          runtimeType == other.runtimeType &&
          searchText == other.searchText &&
          haveFavorites == other.haveFavorites;

  @override
  int get hashCode => searchText.hashCode ^ haveFavorites.hashCode;
}

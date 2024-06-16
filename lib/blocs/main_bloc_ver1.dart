// import 'dart:async';
//
// import 'package:superheroes/pages/main_page.dart';
//
// class MainBloc {
//   final StreamController<MainPageState> stateController =
//       StreamController.broadcast();
//
//   //Нужне для метода listen (изначально может быть пустым
//   StreamSubscription<MainPageState>? stateSubscription;
//
//   Stream<MainPageState> observeMainPageState() {
//     return stateController.stream;
//   }
//
//   //Добавляем изначальную позицию
//   MainBloc() {
//     stateController.sink.add(MainPageState.noFavorites);
//   }
//
// //TODO DIECODE
// //
// //   //Возвращаем состояние экрана
// //   Stream<MainPageState> observeMainPageState() {
// //     //periodic создает новый стрим с новой периодичностью
// //     //Каждый две секунды будет выскакивать новое значение
// //     return Stream.periodic(Duration(seconds: 2), (tick) => tick).map(
// //       //Преобразовывает из нашего tick следующий state
// //       //с помощью % получаем бесконечный цикл от 0, до 7
// //             (tick) => MainPageState.values[tick % MainPageState.values.length]);
// //   }
// //TODO STOP DIECODE
//
//   void nextState() {
//     //ОБЩАЯ РАБОТА МЕТОДА
//     //Нажимаем на кнопку и берем один элемент из стрима и
//     stateSubscription?.cancel();
//     //мы подписываемся на этот стрим take(сколько значений нам нужно получать, в listen мы обрабатываем эти значения
//     stateSubscription = stateController.stream.take(1).listen((currentState) {
//       final nextState = MainPageState.values[
//           (MainPageState.values.indexOf(currentState) + 1) %
//               MainPageState.values.length];
//       stateController.sink.add(nextState);
//     });
//   }
//
//   void dispose() {
//     stateSubscription?.cancel();
//     stateController.close();
//   }
// }
//
// enum MainPageState {
//   noFavorites,
//   minSymbols,
//   loading,
//   nothingFound,
//   loadingError,
//   searchResults,
//   favorites,
// }

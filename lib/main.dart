import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/pages/main_page.dart';
void main() async {
  //Сделать main ассинхронным/ добавить в ассеты/ добавить в гитигнор
  //Получить значения из .env
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),

      ),

      home: MainPage()
    );
  }
}

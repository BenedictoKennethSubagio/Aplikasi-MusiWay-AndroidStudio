import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test2/infoHandler/infoapp.dart';
import 'package:test2/screens/login_screen.dart';
import 'package:test2/screens/main_screen.dart';
import 'package:test2/screens/register_screen.dart';
import 'package:test2/splashscreen/splash_screen.dart';
import 'package:test2/themeProvider/theme_provider.dart';

Future<void> main() async{
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>Infoapp(),
      child: MaterialApp(
          title: 'Flutter Demo',
          themeMode: ThemeMode.system,
          theme: MyThemes.darkTheme,
          darkTheme: MyThemes.darkTheme,
          debugShowCheckedModeBanner: false,
          home: MainScreen()
      ),
    );
  }
}



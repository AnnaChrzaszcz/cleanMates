import 'package:clean_mates_app/screens/add_new_room.dart';

import './screens/dashbord_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(167, 34, 110, 1),
        primarySwatch: Colors.pink,
        appBarTheme: AppBarTheme(color: Color.fromRGBO(167, 34, 110, 1)),
        iconTheme: IconThemeData(color: Color.fromRGBO(47, 149, 153, 1)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Color.fromRGBO(47, 149, 153, 1),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide.none))),
        ),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor:
              MaterialStateProperty.all(Color.fromRGBO(47, 149, 153, 1)),
        )),
        //Color.fromRGBO(247, 219, 79, 1)
        accentColor: Color.fromRGBO(47, 149, 153, 1),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData) {
            return DashboardScreen();
          }
          return AuthScreen();
        },
      ),
      routes: {
        DashboardScreen.routeName: (context) => DashboardScreen(),
        AddNewRoom.routeName: (context) => AddNewRoom(),
      },
    );
  }
}

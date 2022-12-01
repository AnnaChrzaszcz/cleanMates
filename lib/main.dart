import 'package:clean_mates_app/screens/create_room_screen.dart';
import 'package:clean_mates_app/screens/user_dashboard_screen.dart';

import 'screens/room_dashbord_screen.dart';
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
              // backgroundColor: MaterialStateProperty.all(
              //   Color.fromRGBO(47, 149, 153, 1),
              // ),
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled))
                    return Colors.grey;
                  return Color.fromRGBO(
                      47, 149, 153, 1); // Use the component's default.
                },
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
            return RoomDashboardScreen();
          }
          return AuthScreen();
        },
      ),
      routes: {
        RoomDashboardScreen.routeName: (context) => RoomDashboardScreen(),
        CreateRoomScreen.routeName: (context) => CreateRoomScreen(),
        UserDashboardScreen.routeName: (context) => UserDashboardScreen(),
      },
    );
  }
}

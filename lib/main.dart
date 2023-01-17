import 'package:clean_mates_app/providers/gifts_provider.dart';
import 'package:clean_mates_app/screens/activities_screen.dart';
import 'package:clean_mates_app/screens/buy_gift_screen.dart';
import 'package:clean_mates_app/screens/create_room_screen.dart';
import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/screens/edit_gift_screen.dart';
import 'package:clean_mates_app/screens/gifts_screen.dart';
import 'package:clean_mates_app/screens/history_screen.dart';
import 'package:clean_mates_app/screens/gifts_reception_screen.dart';
import 'package:clean_mates_app/screens/save_activity_screen.dart';
import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:clean_mates_app/screens/user_profile_screen.dart';
import 'package:clean_mates_app/screens/user_room_screen.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import './screens/auth_screen.dart';
import 'providers/rooms_provider.dart';
import 'providers/activities_provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: RoomsProvider(
            [],
            null,
          ),
        ),
        ChangeNotifierProvider.value(
          value: ActivitiesProvider(
            [],
          ),
        ),
        ChangeNotifierProvider.value(
          value: GiftsProvider(
            [],
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Color.fromRGBO(167, 34, 110, 1),
            //primarySwatch: Colors.pink,
            appBarTheme: AppBarTheme(color: Color.fromRGBO(167, 34, 110, 1)),
            iconTheme: IconThemeData(color: Color.fromRGBO(47, 149, 153, 1)),
            dividerColor: Color.fromRGBO(47, 149, 153, 1),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: Color.fromRGBO(247, 219, 79, 1),
              // contentTextStyle: TextStyle(color: Color.fromRGBO(236, 32, 73, 1)),
              contentTextStyle: TextStyle(color: Colors.black),
            ),
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
            colorScheme: ThemeData().colorScheme.copyWith(
                  primary: Color.fromRGBO(47, 149, 153, 1),
                )),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasData) {
              return UserDashboardScreen();
            }
            return AuthScreen();
          },
        ),
        routes: {
          CreateRoomScreen.routeName: (context) => CreateRoomScreen(),
          UserDashboardScreen.routeName: (context) => UserDashboardScreen(),
          UserRoomScreen.routeName: (context) => UserRoomScreen(),
          ActivitiesScreen.routeName: (context) => ActivitiesScreen(),
          EditActivityScreen.routeName: (context) => EditActivityScreen(),
          GiftsScreen.routeName: (context) => GiftsScreen(),
          EditGiftScreen.routeName: (context) => EditGiftScreen(),
          SaveActivityScreen.routeName: (context) => SaveActivityScreen(),
          BuyGiftScreen.routeName: (context) => BuyGiftScreen(),
          HistoryScreen.routeName: (context) => HistoryScreen(),
          UserProfile.routeName: (context) => UserProfile(),
          RecivedGiftsScreen.routeName: (context) => RecivedGiftsScreen()
        },
      ),
    );
  }
}

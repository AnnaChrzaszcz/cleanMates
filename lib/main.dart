import 'package:clean_mates_app/providers/gifts_provider.dart';
import 'package:clean_mates_app/screens/activities_screen.dart';
import 'package:clean_mates_app/screens/buy_gift_screen.dart';
import 'package:clean_mates_app/screens/create_room_screen.dart';
import 'package:clean_mates_app/screens/edit_activity_screen.dart';
import 'package:clean_mates_app/screens/edit_gift_screen.dart';
import 'package:clean_mates_app/screens/gifts_screen.dart';
import 'package:clean_mates_app/screens/gratification_activity_screen.dart';
import 'package:clean_mates_app/screens/gratification_gift_screen.dart';
import 'package:clean_mates_app/screens/history_screen.dart';
import 'package:clean_mates_app/screens/onboarding_screen.dart';
import 'package:clean_mates_app/screens/gifts_reception_screen.dart';
import 'package:clean_mates_app/screens/save_activity_screen.dart';
import 'package:clean_mates_app/screens/stats_screen.dart';
import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:clean_mates_app/screens/user_profile_screen.dart';
import 'package:clean_mates_app/screens/user_room_screen.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import './screens/auth_screen.dart';
import 'providers/rooms_provider.dart';
import 'providers/activities_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final bool repeat = prefs.getBool('visited');
  runApp(MyApp(repeat));
}

class MyApp extends StatelessWidget {
  final bool repeat;
  MyApp(this.repeat);
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
            primaryColor: const Color.fromRGBO(167, 34, 110, 1),
            appBarTheme:
                const AppBarTheme(color: Color.fromRGBO(167, 34, 110, 1)),
            iconTheme:
                const IconThemeData(color: Color.fromRGBO(47, 149, 153, 1)),
            dividerColor: const Color.fromRGBO(47, 149, 153, 1),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color.fromRGBO(247, 219, 79, 1),
              contentTextStyle: TextStyle(color: Colors.black),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey;
                      }
                      return const Color.fromRGBO(47, 149, 153, 1);
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide.none))),
            ),
            textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                  const Color.fromRGBO(47, 149, 153, 1)),
            )),
            accentColor: const Color.fromRGBO(47, 149, 153, 1),
            colorScheme: ThemeData().colorScheme.copyWith(
                  primary: const Color.fromRGBO(47, 149, 153, 1),
                )),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasData) {
              User user = userSnapshot.data;
              if (user.displayName != null && user.photoURL != null) {
                return const OnBoardingPage(isLogin: true);
              }
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
          GratificationActivityScreen.routeName: (context) =>
              GratificationActivityScreen(),
          GratificationGiftScreen.routeName: (context) =>
              GratificationGiftScreen(),
          RecivedGiftsScreen.routeName: (context) => RecivedGiftsScreen(),
          StatsScreen.routeName: (context) => StatsScreen(),
        },
      ),
    );
  }
}

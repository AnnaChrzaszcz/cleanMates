import 'package:clean_mates_app/screens/auth_screen.dart';
import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:clean_mates_app/widgets/auth/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class IntroScreen extends StatefulWidget {
  @override
  IntroScreen();

  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      _createRoute(),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.black),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          body: "Invite your room mate and make house keeping more fun",
          title: "App for room mates",
          image: Container(
            width: 300,
            height: 300,
            child: Lottie.asset('assets/animations/lottie/intro.json'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          body: "Like cleaning, cooking, washing dishes etc. ",
          title: "Earn points for home responsibilities",
          image: Container(
            width: 300,
            height: 300,
            child: Lottie.asset('assets/animations/lottie/intro2.json'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          body:
              "You decide what value different tasks are and what gifts you can get",
          title: "Exchange points for gifts",
          image: Container(
            width: 300,
            height: 300,
            child: Lottie.asset('assets/animations/lottie/intro3.json'),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      showNextButton: false,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      done: const Text('Join', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

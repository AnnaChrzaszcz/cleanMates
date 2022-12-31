import 'package:clean_mates_app/screens/auth_screen.dart';
import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:clean_mates_app/widgets/auth/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:rive/rive.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  final bool isLogin;
  OnBoardingPage({this.isLogin});

  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      _createRoute(),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          widget.isLogin ? UserDashboardScreen() : AuthScreen(),
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
          fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.white),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color.fromRGBO(167, 34, 110, 1),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Theme.of(context).primaryColor,
      pages: [
        PageViewModel(
          body: "",
          titleWidget: Container(
            child: AnimatedTextKit(
              animatedTexts: [
                ScaleAnimatedText('CLEAN',
                    textStyle:
                        TextStyle(color: Color.fromRGBO(167, 34, 110, 1)),
                    duration: Duration(milliseconds: 1000)),
                // ScaleAnimatedText('HAVE FUN',
                //     textStyle: TextStyle(color: Colors.white, fontSize: 40)),
              ],
              isRepeatingAnimation: false,
              onFinished: () => _onIntroEnd(context),
            ),
          ),
          image: Container(
            width: 300,
            height: 300,
            child: const RiveAnimation.asset(
              'assets/animations/roomie.riv',
            ),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: false,
      showNextButton: false,
      showDoneButton: false,
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      done: const Text('Skip',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

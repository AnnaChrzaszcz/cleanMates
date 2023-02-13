import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class GratificationGiftScreen extends StatefulWidget {
  static const String routeName = '/gratificationGift';

  _GratificationActivityScreenState createState() =>
      _GratificationActivityScreenState();
}

class _GratificationActivityScreenState extends State<GratificationGiftScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();
  var giftsSum;

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      _createRoute(),
    );
  }

  @override
  void didChangeDependencies() {
    giftsSum = ModalRoute.of(context).settings.arguments as int;
    super.didChangeDependencies();
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          UserDashboardScreen(),
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
    String gifts = giftsSum == 1 ? 'gift' : 'gifts';

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
      ),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return GestureDetector(
      onTap: () => _onIntroEnd(context),
      child: IntroductionScreen(
        key: introKey,
        globalBackgroundColor: Colors.white,
        pages: [
          PageViewModel(
            title: 'Congratulations!',
            bodyWidget: Container(
              child: Column(
                children: [
                  Text('You bought $giftsSum $gifts ', style: bodyStyle),
                  AnimatedTextKit(
                    animatedTexts: [
                      ScaleAnimatedText('You earned 100 points',
                          textStyle: TextStyle(color: Colors.white),
                          duration: Duration(milliseconds: 1800)),
                    ],
                    isRepeatingAnimation: false,
                    onFinished: () => _onIntroEnd(context),
                  )
                ],
              ),
            ),
            image: Lottie.asset('assets/animations/lottie/gift.json'),
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
      ),
    );
  }
}

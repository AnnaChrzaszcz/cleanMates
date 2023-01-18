import 'package:clean_mates_app/screens/user_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class GratificationActivityScreen extends StatefulWidget {
  static const String routeName = '/gratificationActivity';

  _GratificationActivityScreenState createState() =>
      _GratificationActivityScreenState();
}

class _GratificationActivityScreenState
    extends State<GratificationActivityScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();
  var pointsSum;
  var username;

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      _createRoute(),
    );
  }

  @override
  void didChangeDependencies() {
    Map<String, dynamic> modalArgs = ModalRoute.of(context).settings.arguments;
    pointsSum = modalArgs['points'];
    username = modalArgs['username'];
    //pointsSum = ModalRoute.of(context).settings.arguments;
    // TODO: implement didChangeDependencies
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

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          title: 'Congratulations!',
          bodyWidget: Container(
            child: Column(
              children: [
                Text('${username} earned $pointsSum points!', style: bodyStyle),
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
          image: Lottie.asset('assets/animations/lottie/confetti.json'),
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

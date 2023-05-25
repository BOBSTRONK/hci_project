import 'package:flutter/material.dart';
import 'package:hci_project/home.dart';
import 'package:hci_project/intro_page/intro_page_1.dart';
import 'package:hci_project/intro_page/intro_page_2.dart';
import 'package:hci_project/intro_page/intro_page_3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  // controller keep track of which page we're on
  PageController _controller = PageController();

  //keep track of if we are on the last page or not
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                //if the index is 2 the onLastPage will be true
                onLastPage = (index == 2);
              });
            },
            children: [
              IntroPageOne(),
              IntroPageTwo(),
              IntroPageThree(),
            ],
          ),
          // dot indicator,
          Container(
              // alignment is where the indicator is, it represents x and y
              alignment: Alignment(0, 0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //skip
                  onLastPage
                      ? Text("")
                      : GestureDetector(
                          onTap: () {
                            _controller.jumpToPage(2);
                          },
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                  // dot indicator
                  SmoothPageIndicator(controller: _controller, count: 3),

                  //next or done
                  onLastPage
                      ? GestureDetector(
                          onTap: () async {
                            //Navigator.push to the home page
                            await setOnboardingCompleted();
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Home();
                            }));
                          },
                          child: Text(
                            "Done",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            _controller.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          },
                          child: Text(
                            "Next",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                ],
              ))
        ],
      ),
    );
  }
}

Future<void> setOnboardingCompleted() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboardingCompleted', true);
}

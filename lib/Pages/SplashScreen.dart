import 'dart:async';
import 'package:flutter/material.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.of(context)
          .pushNamed('/CanadianResumeForm');
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'img/undraw_Resume_re_hkth.png',
              width: w*0.7,
              height: h*0.3,
              fit: BoxFit.cover,
            ),
          //  Ink.image(image: const AssetImage('img/resume.png'),width: w*0.3, height: h * 0.3,),
           // FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text(
              'Profilio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

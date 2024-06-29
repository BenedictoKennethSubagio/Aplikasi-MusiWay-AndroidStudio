import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test2/Assistants/assistant.dart';
import 'package:test2/global/global.dart';
import 'package:test2/screens/login_screen.dart';
import 'package:test2/screens/main_screen.dart';
import 'package:test2/widgets/placepredictiontitle.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  startTimer(){
    Timer(Duration(seconds: 3),()async{
      if(await firebaseAuth.currentUser != null ){
        firebaseAuth.currentUser!=null? AssistantMethods.readCurrentonlineUserInfo():null;
        Navigator.push(context, MaterialPageRoute(builder: (c)=>MainScreen()));
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));
      }
    });
  }
  @override
  void iniState(){
    super.initState();
    startTimer();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'TrackingTest',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}

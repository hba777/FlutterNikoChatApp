import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatapp/api/apis.dart';
import 'package:flutter_chatapp/screens/auth/login_screen.dart';
import 'package:flutter_chatapp/screens/home_screen.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    //Navigate to homescreen
    Future.delayed(const Duration(seconds:2),(){

      //Newer Android Issues Fix fullscreen and Nav Bar Color
      //Exit FullScreen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.white
      ));

      if(APIs.auth.currentUser != null){
        log('\nUser: ${APIs.auth.currentUser}');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));

      }else
        {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false,
        title: const Text("Chat App",textAlign: TextAlign.center,),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('images/cat.png')),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width * 1,
              child: const Text('NIKO IS QUEEN',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
              ))
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:library_flutter/Login/login_page.dart';

import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '동서남Book',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginPage(title: 'login',),
    );
  }

}
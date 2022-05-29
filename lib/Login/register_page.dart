import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:library_flutter/Login/login_page.dart';

import 'package:firebase_auth/firebase_auth.dart';


class RegisterPage extends StatefulWidget {

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var rememberValue = false;

  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,  // Botton Overflowed by Pixels
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              '회원 가입',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    validator: (value) => EmailValidator.validate(value!)
                        ? null
                        : "Please enter a valid email",
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    maxLines: 1,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // Firebase Authentication Register (Email/Password)
                  GestureDetector(
                      onTap: () async {
                        try {
                          UserCredential userCredential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text)
                              .then((value) {
                            if (value.user!.email == null) {
                            } else {

                              // 화면 전환하지 말고 이메일 인증하라는 팝업 띄우기

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => LoginPage()));
                            }
                            return value;
                          });
                          FirebaseAuth.instance.currentUser?.sendEmailVerification();
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('the password provided is too weak');
                          } else if (e.code == 'email-already-in-use') {
                            print('The account already exists for that email.');
                          } else {
                            print('11111');
                          }
                        } catch (e) {
                          print('끝');
                        }
                      },
                      child: Container(
                        width: 328,
                        height: 48,
                        color: Colors.amber,
                        child: const Center(child: Text('회원가입')),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('회원이라면?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: const Text('로그인'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}








import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:library_flutter/Login/register_page.dart';
import 'package:library_flutter/Screen/interface.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var rememberValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              '동서남BOOK',
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
                      prefixIcon  : const Icon(Icons.email),
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
                  CheckboxListTile(
                    title: const Text("Remember me"),
                    contentPadding: EdgeInsets.zero,
                    value: rememberValue,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (newValue) {
                      setState(() {
                        rememberValue = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                      onTap: () async {
                        try {
                          UserCredential userCredential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text) //아이디와 비밀번호로 로그인 시도
                              .then((value) {
                            print(value);
                            value.user!.emailVerified == true //이메일 인증 여부
                                ? Navigator.push(context,
                                MaterialPageRoute(builder: (_) => Interface()))
                                : print('이메일 확인 안댐');
                            return value;
                          });
                        } on FirebaseAuthException catch (e) {
                          //로그인 예외처리
                          if (e.code == 'user-not-found') {
                            print('등록되지 않은 이메일입니다');
                          } else if (e.code == 'wrong-password') {
                            print('비밀번호가 틀렸습니다');
                          } else {
                            print(e.code);
                          }
                        }
                      },
                      child: Container(
                        child: Center(
                          child: Text(
                            '로그인',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        width: 100,
                        height: 50,
                        color: Colors.black,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('아직 회원이 아니라면?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                        child: const Text('회원가입'),
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


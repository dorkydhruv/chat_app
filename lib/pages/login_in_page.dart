// import 'package:flutter/foundation.dart';
import 'package:chat_app/constants.dart';
import 'package:chat_app/helper/helper_func.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/register.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets.dart/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginInPage extends StatefulWidget {
  const LoginInPage({super.key});

  @override
  State<LoginInPage> createState() => _LoginInPageState();
}

class _LoginInPageState extends State<LoginInPage> {
  AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String email = '';
  String passowrd = '';

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
            ),
          )
        : Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Chatyy Box',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Login Now to see what they are talking!',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                      Image.asset(
                        'assets/login.png',
                        fit: BoxFit.fill,
                      ),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: Constants.primaryColor,
                            )),
                        onChanged: (value) => setState(() {
                          email = value;
                          print(email);
                        }),
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val!)
                              ? null
                              : 'Please Enter a valid Email';
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Password',
                            prefixIcon: Icon(
                              Icons.key,
                              color: Constants.primaryColor,
                            )),
                        validator: (val) {
                          if (val!.length < 6) {
                            return 'Password must be atleast 6 characters';
                          } else {
                            return null;
                          }
                        },
                        obscureText: true,
                        onChanged: (value) => setState(() {
                          passowrd = value;
                        }),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          login();
                        },
                        child: const Text('Login'),
                        style: ElevatedButton.styleFrom(
                          primary: Constants.primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                            text: "Dont have an account yet?",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                            children: <TextSpan>[
                              TextSpan(
                                  text: " Register here",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreen(context, const RegisterPage());
                                    })
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Future login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithEmailAndPassword(email, passowrd)
          .then((value) async {
        if (value == true) {
          QuerySnapshot querySnapshot =
              await DatabseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .getUserData(email);

          /// saving values to SharedPreferneces
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSf(email);
          await HelperFunction.saveUserNameSF(
              querySnapshot.docs[0]['fullName']);
          // ignore: use_build_context_synchronously
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackBar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}

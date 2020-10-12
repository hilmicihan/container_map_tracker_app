import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:evreka_bin_tracker/constants.dart';
import 'package:evreka_bin_tracker/main.dart';
import 'package:evreka_bin_tracker/screens/pageConnection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Timer timer;
  bool isConnected = false;
  bool isFinished = false;

  void CheckConnectivity() async {
    if (isFinished) return;
    var ConnectionResult = await (Connectivity().checkConnectivity());
    if (ConnectionResult == ConnectivityResult.mobile ||
        ConnectionResult == ConnectivityResult.wifi) {
      setState(() {
        isConnected = true;
      });
    } else {
      isConnected = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    CheckConnectivity();
    timer =
        Timer.periodic(Duration(seconds: 2), (Timer t) => CheckConnectivity());
    super.initState();
  }

  String email, password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double size_height;
  double size_width;

  @override
  Widget build(BuildContext context) {
    CheckConnectivity();
    size_height = MediaQuery.of(context).size.height;
    size_width = MediaQuery.of(context).size.width;
    return isConnected == false
        ? PageConnection()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              child: Column(
                children: [
                  SizedBox(height: size_height * 0.2),
                  Image.asset('assets/evreka.jpg'),
                  Text(
                    "Please enter your username and password",
                    style: t2,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextFormField(
                            validator: (input) {
                              if (input.isEmpty ||
                                  !EmailValidator.validate(input))
                                return "Username is not filled or invalid email adress";
                            },
                            onSaved: (input) => email = input,
                            decoration: InputDecoration(labelText: "Username"),
                          ),
                        ), //username
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextFormField(
                            validator: (input) {
                              if (input.length < 6)
                                return "Your Password is empty or less than 6 character";
                            },
                            onSaved: (input) => password = input,
                            decoration: InputDecoration(labelText: "Password"),
                            obscureText: true,
                          ),
                        ),
                        SizedBox(
                          height: size_height * 0.2,
                        ),
                        RaisedButton(
                          onPressed: _login,
                          color: Colors.green,
                          disabledColor: shadowColorGreen,
                          focusColor: Colors.green,
                          child: Text(
                            "LOGİN",
                            style: buttonText,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future _alertShow(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Something is Wrong'),
          content: const Text('Your username or password is wrong.'),
          actions: [
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    await Firebase.initializeApp();
    final formInfo = _formKey.currentState;
    if (formInfo.validate()) {
      // authentication
      formInfo.save();
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        Route route = MaterialPageRoute(
            builder: (context) => MyHomePage(title: "Map Screen"));
        isFinished = true;
        Navigator.pushReplacement(context, route);
        print("success");
      } on FirebaseAuthException catch (e) {
        _alertShow(context);
        print("an error occured");
        print(e);
      } on PlatformException catch (e) {
        _alertShow(context);
        print(e);
      }
    }
  }
}

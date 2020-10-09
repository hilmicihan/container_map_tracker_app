import 'package:evreka_bin_tracker/constants.dart';
import 'package:evreka_bin_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email, password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double size_height;
  double size_width;

  @override
  Widget build(BuildContext context) {
    size_height = MediaQuery.of(context).size.height;
    size_width = MediaQuery.of(context).size.width;
    return Scaffold(
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
                        if (input.isEmpty) return "Username is not filled";
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

  Future<void> _login() async {
    final formInfo = _formKey.currentState;
    if (formInfo.validate()) {
      // TODO validate
      // authentication
      formInfo.save();
      try {
        var user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        print("success");
        Route route = MaterialPageRoute(
            builder: (context) => MyHomePage(title: "Map Screen"));
        Navigator.pushReplacement(context, route);
      } catch (e) {
        // TODO
        print(e);
      }
    }
  }
}

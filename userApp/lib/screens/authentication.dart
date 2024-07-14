import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


import 'home.dart';

class AuthenticationScreen extends StatefulWidget
{
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() {
    return _AuthenticationScreenState();
  }
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
{

  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPassController = TextEditingController();
  String email = '';
  String password = '';
  String userName = '';
  int userAge = 18;
  String userNumber = '';


  Future<String> _checkLogin() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userEmail = prefs.getString('userEmail');
    if (userEmail != null)
    {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userEmail: userEmail,),));
      return userEmail;
    }
    else
    {
      return '';
    }
  }

  void _loginUser() async
  {
    FocusManager.instance.primaryFocus?.unfocus();
    if(_formKey.currentState!.validate())
    {
      _formKey.currentState!.save();
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userEmail', email);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userEmail: email,),));
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful!")));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wrong Credentials Provided!")));
        }
        else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cant Login, Some Error Occurred")));
        }
      }
    }
  }

  void _signUpUser() async
  {
    FocusManager.instance.primaryFocus?.unfocus();
    if(_formKey.currentState!.validate())
    {
      _formKey.currentState!.save();
      try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await http.post(
          body: json.encode({
            "userEmail": email,
            "userName": userName,
            "userAge": userAge,
            "userNumber": userNumber
          }),
          Uri.parse(
              'https://wccgslv831.execute-api.ap-south-1.amazonaws.com/prod/create-user'),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signup Successful, Login to continue.")));
        setState(() {
          _regEmailController.clear();
          _regPassController.clear();
          password = '';
          email = '';
          _isLogin = true;
        });
      }
      on FirebaseAuthException catch (e){
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cant Signup, Some Error Occurred")));
      }
    }
  }

  void _handleForgotPassword() async{
    FocusManager.instance.primaryFocus?.unfocus();
    _formKey.currentState!.save();
    if(_regEmailController.value.text.isNotEmpty)
    {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: email
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Reset Link Mail Sent")));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Some Error Occurred!, Maybe email is not registered.")));
      }
    }
    else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Provide Email")));
    }
  }

  @override
  void initState() {
    _checkLogin();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: const Color.fromRGBO(80, 160, 171, 1),
        body: Center(
          child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        bottom: 5
                        , left: 15, right: 20, top: 30),
                    width: 300,
                    child: Image.asset("lib/assets/images/Book Nexus Logo.png"),
                  ),
                  const SizedBox(height: 30,),
                  Container(
                    padding: const EdgeInsets.only(right: 14, left: 14, bottom: 14, top: 0),
                    child: Card(
                      elevation: 7,
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 17,right: 17, top: 7, bottom: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(_isLogin) TextFormField(
                                  controller: _regEmailController,// form fields for login
                                  decoration: const InputDecoration(label: Text("Registered Email"), icon: Icon(Icons.mail_outline_rounded)),
                                  keyboardType: TextInputType.emailAddress,
                                  onSaved: (newValue) {
                                    email = newValue!;
                                  },
                                  validator: (value) {
                                    if(value == null || value.toString().trim().isEmpty || !(value.toString().contains("@")) || value.toString().length<8 || !(value.toString().contains(".")))
                                    {
                                      return "Invalid Email Address";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 5,),
                                if(_isLogin) TextFormField(
                                  controller: _regPassController,
                                  decoration: const InputDecoration(label: Text("Password"),icon: Icon(Icons.password_rounded)),
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  onSaved: (newValue) {
                                    password = newValue!;
                                  },
                                  validator: (value) {
                                    if(value == null || value.toString().isEmpty || value.toString().trim().length<6)
                                    {
                                      return "Password must be 6 character long";
                                    }
                                    return null;
                                  },

                                ),
                                if(!_isLogin) TextFormField(
                                    decoration: const InputDecoration(label: Text("Full Name"),icon: Icon(Icons.account_box_rounded)),
                                    keyboardType: TextInputType.name,
                                    onSaved: (newValue) {
                                      userName = newValue!;
                                    },
                                    validator: (value) {
                                      if(value == null || value.toString().isEmpty || !value.toString().trim().contains(" "))
                                      {
                                        return "Please enter valid full name";
                                      }
                                      return null;
                                    }
                                ),                                                              // form fields for signup
                                if(!_isLogin) TextFormField(
                                    decoration: const InputDecoration(label: Text("Contact Number"), prefix: Text("+91 "), icon: Icon(Icons.phone_enabled_rounded)),
                                    keyboardType: TextInputType.number,
                                    onSaved: (newValue) {
                                      userNumber = newValue!;
                                    },
                                    validator: (value) {
                                      if(value == null || value.toString().isEmpty || value.toString().trim().length<10)
                                      {
                                        return "Please enter valid contact number";
                                      }
                                      return null;
                                    }
                                ),
                                if(!_isLogin) TextFormField(
                                    decoration: const InputDecoration(label: Text("Age"),icon: Icon(Icons.numbers_rounded)),
                                    keyboardType: TextInputType.number,
                                    onSaved: (newValue) {
                                      userAge = int.parse(newValue!);
                                    },
                                    validator: (value) {
                                      if(value == null || value.toString().isEmpty || int.parse(value) <= 0 || int.parse(value) >=100)
                                      {
                                        return "Please enter valid Age";
                                      }
                                      return null;
                                    }
                                ),
                                if(!_isLogin) TextFormField(                                                                // form fields for login
                                  decoration: const InputDecoration(label: Text("Email"),icon: Icon(Icons.mail_outline_rounded)),
                                  keyboardType: TextInputType.emailAddress,
                                  onSaved: (newValue) {
                                    email = newValue!;
                                  },
                                  validator: (value) {
                                    if(value == null || value.toString().trim().isEmpty || !(value.toString().contains("@")) || value.toString().length<8 || !(value.toString().contains(".")))
                                    {
                                      return "Invalid Email Address";
                                    }
                                    return null;
                                  },
                                ),
                                if(!_isLogin) TextFormField(
                                  decoration: const InputDecoration(label: Text("Password"),icon: Icon(Icons.password_rounded)),
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: true,
                                  onSaved: (newValue) {
                                    password = newValue!;
                                  },
                                  validator: (value) {
                                    if(value == null || value.toString().isEmpty || value.toString().trim().length<6)
                                    {
                                      return "Password must be 6 character long";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30,),
                                ElevatedButton(
                                    onPressed: _isLogin ? _loginUser : _signUpUser,
                                    child: Text(_isLogin ? "Login":"Signup", style: TextStyle(color: Colors.blueAccent.shade400,))
                                ),
                                if (_isLogin) TextButton(
                                  onPressed: _handleForgotPassword,
                                  child: const Text("Forgot Password?"),
                                ),
                                TextButton(
                                  onPressed: (){
                                    setState(() {
                                      _formKey.currentState!.reset();
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin ? "Create Account":"Already Have Account"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ),
        )

    );
  }
}
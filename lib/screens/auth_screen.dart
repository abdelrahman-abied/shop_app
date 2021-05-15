import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/language/app_locale.dart';
import 'package:shop_app/models/http_exceptions.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/utilities/helper.dart';

class AuthScreen extends StatelessWidget {
  static const routesName = "/auth";

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(74, 112, 122, 1),
                    Color.fromRGBO(194, 200, 197, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 1]),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: deviceSize.width,
              height: deviceSize.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 94.0, vertical: 8.0),
                      margin: EdgeInsets.only(bottom: 20.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.blueGrey,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 8.0,
                              color: Colors.blueGrey[600],
                              offset: Offset(0, 3))
                        ],
                      ),
                      child: Text(
                        "Shop",
                        style: TextStyle(
                            color: Theme.of(context)
                                .accentTextTheme
                                .headline6
                                .color,
                            fontSize: 50.0,
                            fontFamily: 'Anton'),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthMode { Login, SignUp }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthMode authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var isLoading = false;
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  AnimationController _animController;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;
  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState.save();
    setState(() {
      isLoading = true;
    });
    try {
      if (authMode == AuthMode.Login) {
        // print(_authData['email'] + _authData['password']+'login');
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email'], _passwordController.text.toString());
      } else {
        //  print(_authData['email'] + _authData['password']+'signup');
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authData['email'], _authData['password']);
      }
    } on HttpException catch (e) {
      var errorMessage = 'Authentication Faild';
      if (e.message.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This Email Address is exist';
      } else if (e.message.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This Email Address is not valid';
      } else if (e.message.toString().contains('WEAK_PASSOWRD')) {
        errorMessage = 'This password is too weak';
      } else if (e.message.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'This Email Address is exist';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      const errorMessage = '';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (authMode == AuthMode.Login) {
      setState(() {
        authMode = AuthMode.SignUp;
      });
      _animController.forward();
    } else {
      setState(() {
        authMode = AuthMode.Login;
      });
      _animController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: Duration(microseconds: 300));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -0.15), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.fastOutSlowIn));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeIn));
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeIn,
        height: authMode == AuthMode.SignUp ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: authMode == AuthMode.SignUp ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-mail'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Inavalide Email';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _authData['email'] = val;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short';
                    }
                    return null;
                  },
                  onSaved: (val) {
                    print(val);
                    _authData['password'] = val;
                  },
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  constraints: BoxConstraints(
                    minHeight: authMode == AuthMode.SignUp ? 60 : 0,
                    maxHeight: authMode == AuthMode.SignUp ? 120 : 0,
                  ),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: authMode == AuthMode.SignUp,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: authMode == AuthMode.SignUp
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Password don\'t match';
                                }
                                return null;
                              }
                            : null,
                        onSaved: (val) {
                          _authData['password'] = val;
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                if (isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(authMode == AuthMode.Login
                        ? AppLocale.of(context).getString('login')
                        : AppLocale.of(context).getString('signUp')),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      onPrimary:
                          Theme.of(context).primaryTextTheme.headline6.color,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    _switchAuthMode();
                  },
                  style: TextButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  ),
                  child: Text(
                      '${authMode == AuthMode.SignUp ? getString(context, 'login') : getString(context, 'signUp')} Instead'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Row(children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                Text('An error occurred'),
              ]),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok"),
                )
              ],
            ));
  }
}

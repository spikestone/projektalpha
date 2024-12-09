import 'dart:math';
import 'main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pocketbase/pocketbase.dart';
import 'global.dart' as global;
class AuthWidget extends StatefulWidget {
  
   
  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  PocketBase pb = global.pb;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _iswrong = false;

  void _toggleFormMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void somethingwrong() {
    setState(() {
      _iswrong = !_iswrong;
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fehler'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Sie haben sich vertippt oder noch kein Account eröffnet, bitte registrieren sie sich! :-)'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Verstanden?'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _authenticate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await pb
            .collection('users')
            .authWithPassword(emailController.text, passwordController.text);
        Navigator.pushNamed(context, '/home');
        final authData = await pb.collection('users').authRefresh();
        if (kDebugMode) {
          print(authData);
        }
        // Login erfolgreich, weitere Verarbeitung hier
      } else {
        final body = <String, dynamic>{
          "password": passwordController.text,
          "passwordConfirm": passwordController.text,
          "email": emailController.text,
          "emailVisibility": true,
          "name": "anonym"
        };
        await pb.collection('users').create(body: body);
        await pb.collection('users').requestVerification(emailController.text);
        Navigator.pushNamed(context, '/home');
        // Registrierung erfolgreich, weitere Verarbeitung hier
      }
    } catch (e) {
      _showMyDialog();
      if (kDebugMode) {
        print(e);
      }

      // Fehlerbehandlung hier
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 24, 24, 24),
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Registrieren'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  constraints: new BoxConstraints(
                    maxWidth: 1000,
                    minWidth: 100,
                  ),
                  child: Card(
                    color: Color.fromARGB(255, 175, 175, 175),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'Email hier Schreiben',
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'Password hier schreiben',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 20),
                          _isLoading
                              ? SpinKitFadingCircle(color: Colors.deepPurple)
                              : ElevatedButton(
                                  onPressed: _authenticate,
                                  child: Text(
                                    _isLogin ? 'Login' : 'Registrieren',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 2, 2, 2)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: _toggleFormMode,
                            child: Text(
                                _isLogin
                                    ? "Don't have an account? Registrieren"
                                    : "Already have an account? Login",
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

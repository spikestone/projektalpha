import 'package:flutter/material.dart';
import 'package:spikeapp/messager.dart';
import 'package:spikeapp/utilits.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialisieren
  await Supabase.initialize(
    url: url, // Ersetze durch deine Supabase-URL
    anonKey: anon, // Ersetze durch deinen anon Key
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // Registrierung
  Future<void> signUp() async {
    setState(() {
      isLoading = true;
    });

    try {
      await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );
      showMessage('Registrierung erfolgreich! Bitte E-Mail bestätigen.');
    } on AuthException catch (error) {
      showError(error.message);
    } catch (e) {
      showError('Ein unbekannter Fehler ist aufgetreten');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Anmeldung
  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } on AuthException catch (error) {
      showError(error.message);
    } catch (e) {
      showError('Ein unbekannter Fehler ist aufgetreten');
    }

    setState(() {
      isLoading = false;
    });
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.red))),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supabase Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'E-Mail'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: signUp,
                        child: Text('Registrieren'),
                      ),
                      ElevatedButton(
                        onPressed: signIn,
                        child: Text('Anmelden'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Abmelden fehlgeschlagen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => signOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Messager()));
          }, child: Text("messager")),
          Center(
            child: user != null
                ? Text(
                    'Willkommen, ${user.email}!',
                    style: TextStyle(fontSize: 18),
                  )
                : Text(
                    'Keine Benutzerdaten verfügbar.',
                    style: TextStyle(fontSize: 18),
                  ),
          ),
        ],
      ),
    );
  }
}

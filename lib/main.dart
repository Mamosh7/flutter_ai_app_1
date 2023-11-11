import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'chat_screen.dart'; // Make sure this path is correct
import 'auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyC1ZIHoPC7Y7g9XXFMbB0Wn5R-DIskeNMo",
      authDomain: "ai-app-v1.firebaseapp.com",
      projectId: "ai-app-v1",
      storageBucket: "ai-app-v1.appspot.com",
      messagingSenderId: "131954199293",
      appId: "1:131954199293:web:3504cb90ff9262cdb94c94",
      measurementId: "G-16T4HP2DZJ",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Flutter Firebase Authentication',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.user != null) {
              return HomeScreen();
            }
            return LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/chat': (context) => ChatScreen(), // Ensure ChatScreen is defined
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}

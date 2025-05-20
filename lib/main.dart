import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/marquee_provider.dart';
import 'providers/food_items_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAo7FrUhnVROPMw_lhlQZ_YQVX1UURocRk",
      authDomain: "caribbeanqueenrestaurant-8043f.firebaseapp.com",
      projectId: "caribbeanqueenrestaurant-8043f",
      storageBucket: "caribbeanqueenrestaurant-8043f.firebasestorage.app",
      messagingSenderId: "340959568435",
      appId: "1:340959568435:web:542f2d4ed524fc72ac3946",
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarqueeProvider()),
        ChangeNotifierProvider(create: (_) => FoodItemsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Menu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}




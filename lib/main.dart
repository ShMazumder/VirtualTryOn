import 'package:flutter/material.dart';
import './screens/glasses_try_on_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(VirtualGlassesApp());
}

class VirtualGlassesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Glasses Try-On',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GlassesTryOnScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:googlemapss/widgets/custom_camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CustomCamera(),
    );
  }
}

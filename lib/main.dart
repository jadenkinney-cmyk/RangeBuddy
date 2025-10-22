import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const RangeBuddyApp());
}

class RangeBuddyApp extends StatelessWidget {
  const RangeBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RangeBuddy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HoleGeneratorScreen(),
    );
  }
}

class HoleGeneratorScreen extends StatefulWidget {
  const HoleGeneratorScreen({super.key});

  @override
  State<HoleGeneratorScreen> createState() => _HoleGeneratorScreenState();
}

class _HoleGeneratorScreenState extends State<HoleGeneratorScreen> {
  String yardage = '';
  String par = '';
  String direction = '';
  String greenDiameter = '';

  void generateHole() {
    final random = Random();
    setState(() {
      yardage = (130 + random.nextInt(421)).toString(); // 130-550 yards
      par = (3 + random.nextInt(3)).toString(); // Par 3-5
      direction = ['Straight', 'Dogleg Left', 'Dogleg Right'][random.nextInt(3)];
      greenDiameter = (10 + random.nextInt(11)).toString(); // 10-20 yards
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RangeBuddy'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              yardage.isEmpty ? 'Press Generate to start!' : 'Yardage: $yardage yards',
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            if (yardage.isNotEmpty) ...[
              Text('Par: $par', style: const TextStyle(fontSize: 18)),
              Text('Direction: $direction', style: const TextStyle(fontSize: 18)),
              Text('Green Diameter: $greenDiameter yards', style: const TextStyle(fontSize: 18)),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: generateHole,
              icon: const Icon(Icons.golf_course),
              label: const Text('Generate Hole'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
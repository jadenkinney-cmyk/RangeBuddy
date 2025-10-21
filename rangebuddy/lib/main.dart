import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const GolfPracticeApp());
}

class GolfPracticeApp extends StatelessWidget {
  const GolfPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golf Practice App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 18),
        ),
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

  final Random random = Random();

  void generateHole() {
    // Generate yardage: 130-550 inclusive
    int newYardage = random.nextInt(421) + 130; // 550 - 130 + 1 = 421

    // Determine par based on yardage
    String newPar = '';
    if (newYardage >= 130 && newYardage <= 200) {
      newPar = '3';
    } else if (newYardage >= 201 && newYardage <= 239) {
      newPar = random.nextBool() ? '3' : '4';
    } else if (newYardage >= 240 && newYardage <= 439) {
      newPar = '4';
    } else if (newYardage >= 440 && newYardage <= 459) {
      newPar = random.nextBool() ? '4' : '5';
    } else if (newYardage >= 460 && newYardage <= 550) {
      newPar = '5';
    }

    // Generate direction
    List<String> directions = ['dogleg Left', 'Straight', 'dogleg Right'];
    String newDirection = directions[random.nextInt(directions.length)];

    // Generate green diameter: 10-20 inclusive
    int newGreenDiameter = random.nextInt(11) + 10;

    setState(() {
      yardage = '$newYardage yards';
      par = 'Par $newPar';
      direction = newDirection;
      greenDiameter = '$newGreenDiameter yards';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golf Practice App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (yardage.isEmpty)
                const Text(
                  'Press Generate to start!',
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                ),
              if (yardage.isNotEmpty) ...[
                Text('Yardage: $yardage', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text(par, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Direction: $direction', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Text('Green Diameter: $greenDiameter', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: generateHole,
        label: const Text('Generate Hole'),
        icon: const Icon(Icons.golf_course),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
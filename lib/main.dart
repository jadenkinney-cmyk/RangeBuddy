import 'dart:math';
import 'package:flutter/material.dart';

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
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green[50],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 24.0), // Bigger font for main text
          bodyMedium: TextStyle(fontSize: 20.0),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green[700],
          titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 24.0, color: Colors.white), // Bigger font in dark mode
          bodyMedium: TextStyle(fontSize: 20.0, color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green[900],
          titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system, // System dark mode toggle
      home: const MyHomePage(),
    );
  }
}

class HoleInfo {
  final int yardage;
  final int par;
  final String direction;
  final int greenDiameter;
  final bool fairwayInRegulation;
  final bool greenInRegulation;

  HoleInfo({
    required this.yardage,
    required this.par,
    required this.direction,
    required this.greenDiameter,
    this.fairwayInRegulation = false,
    this.greenInRegulation = false,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _holeInfo = 'Press Generate to start!';
  List<HoleInfo> _holeHistory = [];
  bool _showQuestions = false;
  bool _fairwayInRegulation = false;
  bool _greenInRegulation = false;

  void _generateHole() {
    if (_showQuestions && _holeHistory.isNotEmpty) {
      setState(() {
        _holeHistory[_holeHistory.length - 1] = HoleInfo(
          yardage: _holeHistory[_holeHistory.length - 1].yardage,
          par: _holeHistory[_holeHistory.length - 1].par,
          direction: _holeHistory[_holeHistory.length - 1].direction,
          greenDiameter: _holeHistory[_holeHistory.length - 1].greenDiameter,
          fairwayInRegulation: _fairwayInRegulation,
          greenInRegulation: _greenInRegulation,
        );
        _showQuestions = false;
      });
      _fairwayInRegulation = false;
      _greenInRegulation = false;
    }

    final random = Random();
    int yardage = random.nextInt(451) + 100; // 100-550 yards
    int par;
    if (yardage <= 225) {
      par = 3;
    } else if (yardage <= 250) {
      par = random.nextBool() ? 3 : 4;
    } else if (yardage <= 425) {
      par = 4;
    } else if (yardage <= 475) {
      par = random.nextBool() ? 4 : 5;
    } else {
      par = 5;
    }
    List<String> directions = ['Straight', 'Dogleg Left', 'Dogleg Right', 'Double Dogleg'];
    String direction = directions[random.nextInt(directions.length)];
    int greenDiameter = random.nextInt(21) + 10; // 10-30 yards

    setState(() {
      _holeInfo = 'Yardage: $yardage yards\nDirection: $direction\nPar: $par\nGreen Diameter: $greenDiameter yards';
      _holeHistory.add(HoleInfo(yardage: yardage, par: par, direction: direction, greenDiameter: greenDiameter));
      if (_holeHistory.length > 10) {
        _holeHistory = _holeHistory.sublist(_holeHistory.length - 10);
      }
      if (_holeHistory.length > 1) {
        _showQuestions = true;
      }
    });
  }

  void _updateFairway(bool value) {
    setState(() {
      _fairwayInRegulation = value;
    });
  }

  void _updateGreen(bool value) {
    setState(() {
      _greenInRegulation = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RangeBuddy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HoleHistoryPage(holeHistory: _holeHistory)),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HoleHistoryPage(holeHistory: _holeHistory)),
            );
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _holeInfo,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (_showQuestions) ...[
                  const Text(
                    'Fairway in regulation?',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green, size: 48),
                        onPressed: () => _updateFairway(true),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red, size: 48),
                        onPressed: () => _updateFairway(false),
                      ),
                    ],
                  ),
                  const Text(
                    'Green in regulation?',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green, size: 48),
                        onPressed: () => _updateGreen(true),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red, size: 48),
                        onPressed: () => _updateGreen(false),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateHole,
        tooltip: 'Generate Hole',
        child: const Icon(Icons.golf_course),
      ),
    );
  }
}

class HoleHistoryPage extends StatelessWidget {
  final List<HoleInfo> holeHistory;

  const HoleHistoryPage({super.key, required this.holeHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Holes'),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          }
        },
        child: ListView.builder(
          itemCount: holeHistory.length,
          itemBuilder: (context, index) {
            final hole = holeHistory[index];
            return ListTile(
              title: Text('Hole ${index + 1}'),
              subtitle: Text(
                'Yardage: ${hole.yardage} yards\nDirection: ${hole.direction}\nPar: ${hole.par}\nGreen Diameter: ${hole.greenDiameter} yards\nFairway in regulation: ${hole.fairwayInRegulation ? 'Yes' : 'No'}\nGreen in regulation: ${hole.greenInRegulation ? 'Yes' : 'No'}',
              ),
            );
          },
        ),
      ),
    );
  }
}
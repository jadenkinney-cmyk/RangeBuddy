import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 24.0),
          bodyMedium: TextStyle(fontSize: 20.0),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 56, 142, 60),
          titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 24.0, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 20.0, color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 27, 94, 32),
          titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RangeBuddy',
              style: TextStyle(fontSize: 48.0, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              ),
              child: const Text('Start Round', style: TextStyle(fontSize: 24.0)),
            ),
          ],
        ),
      ),
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

class RoundInfo {
  final String date;
  final String time;
  final double fairwayPercent;
  final double greenPercent;

  RoundInfo({
    required this.date,
    required this.time,
    required this.fairwayPercent,
    required this.greenPercent,
  });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _holeInfo = 'Press Generate to start!';
  List<HoleInfo> _holeHistory = [];
  List<RoundInfo> _previousRounds = [];
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

    if (_holeHistory.length >= 18) {
      _endRound();
      return;
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
    List<String> directions = ['Straight', 'Dogleg Left', 'Dogleg Right'];
    String direction = directions[random.nextInt(directions.length)];
    int greenDiameter = random.nextInt(21) + 10; // 10-30 yards

    setState(() {
      _holeInfo = 'Yardage: $yardage yards\nDirection: $direction\nPar: $par\nGreen Diameter: $greenDiameter yards';
      _holeHistory.add(HoleInfo(yardage: yardage, par: par, direction: direction, greenDiameter: greenDiameter));
      if (_holeHistory.length > 18) {
        _holeHistory = _holeHistory.sublist(_holeHistory.length - 18);
      }
      if (_holeHistory.length > 1) {
        _showQuestions = true;
      }
    });
  }

  void _endRound() {
    double fairwayPercent = _holeHistory.isEmpty
        ? 0.0
        : (_holeHistory.where((hole) => hole.fairwayInRegulation).length / _holeHistory.length) * 100;
    double greenPercent = _holeHistory.isEmpty
        ? 0.0
        : (_holeHistory.where((hole) => hole.greenInRegulation).length / _holeHistory.length) * 100;
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String time = DateFormat('HH:mm').format(DateTime.now());

    setState(() {
      _previousRounds.add(RoundInfo(
        date: date,
        time: time,
        fairwayPercent: fairwayPercent,
        greenPercent: greenPercent,
      ));
      if (_previousRounds.length > 10) {
        _previousRounds = _previousRounds.sublist(_previousRounds.length - 10);
      }
      _holeHistory = [];
      _holeInfo = 'Press Generate to start!';
      _showQuestions = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Round Recap'),
        content: Text('Fairways Hit: ${fairwayPercent.toStringAsFixed(2)}%\nGreens Hit: ${greenPercent.toStringAsFixed(2)}%'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
          IconButton(
            icon: const Icon(Icons.scoreboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PreviousRoundsPage(previousRounds: _previousRounds)),
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
          } else if (details.primaryVelocity! > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PreviousRoundsPage(previousRounds: _previousRounds)),
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
                  Text(
                    'Fairway in regulation?',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: _fairwayInRegulation ? 1.0 : 0.5,
                        child: IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                          onPressed: () => _updateFairway(true),
                        ),
                      ),
                      Opacity(
                        opacity: _fairwayInRegulation ? 0.5 : 1.0,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 48),
                          onPressed: () => _updateFairway(false),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Green in regulation?',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: _greenInRegulation ? 1.0 : 0.5,
                        child: IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                          onPressed: () => _updateGreen(true),
                        ),
                      ),
                      Opacity(
                        opacity: _greenInRegulation ? 0.5 : 1.0,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 48),
                          onPressed: () => _updateGreen(false),
                        ),
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
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: _endRound,
              child: const Text('End Round', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
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
        title: const Text('Current Round'),
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
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Text('Hole ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Yardage: ${hole.yardage} yards\nDirection: ${hole.direction}\nPar: ${hole.par}\nGreen Diameter: ${hole.greenDiameter} yards\nFairway in regulation: ${hole.fairwayInRegulation ? 'Yes' : 'No'}\nGreen in regulation: ${hole.greenInRegulation ? 'Yes' : 'No'}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PreviousRoundsPage extends StatelessWidget {
  final List<RoundInfo> previousRounds;

  const PreviousRoundsPage({super.key, required this.previousRounds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Rounds'),
      ),
      body: ListView.builder(
        itemCount: previousRounds.length,
        itemBuilder: (context, index) {
          final round = previousRounds[index];
          return Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text('Round ${index + 1} - ${round.date} at ${round.time}'),
              subtitle: Text(
                'Fairways Hit: ${round.fairwayPercent.toStringAsFixed(2)}%\nGreens Hit: ${round.greenPercent.toStringAsFixed(2)}%',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ← REQUIRED FOR PERSISTENCE
import 'package:intl/intl.dart';

void main() => runApp(const RangeBuddyApp());

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
          bodyLarge: TextStyle(fontSize: 24.0),
          bodyMedium: TextStyle(fontSize: 20.0),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 24.0, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 20.0, color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
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
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyHomePage())),
              style: ElevatedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text('Start Round', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DistanceBuddyPage())),
              style: ElevatedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text('DistanceBuddy', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}

// === DATA MODELS ===
class HoleInfo {
  final int yardage, par, greenDiameter;
  final String direction;
  final bool fairwayInRegulation, greenInRegulation;
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
  final String date, time;
  final double fairwayPercent, greenPercent;
  RoundInfo({required this.date, required this.time, required this.fairwayPercent, required this.greenPercent});
  factory RoundInfo.fromJson(Map<String, dynamic> json) => RoundInfo(
        date: json['date'],
        time: json['time'],
        fairwayPercent: json['fairwayPercent'],
        greenPercent: json['greenPercent'],
      );
  Map<String, dynamic> toJson() => {'date': date, 'time': time, 'fairwayPercent': fairwayPercent, 'greenPercent': greenPercent};
}

// === MAIN ROUND PAGE ===
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // State
  Widget _directionArrow = const SizedBox.shrink();
  String _holeText = '';
  List<HoleInfo> _holeHistory = [];
  List<RoundInfo> _previousRounds = [];
  bool _showGIRFIR = false;
  bool _gir = false, _fir = false;

  // Filters
  bool _par3 = true, _par4 = true, _par5 = true;
  bool _left = true, _right = true, _straight = true;

  // Wisdom
  final List<String> _quotes = [
    "The harder you practice, the luckier you get. — Gary Player",
    "There are no shortcuts on the quest for perfection. — Ben Hogan",
    "Practice does not make perfect. Only perfect practice makes perfect. — Vince Lombardi",
    "Golf is deceptively simple and endlessly complicated. — Arnold Palmer",
    "Success is the sum of small efforts, repeated day in and day out. — Robert Collier",
    "Every shot is a lesson. Every swing is a teacher. — Unknown",
    "Repetition is the mother of skill. — Tony Robbins",
    "The expert in anything was once a beginner. — Helen Hayes",
    "Practice puts brains in your muscles. — Sam Snead",
    "Don’t practice until you get it right. Practice until you can’t get it wrong. — Unknown",
    "You don’t have to be great to start, but you have to start to be great. — Zig Ziglar",
    "The secret of getting ahead is getting started. — Mark Twain",
    "Progress, not perfection. — Unknown",
    "Every pro was once an amateur. Every expert was once a beginner. — Unknown",
    "What you do today can improve all your tomorrows. — Ralph Marston",
    "Every practice swing is a step toward perfection. — Unknown",
    "The path to mastery is paved with repetition. — Unknown",
    "Practice is the price of proficiency. — Unknown",
    "Grit is the thread that weaves success. — Unknown",
    "Practice is the whisper of improvement. — Unknown",
  ];

  final List<String> _prompts = [
    "Tap to start swingin'",
    "Your practice tee awaits.",
    "Tap to dial in the distances.",
    "Tap to begin the session.",
    "Let’s get after it.",
    "Tap to tee up.",
    "Let's get the range rocking.",
    "Swing away—tap to begin.",
  ];

  late String _quote, _prompt;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pickWisdom();
  }

  void _pickWisdom() {
    final r = Random();
    _quote = _quotes[r.nextInt(_quotes.length)];
    _prompt = _prompts[r.nextInt(_prompts.length)];
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // Load previous rounds
    final roundsJson = prefs.getString('previousRounds');
    if (roundsJson != null) {
      _previousRounds = (jsonDecode(roundsJson) as List).map((e) => RoundInfo.fromJson(e)).toList();
    }
    // Load filters
    _par3 = prefs.getBool('par3') ?? true;
    _par4 = prefs.getBool('par4') ?? true;
    _par5 = prefs.getBool('par5') ?? true;
    _left = prefs.getBool('left') ?? true;
    _right = prefs.getBool('right') ?? true;
    _straight = prefs.getBool('straight') ?? true;
    setState(() {});
  }

  Future<void> _saveRounds() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('previousRounds', jsonEncode(_previousRounds.map((r) => r.toJson()).toList()));
  }

  Future<void> _saveFilters() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('par3', _par3);
    prefs.setBool('par4', _par4);
    prefs.setBool('par5', _par5);
    prefs.setBool('left', _left);
    prefs.setBool('right', _right);
    prefs.setBool('straight', _straight);
  }

  void _generateHole() {
    // Save GIR/FIR from previous hole
    if (_showGIRFIR && _holeHistory.isNotEmpty) {
      final last = _holeHistory.last;
      _holeHistory[_holeHistory.length - 1] = HoleInfo(
        yardage: last.yardage,
        par: last.par,
        direction: last.direction,
        greenDiameter: last.greenDiameter,
        fairwayInRegulation: _fir,
        greenInRegulation: _gir,
      );
    }

    if (_holeHistory.length >= 18) {
      _endRound();
      return;
    }

    final r = Random();
    int yardage = r.nextInt(451) + 100;

    // Filter PAR
    int par;
    do {
      if (yardage <= 225) par = 3;
      else if (yardage <= 250) par = r.nextBool() ? 3 : 4;
      else if (yardage <= 425) par = 4;
      else if (yardage <= 475) par = r.nextBool() ? 4 : 5;
      else par = 5;
    } while ((par == 3 && !_par3) || (par == 4 && !_par4) || (par == 5 && !_par5));

    // Filter DIRECTION
    List<String> dirs = [];
    if (_straight) dirs.add('Straight');
    if (_left) dirs.add('Dogleg Left');
    if (_right) dirs.add('Dogleg Right');
    if (dirs.isEmpty) dirs.add('Straight');
    String direction = dirs[r.nextInt(dirs.length)];

    int greenDia = r.nextInt(21) + 10;

    // Arrow
    late IconData icon;
    double rot = 0;
    if (direction == 'Straight') icon = Icons.arrow_upward;
    else if (direction == 'Dogleg Left') { icon = Icons.turn_left; rot = -0.3; }
    else { icon = Icons.turn_right; rot = 0.3; }

    setState(() {
      _directionArrow = Transform.rotate(angle: rot, child: Icon(icon, size: 100, color: Colors.green[700]));
      _holeText = 'Yardage: $yardage yards\nPar: $par\nGreen Diameter: $greenDia yards';
      _holeHistory.add(HoleInfo(yardage: yardage, par: par, direction: direction, greenDiameter: greenDia));
      _showGIRFIR = true;
      _gir = false;
      _fir = false;
    });
  }

  void _endRound() {
    final fairwayPct = _holeHistory.isEmpty ? 0.0 : (_holeHistory.where((h) => h.fairwayInRegulation).length / _holeHistory.length) * 100;
    final greenPct = _holeHistory.isEmpty ? 0.0 : (_holeHistory.where((h) => h.greenInRegulation).length / _holeHistory.length) * 100;
    final now = DateTime.now();
    _previousRounds.add(RoundInfo(date: DateFormat('yyyy-MM-dd').format(now), time: DateFormat('HH:mm').format(now), fairwayPercent: fairwayPct, greenPercent: greenPct));
    if (_previousRounds.length > 10) _previousRounds.removeAt(0);
    _saveRounds();

    setState(() {
      _holeHistory.clear();
      _holeText = '';
      _directionArrow = const SizedBox.shrink();
      _showGIRFIR = false;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Round Recap'),
        content: Text('Fairways: ${fairwayPct.toStringAsFixed(1)}%\nGreens: ${greenPct.toStringAsFixed(1)}%'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          par3: _par3, par4: _par4, par5: _par5,
          left: _left, right: _right, straight: _straight,
          onSave: (p3, p4, p5, l, r, s) {
            setState(() {
              _par3 = p3; _par4 = p4; _par5 = p5;
              _left = l; _right = r; _straight = s;
            });
            _saveFilters();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RangeBuddy'),
        leading: IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings),
        actions: [
          IconButton(icon: const Icon(Icons.scoreboard), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HoleHistoryPage(holeHistory: _holeHistory)))),
          IconButton(icon: const Icon(Icons.history), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PreviousRoundsPage(previousRounds: _previousRounds)))),
        ],
      ),
      body: GestureDetector(
        onTap: () => _holeHistory.isEmpty ? _generateHole() : null,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_holeHistory.isEmpty) ...[
                  Text(_quote, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 20), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(_prompt, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700], fontSize: 18)),
                ] else ...[
                  _directionArrow,
                  const SizedBox(height: 16),
                  Text(_holeText, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                  if (_showGIRFIR) ...[
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOvalButton('GIR', _gir, () => setState(() => _gir = !_gir)),
                        const SizedBox(width: 12),
                        _buildOvalButton('FIR', _fir, () => setState(() => _fir = !_fir)),
                        const SizedBox(width: 20),
                        FloatingActionButton(onPressed: _generateHole, child: const Icon(Icons.golf_course)),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _holeHistory.isNotEmpty && !_showGIRFIR
          ? ElevatedButton(
              onPressed: _endRound,
              style: ElevatedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: const Text('End Round', style: TextStyle(color: Colors.red)),
            )
          : null,
    );
  }

  Widget _buildOvalButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text(' | '),
            Icon(Icons.check_circle, color: selected ? Colors.green : Colors.grey, size: 28),
            const SizedBox(width: 4),
            Icon(Icons.cancel, color: !selected ? Colors.red : Colors.grey, size: 28),
          ],
        ),
      ),
    );
  }
}

// === SETTINGS PAGE ===
class SettingsPage extends StatefulWidget {
  final bool par3, par4, par5, left, right, straight;
  final Function(bool, bool, bool, bool, bool, bool) onSave;
  const SettingsPage({super.key, required this.par3, required this.par4, required this.par5, required this.left, required this.right, required this.straight, required this.onSave});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool p3, p4, p5, l, r, s;

  @override
  void initState() {
    super.initState();
    p3 = widget.par3; p4 = widget.par4; p5 = widget.par5;
    l = widget.left; r = widget.right; s = widget.straight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PAR:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(title: const Text('Par 3'), value: p3, onChanged: (v) => setState(() => p3 = v)),
            SwitchListTile(title: const Text('Par 4'), value: p4, onChanged: (v) => setState(() => p4 = v)),
            SwitchListTile(title: const Text('Par 5'), value: p5, onChanged: (v) => setState(() => p5 = v)),
            const SizedBox(height: 20),
            const Text('DIRECTION:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SwitchListTile(title: const Text('Left'), value: l, onChanged: (v) => setState(() => l = v)),
            SwitchListTile(title: const Text('Right'), value: r, onChanged: (v) => setState(() => r = v)),
            SwitchListTile(title: const Text('Straight'), value: s, onChanged: (v) => setState(() => s = v)),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () { widget.onSave(p3, p4, p5, l, r, s); Navigator.pop(context); }, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}

// === HISTORY PAGES ===
class HoleHistoryPage extends StatelessWidget {
  final List<HoleInfo> holeHistory;
  const HoleHistoryPage({super.key, required this.holeHistory});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Current Round')),
    body: ListView.builder(
      itemCount: holeHistory.length,
      itemBuilder: (_, i) {
        final h = holeHistory[i];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('Hole ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Yardage: ${h.yardage}\nDirection: ${h.direction}\nPar: ${h.par}\nGreen: ${h.greenDiameter} yd\nFIR: ${h.fairwayInRegulation ? "Yes" : "No"}\nGIR: ${h.greenInRegulation ? "Yes" : "No"}'),
          ),
        );
      },
    ),
  );
}

class PreviousRoundsPage extends StatelessWidget {
  final List<RoundInfo> previousRounds;
  const PreviousRoundsPage({super.key, required this.previousRounds});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Previous Rounds')),
    body: ListView.builder(
      itemCount: previousRounds.length,
      itemBuilder: (_, i) {
        final r = previousRounds[i];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('Round ${i + 1} – ${r.date} @ ${r.time}'),
            subtitle: Text('FIR: ${r.fairwayPercent.toStringAsFixed(1)}%\nGIR: ${r.greenPercent.toStringAsFixed(1)}%'),
          ),
        );
      },
    ),
  );
}

// === DISTANCE BUDDY ===
class DistanceBuddyPage extends StatefulWidget {
  const DistanceBuddyPage({super.key});
  @override
  State<DistanceBuddyPage> createState() => _DistanceBuddyPageState();
}

class _DistanceBuddyPageState extends State<DistanceBuddyPage> {
  final clubs = ['Driver','3W','5W','7W','Hybrid','3I','4I','5I','6I','7I','8I','9I','PW','GW','SW','LW'];
  final Map<String, List<double>> data = {};
  final Map<String, TextEditingController> ctrl = {};
  final Map<String, double> avg = {};

  @override
  void initState() {
    super.initState();
    for (var c in clubs) { data[c] = []; ctrl[c] = TextEditingController(); avg[c] = 0; }
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    for (var c in clubs) {
      final s = p.getString(c);
      if (s != null) data[c] = (jsonDecode(s) as List).cast<double>();
      _calc(c);
    }
    setState(() {});
  }

  void _calc(String c) => avg[c] = data[c]!.isEmpty ? 0 : data[c]!.reduce((a,b)=>a+b)/data[c]!.length;

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    for (var c in clubs) p.setString(c, jsonEncode(data[c]));
  }

  void _log() {
    for (var c in clubs) {
      final t = ctrl[c]!.text.trim();
      if (t.isEmpty) continue;
      final nums = t.split(',').map((e) => double.tryParse(e.trim())??0).where((d)=>d>0).toList();
      data[c]!.addAll(nums);
      if (data[c]!.length > 100) data[c]!.removeRange(0, data[c]!.length - 100);
      _calc(c);
      ctrl[c]!.clear();
    }
    _save();
    setState(() {});
  }

  void _clear() {
    bool yes = false;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Clear All?'),
          content: const Text('This will erase all stored distances.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
            TextButton(
              onPressed: () {
                if (yes) {
                  for (var c in clubs) { data[c] = []; avg[c] = 0; }
                  _save();
                  Navigator.pop(ctx);
                  this.setState(() {});
                } else {
                  setState(() => yes = true);
                }
              },
              child: Text(yes ? 'Confirm' : 'Yes', style: TextStyle(color: yes ? Colors.red : null)),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('DistanceBuddy'), actions: [IconButton(icon: const Icon(Icons.delete_forever), onPressed: _clear)]),
    body: ListView.builder(
      itemCount: clubs.length,
      itemBuilder: (_, i) {
        final c = clubs[i];
        return Card(
          child: ListTile(
            title: Text(c),
            subtitle: TextField(controller: ctrl[c], keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '80,95,65,...')),
            trailing: Text('${avg[c]!.toStringAsFixed(0)} yd', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton(onPressed: _log, child: const Text('LOG')),
  );
}
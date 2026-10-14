
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const FocusPro());
}

class FocusPro extends StatelessWidget {
  const FocusPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7186FF),
          surface: Color(0xFF161B22),
        ),
      ),
      home: const StudyHome(),
    );
  }
}

class StudyHome extends StatefulWidget {
  const StudyHome({super.key});

  @override
  State<StudyHome> createState() => _StudyHomeState();
}

class _StudyHomeState extends State<StudyHome> {
  int studyMinutes = 25;
  int breakMinutes = 5;
  int seconds = 25 * 60;
  int sessions = 0;
  int totalMinutes = 0;
  bool isBreak = false;
  Timer? timer;

  final List<Map<String, dynamic>> tasks = [];
  final TextEditingController taskController =
      TextEditingController();

  String get clock {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
      setState(() {});
      return;
    }

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
        timer = null;

        if (!isBreak) {
          sessions++;
          totalMinutes += studyMinutes;
        }

        isBreak = !isBreak;
        seconds = (isBreak ? breakMinutes : studyMinutes) * 60;
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBreak
                ? 'أحسنت! حان وقت الراحة ☕'
                : 'انتهت الراحة، لنكمل المذاكرة 💪'),
          ),
        );
      }
    });

    setState(() {});
  }

  void resetTimer() {
    timer?.cancel();
    timer = null;
    setState(() {
      seconds = (isBreak ? breakMinutes : studyMinutes) * 60;
    });
  }

  void switchMode() {
    timer?.cancel();
    timer = null;
    setState(() {
      isBreak = !isBreak;
      seconds = (isBreak ? breakMinutes : studyMinutes) * 60;
    });
  }

  void addTask() {
    final name = taskController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      tasks.add({
        'name': name,
        'done': false,
      });
      taskController.clear();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    taskController.dispose();
    super.dispose();
  }

  Widget panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((t) => t['done'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Focus Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF161B22),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'خطّط لمذاكرتك وحقق هدفك 🎯',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),

            panel(
              child: Column(
                children: [
                  Text(
                    isBreak ? '☕ وقت الراحة' : '📚 وقت التركيز',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    clock,
                    style: const TextStyle(
                      fontSize:  sixty,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF91A4FF),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: seconds /
                        ((isBreak ? breakMinutes : studyMinutes) * 60),
                    minHeight: 7,
                    backgroundColor: Colors.white12,
                    color: const Color(0xFF7186FF),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: startTimer,
                        child: Text(timer == null ? 'ابدأ' : 'إيقاف مؤقت'),
                      ),
                      ElevatedButton(
                        onPressed: resetTimer,
                        child: const Text('إعادة'),
                      ),
                      ElevatedButton(
                        onPressed: switchMode,
                        child: const Text('تبديل الوضع'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text('جلسات مكتملة: $sessions'),
                  Text('وقت المذاكرة: $totalMinutes دقيقة'),
                ],
              ),
            ),

            panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📝 مهام المذاكرة',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: taskController,
                    onSubmitted: (_) => addTask(),
                    decoration: InputDecoration(
                      hintText: 'اكتب اسم الدرس...',
                      filled: true,
                      fillColor: const Color(0xFF0D1117),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: addTask,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة مهمة'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (tasks.isEmpty)
                    const Text(
                      'أضف أول درس عشان تبدأ خطتك.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ...List.generate(tasks.length, (i) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: tasks[i]['done'] as bool,
                      title: Text(
                        tasks[i]['name'] as String,
                        style: TextStyle(
                          decoration: tasks[i]['done']
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          tasks[i]['done'] = value ?? false;
                        });
                      },
                      secondary: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          setState(() => tasks.removeAt(i));
                        },
                      ),
                    );
                  }),
                  const Divider(),
                  Text('المهام المكتملة: $completed / ${tasks.length}'),
                ],
              ),
            ),

            const Center(
              child: Text(
                'كل يوم خطوة نحو التفوق ✨',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const double sixty = 60;
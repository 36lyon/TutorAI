import 'package:flutter/material.dart';

import 'study_plan.dart';

class StudyPlanScreen extends StatelessWidget {
  final StudyPlanStore store;

  const StudyPlanScreen({
    super.key,
    required this.store,
  });

  void _openCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CreateStudyPlanScreen(store: store),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Plan'),
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final plans = store.plans;

          if (plans.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No study plan yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a study plan to organize your subjects, study days, and daily study time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _openCreate(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Study Plan'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              const Text(
                'Your Study Plans',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...plans.map(
                (plan) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _StudyPlanDetailsScreen(
                            store: store,
                            planId: plan.id,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      child: const Icon(Icons.menu_book_outlined),
                    ),
                    title: Text(
                      plan.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${plan.examType} • ${plan.level}\n'
                        '${plan.subjects.length} subject(s) • '
                        '${plan.minutesPerDay} min/day\n'
                        '${_formatDate(plan.startDate)} → ${_formatDate(plan.targetDate)}',
                      ),
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}



class _StudyPlanDetailsScreen extends StatelessWidget {
  final StudyPlanStore store;
  final String planId;

  const _StudyPlanDetailsScreen({
    required this.store,
    required this.planId,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        StudyPlan? plan;

        for (final StudyPlan item in store.plans) {
          if (item.id == planId) {
            plan = item;
            break;
          }
        }

        if (plan == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Study Plan')),
            body: const Center(child: Text('Study plan not found.')),
          );
        }

        final StudyPlan currentPlan = plan;

        return Scaffold(
          appBar: AppBar(title: Text(currentPlan.title)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentPlan.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('${currentPlan.examType} • ${currentPlan.level}'),
                      const SizedBox(height: 6),
                      Text('Subjects: ${currentPlan.subjects.join(', ')}'),
                      const SizedBox(height: 6),
                      Text('Study time: ${currentPlan.minutesPerDay} min/day'),
                      const SizedBox(height: 6),
                      Text('Period: ${_formatDate(currentPlan.startDate)} → ${_formatDate(currentPlan.targetDate)}'),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: currentPlan.completionRate),
                      const SizedBox(height: 8),
                      Text('${currentPlan.completedTasks} of ${currentPlan.totalTasks} tasks completed'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Study Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (currentPlan.tasks.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No study tasks were generated.'),
                  ),
                )
              else
                ...currentPlan.tasks.map(
                  (task) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      value: task.completed,
                      onChanged: (_) {
                        store.toggleTask(planId: currentPlan.id, taskId: task.id);
                      },
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text('${task.subject} • ${_formatDate(task.date)} • ${task.durationMinutes} min'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CreateStudyPlanScreen extends StatefulWidget {
  final StudyPlanStore store;

  const _CreateStudyPlanScreen({
    super.key,
    required this.store,
  });

  @override
  State<_CreateStudyPlanScreen> createState() => _CreateStudyPlanScreenState();
}

class _CreateStudyPlanScreenState extends State<_CreateStudyPlanScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController =
      TextEditingController(text: 'My Study Plan');

  String _examType = 'WAEC';
  String _level = 'SSS';
  DateTime _startDate = DateTime.now();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  int _minutesPerDay = 60;

  final Set<String> _selectedSubjects = <String>{
    'Mathematics',
    'English',
  };

  final Set<int> _selectedStudyDays = <int>{
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  };

  static const List<String> _examTypes = <String>[
    'WAEC',
    'NECO',
    'JAMB',
    'Post-UTME',
    'School Exam',
    'General Study',
  ];

  static const List<String> _levels = <String>[
    'Primary',
    'JSS',
    'SSS',
    'University',
  ];

  static const List<String> _subjects = <String>[
    'Mathematics',
    'English',
    'Biology',
    'Chemistry',
    'Physics',
    'Economics',
    'Government',
    'History',
    'Geography',
    'Literature',
    'Computer Science',
  ];

  static const List<Map<String, dynamic>> _weekdays =
      <Map<String, dynamic>>[
    <String, dynamic>{'name': 'Mon', 'value': DateTime.monday},
    <String, dynamic>{'name': 'Tue', 'value': DateTime.tuesday},
    <String, dynamic>{'name': 'Wed', 'value': DateTime.wednesday},
    <String, dynamic>{'name': 'Thu', 'value': DateTime.thursday},
    <String, dynamic>{'name': 'Fri', 'value': DateTime.friday},
    <String, dynamic>{'name': 'Sat', 'value': DateTime.saturday},
    <String, dynamic>{'name': 'Sun', 'value': DateTime.sunday},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _startDate = picked;

      if (!_targetDate.isAfter(_startDate)) {
        _targetDate = _startDate.add(const Duration(days: 30));
      }
    });
  }

  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _targetDate.isAfter(_startDate) ? _targetDate : _startDate,
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: _startDate.add(const Duration(days: 365)),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _targetDate = picked;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min/day';
    }

    final int hours = minutes ~/ 60;
    final int remaining = minutes % 60;

    if (remaining == 0) {
      return '$hours hr/day';
    }

    return '$hours hr $remaining min/day';
  }

  List<StudyTask> _buildTasks({
    required String planId,
    required List<String> subjects,
    required DateTime startDate,
    required DateTime targetDate,
    required Set<int> studyDays,
    required int minutesPerDay,
  }) {
    final List<StudyTask> tasks = <StudyTask>[];

    if (subjects.isEmpty || studyDays.isEmpty) {
      return tasks;
    }

    final int durationPerSubject = _mathMax(
      15,
      (minutesPerDay / subjects.length).round(),
    );

    int subjectIndex = 0;
    DateTime current = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final DateTime end = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    while (!current.isAfter(end)) {
      if (studyDays.contains(current.weekday)) {
        final String subject = subjects[subjectIndex % subjects.length];

        tasks.add(
          StudyTask(
            id: '${planId}_${tasks.length + 1}',
            title: 'Study $subject',
            subject: subject,
            date: current,
            durationMinutes: durationPerSubject,
          ),
        );

        subjectIndex++;
      }

      current = current.add(const Duration(days: 1));
    }

    return tasks;
  }

  Future<void> _createPlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubjects.isEmpty) {
      _showMessage('Select at least one subject.');
      return;
    }

    if (_selectedStudyDays.isEmpty) {
      _showMessage('Select at least one study day.');
      return;
    }

    if (!_targetDate.isAfter(_startDate)) {
      _showMessage('Target date must be after the start date.');
      return;
    }

    final String planId =
        DateTime.now().microsecondsSinceEpoch.toString();

    final List<String> subjects = List<String>.of(_selectedSubjects);

    final List<StudyTask> tasks = _buildTasks(
      planId: planId,
      subjects: subjects,
      startDate: _startDate,
      targetDate: _targetDate,
      studyDays: _selectedStudyDays,
      minutesPerDay: _minutesPerDay,
    );

    final StudyPlan plan = StudyPlan(
      id: planId,
      title: _titleController.text.trim().isEmpty
          ? 'My Study Plan'
          : _titleController.text.trim(),
      examType: _examType,
      level: _level,
      subjects: subjects,
      startDate: _startDate,
      targetDate: _targetDate,
      studyDays: List<int>.of(_selectedStudyDays),
      minutesPerDay: _minutesPerDay,
      createdAt: DateTime.now(),
      tasks: tasks,
    );

    await widget.store.addPlan(plan);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  int _mathMax(int a, int b) => a > b ? a : b;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Study Plan'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: <Widget>[
              const Text(
                'Build your personal study plan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose what you are preparing for, what to study, '
                'and when you want to study.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Plan name',
                  hintText: 'e.g. WAEC Preparation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a plan name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _examType,
                decoration: const InputDecoration(
                  labelText: 'Exam / Study goal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: _examTypes
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _examType = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _level,
                decoration: const InputDecoration(
                  labelText: 'Education level',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                items: _levels
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _level = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Subjects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select the subjects you want TutorAI to include.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subjects.map(
                  (String subject) {
                    final bool selected =
                        _selectedSubjects.contains(subject);

                    return FilterChip(
                      label: Text(subject),
                      selected: selected,
                      onSelected: (bool value) {
                        setState(() {
                          if (value) {
                            _selectedSubjects.add(subject);
                          } else {
                            _selectedSubjects.remove(subject);
                          }
                        });
                      },
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Study days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _weekdays.map(
                  (Map<String, dynamic> item) {
                    final String name = item['name'] as String;
                    final int value = item['value'] as int;
                    final bool selected =
                        _selectedStudyDays.contains(value);

                    return FilterChip(
                      label: Text(name),
                      selected: selected,
                      onSelected: (bool isSelected) {
                        setState(() {
                          if (isSelected) {
                            _selectedStudyDays.add(value);
                          } else {
                            _selectedStudyDays.remove(value);
                          }
                        });
                      },
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Study time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatMinutes(_minutesPerDay),
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
              Slider(
                min: 30,
                max: 180,
                divisions: 10,
                value: _minutesPerDay.toDouble(),
                label: _formatMinutes(_minutesPerDay),
                onChanged: (double value) {
                  setState(() {
                    _minutesPerDay = value.round();
                  });
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'Study period',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectStartDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Start'),
                          Text(_formatDate(_startDate)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTargetDate,
                      icon: const Icon(Icons.event_outlined),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Target'),
                          Text(_formatDate(_targetDate)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _createPlan,
                icon: const Icon(Icons.auto_awesome),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Create Study Plan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudyTask {
  final String id;
  final String title;
  final String subject;
  final DateTime date;
  final int durationMinutes;
  final bool completed;

  const StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.durationMinutes,
    this.completed = false,
  });

  StudyTask copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? date,
    int? durationMinutes,
    bool? completed,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'subject': subject,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completed': completed,
    };
  }

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ??
          DateTime.now(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class StudyPlan {
  final String id;
  final String title;
  final String examType;
  final String level;
  final List<String> subjects;
  final DateTime startDate;
  final DateTime targetDate;
  final List<int> studyDays;
  final int minutesPerDay;
  final DateTime createdAt;
  final List<StudyTask> tasks;

  const StudyPlan({
    required this.id,
    required this.title,
    required this.examType,
    required this.level,
    required this.subjects,
    required this.startDate,
    required this.targetDate,
    required this.studyDays,
    required this.minutesPerDay,
    required this.createdAt,
    this.tasks = const <StudyTask>[],
  });

  int get totalTasks => tasks.length;

  int get completedTasks =>
      tasks.where((StudyTask task) => task.completed).length;

  double get completionRate {
    if (tasks.isEmpty) {
      return 0;
    }
    return completedTasks / totalTasks;
  }

  StudyPlan copyWith({
    String? id,
    String? title,
    String? examType,
    String? level,
    List<String>? subjects,
    DateTime? startDate,
    DateTime? targetDate,
    List<int>? studyDays,
    int? minutesPerDay,
    DateTime? createdAt,
    List<StudyTask>? tasks,
  }) {
    return StudyPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      examType: examType ?? this.examType,
      level: level ?? this.level,
      subjects: subjects ?? this.subjects,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      studyDays: studyDays ?? this.studyDays,
      minutesPerDay: minutesPerDay ?? this.minutesPerDay,
      createdAt: createdAt ?? this.createdAt,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'examType': examType,
      'level': level,
      'subjects': subjects,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'studyDays': studyDays,
      'minutesPerDay': minutesPerDay,
      'createdAt': createdAt.toIso8601String(),
      'tasks': tasks.map((StudyTask task) => task.toJson()).toList(),
    };
  }

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSubjects =
        json['subjects'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawStudyDays =
        json['studyDays'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawTasks =
        json['tasks'] as List<dynamic>? ?? <dynamic>[];

    return StudyPlan(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Study Plan',
      examType: json['examType'] as String? ?? '',
      level: json['level'] as String? ?? '',
      subjects: rawSubjects.map((dynamic value) => value.toString()).toList(),
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.now(),
      targetDate: DateTime.tryParse(json['targetDate'] as String? ?? '') ??
          DateTime.now(),
      studyDays:
          rawStudyDays.whereType<num>().map((num value) => value.toInt()).toList(),
      minutesPerDay: (json['minutesPerDay'] as num?)?.toInt() ?? 30,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      tasks: rawTasks
          .whereType<Map>()
          .map(
            (Map value) =>
                StudyTask.fromJson(Map<String, dynamic>.from(value)),
          )
          .toList(),
    );
  }
}


class StudyPlanStore extends ChangeNotifier {
  static const String _storageKey = 'tutor_ai_study_plans_v1';

  final List<StudyPlan> _plans = <StudyPlan>[];
  bool _loaded = false;

  List<StudyPlan> get plans => List<StudyPlan>.unmodifiable(_plans);
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) {
      return;
    }

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    final String? raw = preferences.getString(_storageKey);

    _plans.clear();

    if (raw != null && raw.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(raw);

        if (decoded is List) {
          for (final dynamic item in decoded) {
            if (item is Map) {
              _plans.add(
                StudyPlan.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        }
      } catch (_) {
        _plans.clear();
      }
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> addPlan(StudyPlan plan) async {
    _plans.add(plan);
    await _persist();
    notifyListeners();
  }

  Future<void> updatePlan(StudyPlan plan) async {
    final int index =
        _plans.indexWhere((StudyPlan item) => item.id == plan.id);

    if (index == -1) {
      return;
    }

    _plans[index] = plan;
    await _persist();
    notifyListeners();
  }

  Future<void> deletePlan(String planId) async {
    _plans.removeWhere((StudyPlan plan) => plan.id == planId);
    await _persist();
    notifyListeners();
  }

  Future<void> toggleTask({
    required String planId,
    required String taskId,
  }) async {
    final int planIndex =
        _plans.indexWhere((StudyPlan plan) => plan.id == planId);

    if (planIndex == -1) {
      return;
    }

    final StudyPlan plan = _plans[planIndex];

    final List<StudyTask> updatedTasks = plan.tasks.map(
      (StudyTask task) {
        if (task.id != taskId) {
          return task;
        }

        return task.copyWith(completed: !task.completed);
      },
    ).toList();

    _plans[planIndex] = plan.copyWith(tasks: updatedTasks);
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _plans.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String encoded = jsonEncode(
      _plans.map((StudyPlan plan) => plan.toJson()).toList(),
    );

    await preferences.setString(_storageKey, encoded);
  }
}

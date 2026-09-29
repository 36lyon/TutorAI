import 'package:shared_preferences/shared_preferences.dart';

class TutorPremiumStore {
  static const String _activeKey = 'tutor_ai_premium_active_v1';
  static const String _planKey = 'tutor_ai_premium_plan_v1';
  static const String _emailKey = 'tutor_ai_premium_email_v1';
  static const String _referenceKey = 'tutor_ai_premium_reference_v1';

  bool _loaded = false;
  bool _isActive = false;
  String _plan = '';
  String _email = '';
  String _reference = '';

  bool get isActive => _isActive;
  String get plan => _plan;
  String get email => _email;
  String get reference => _reference;

  Future<void> load() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();

    _isActive = prefs.getBool(_activeKey) ?? false;
    _plan = prefs.getString(_planKey) ?? '';
    _email = prefs.getString(_emailKey) ?? '';
    _reference = prefs.getString(_referenceKey) ?? '';

    _loaded = true;
  }

  Future<void> activate({
    required String plan,
    required String email,
    required String reference,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _isActive = true;
    _plan = plan.trim().toLowerCase();
    _email = email.trim().toLowerCase();
    _reference = reference.trim();

    await prefs.setBool(_activeKey, true);
    await prefs.setString(_planKey, _plan);
    await prefs.setString(_emailKey, _email);
    await prefs.setString(_referenceKey, _reference);

    _loaded = true;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    _isActive = false;
    _plan = '';
    _email = '';
    _reference = '';

    await prefs.remove(_activeKey);
    await prefs.remove(_planKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_referenceKey);

    _loaded = true;
  }
}
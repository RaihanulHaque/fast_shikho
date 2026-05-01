import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/session.dart';
import '../models/study_package.dart';
import 'dummy_data.dart';

/// Auth service provider — manages login state and user data.
/// Replace DummyAuthService with real API implementation later.
class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Dummy: accept any phone/password combo
    if (phone.isNotEmpty && password.length >= 4) {
      _currentUser = DummyData.defaultUser;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required String classLevel,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _currentUser = User(
      id: 'u-new-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      phoneNumber: phone,
      classLevel: classLevel,
      pointsBalance: 10, // Welcome bonus
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> updateProfile({String? fullName, String? classLevel}) async {
    if (_currentUser == null) return;
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      classLevel: classLevel,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

/// Session service provider — manages sessions and study content.
class SessionService extends ChangeNotifier {
  List<Session> _sessions = List.from(DummyData.sessions);
  bool _isLoading = false;
  StudyPackage? _currentPackage;

  List<Session> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  StudyPackage? get currentPackage => _currentPackage;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _sessions = List.from(DummyData.sessions);

    _isLoading = false;
    notifyListeners();
  }

  Future<Session> createSession() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final session = Session(
      id: 's-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'u-001',
      title: 'New Study Session',
      status: 'pending',
    );

    _sessions.insert(0, session);
    notifyListeners();
    return session;
  }

  Future<Session> uploadAndProcess(String sessionId) async {
    // Simulate upload and processing
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx == -1) throw Exception('Session not found');

    // Update to processing
    _sessions[idx] = _sessions[idx].copyWith(status: 'processing');
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Update to complete with data from dummy
    _sessions[idx] = _sessions[idx].copyWith(
      status: 'complete',
      title: 'Structure and Functions of Blood Cells',
      detectedSubject: 'Biology',
      filePageCount: 3,
      completedAt: DateTime.now(),
    );
    notifyListeners();

    return _sessions[idx];
  }

  Future<StudyPackage> getSessionContent(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _currentPackage = StudyPackage.fromJson(DummyData.studyPackageJson);
    return _currentPackage!;
  }

  Future<void> deleteSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _sessions[idx] = _sessions[idx].copyWith(title: newTitle);
      notifyListeners();
    }
  }
}

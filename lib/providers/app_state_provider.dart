import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../core/services/firebase_service.dart';

class AppStateProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSyncing = false;

  String _customServerUrl = 'https://ais-pre-3d27sf5ik2n6ln4xabwir3-272598978153.europe-west2.run.app';

  String get customServerUrl => _customServerUrl;

  void updateServerUrl(String url) {
    if (url.trim().isNotEmpty) {
      _customServerUrl = url.trim();
      notifyListeners();
    }
  }

  String get _apiBaseUrl {
    if (kIsWeb) {
      final baseUri = Uri.base;
      if (baseUri.scheme == 'http' || baseUri.scheme == 'https') {
        // If the web app is running under standard localhost/custom port, return the baseUri.
        // But if we specifically want to proxy through the server, we can also use customServerUrl.
        return '${baseUri.scheme}://${baseUri.host}:${baseUri.port}';
      }
    }
    return _customServerUrl;
  }

  bool get isSyncing => _isSyncing;
  bool get isFirebaseConnected => _firebaseService.isLoggedIn;
  String? get userUid => _firebaseService.uid;
  String? get userEmail => _firebaseService.email;

  // Theme and Locale
  ThemeMode _themeMode = ThemeMode.light;
  Locale _currentLocale = const Locale('fr', 'FR');

  ThemeMode get themeMode => _themeMode;
  Locale get currentLocale => _currentLocale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Profile / Onboarding State
  bool _isOnboardingComplete = false;
  String _profileName = '';
  String _profileBirthdate = '';
  int _profileAge = 0;

  bool get isOnboardingComplete => _isOnboardingComplete;
  String get profileName => _profileName;
  String get profileBirthdate => _profileBirthdate;
  int get profileAge => _profileAge;

  bool get isTodayBirthday {
    if (_profileBirthdate.isEmpty) return false;
    try {
      final parts = _profileBirthdate.split('-');
      if (parts.length == 3) {
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final now = DateTime.now();
        return now.day == day && now.month == month;
      }
    } catch (_) {}
    return false;
  }

  // XP, Level, Streak State
  int _xp = 0;
  int _level = 1;
  int _streak = 0;
  bool _isDayValidated = false;

  int get xp => _xp;
  int get level => _level;
  int get streak => _streak;
  bool get isDayValidated => _isDayValidated;

  // Dynamic Focus States
  int _focusMinutesTotal = 120;
  String _selectedSound = 'Pluie en Forêt'; // Rain
  
  int get focusMinutesTotal => _focusMinutesTotal;
  String get selectedSound => _selectedSound;

  void setSound(String sound) {
    _selectedSound = sound;
    _syncToFirebase();
    notifyListeners();
  }

  void addFocusMinutes(int mins) {
    _focusMinutesTotal += mins;
    _xp += mins * 2;
    if (_xp >= 100 * _level) {
      _xp -= 100 * _level;
      _level += 1;
    }
    _syncToFirebase();
    notifyListeners();
  }

  // Tasks State
  final List<Map<String, dynamic>> _tasks = [];

  List<Map<String, dynamic>> get tasks => _tasks;

  // Notifications State
  final List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;

  void addNotification(String title, String content, String type) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'content': content,
      'date': DateTime.now().toIso8601String(),
      'read': false,
      'type': type, // 'info', 'success', 'warning', 'xp'
    });
    _syncToFirebase();
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (var notif in _notifications) {
      notif['read'] = true;
    }
    _syncToFirebase();
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _syncToFirebase();
    notifyListeners();
  }

  // Goals State (Objectifs)
  final List<Map<String, dynamic>> _goals = [];

  List<Map<String, dynamic>> get goals => _goals;

  void addGoal(String title, String category) {
    _goals.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'category': category,
      'progress': 0.0,
    });
    _syncToFirebase();
    notifyListeners();
  }

  void updateGoalProgress(String id, double progress) {
    for (var g in _goals) {
      if (g['id'] == id) {
        g['progress'] = progress;
        break;
      }
    }
    _syncToFirebase();
    notifyListeners();
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g['id'] == id);
    _syncToFirebase();
    notifyListeners();
  }

  // Community Posts State
  final List<Map<String, dynamic>> _communityPosts = [];

  List<Map<String, dynamic>> get communityPosts => _communityPosts;

  Future<void> loadCommunityPosts() async {
    final posts = await _firebaseService.fetchCollection('community_posts');
    if (posts != null) {
      _communityPosts.clear();
      // Sort posts by timestamp descending
      posts.sort((a, b) {
        final num tA = a['timestamp'] ?? 0;
        final num tB = b['timestamp'] ?? 0;
        return tB.compareTo(tA);
      });
      for (var post in posts) {
        final String authorId = post['authorId'] ?? '';
        final List likedBy = post['likedBy'] ?? [];
        _communityPosts.add({
          'id': post['id'] ?? '',
          'author': post['author'] ?? 'Anonyme',
          'authorId': authorId,
          'avatarColorValue': post['avatarColorValue'] ?? 0xff6366f1,
          'time': post['time'] ?? 'À l\'instant',
          'text': post['text'] ?? '',
          'likes': post['likes'] ?? 0,
          'hasLiked': likedBy.contains(userUid),
          'likedBy': likedBy,
          'tag': post['tag'] ?? '#BienEtre',
          'timestamp': post['timestamp'] ?? 0,
        });
      }
      notifyListeners();
    }
  }

  Future<void> addCommunityPost(String text, {String tag = '#BienEtre'}) async {
    final authorName = _profileName.isNotEmpty ? _profileName : 'Moi';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final newPost = {
      'author': authorName,
      'authorId': userUid ?? '',
      'avatarColorValue': 0xff6366f1,
      'time': 'À l\'instant',
      'text': text,
      'likes': 0,
      'likedBy': [],
      'tag': tag,
      'timestamp': timestamp,
    };
    
    _isSyncing = true;
    notifyListeners();
    
    final createdDoc = await _firebaseService.createDocument('community_posts', newPost);
    if (createdDoc != null) {
      await loadCommunityPosts();
    }
    _isSyncing = false;
    notifyListeners();
  }

  Future<void> toggleLikePost(String id) async {
    final String currentUid = userUid ?? '';
    if (currentUid.isEmpty) return;
    
    Map<String, dynamic>? targetPost;
    for (var post in _communityPosts) {
      if (post['id'] == id) {
        targetPost = post;
        break;
      }
    }
    
    if (targetPost != null) {
      final List likedBy = List.from(targetPost['likedBy'] ?? []);
      bool isLikedNow = likedBy.contains(currentUid);
      
      if (isLikedNow) {
        likedBy.remove(currentUid);
      } else {
        likedBy.add(currentUid);
      }
      
      final int newLikes = likedBy.length;
      final bool hasLikedNew = !isLikedNow;
      
      targetPost['hasLiked'] = hasLikedNew;
      targetPost['likedBy'] = likedBy;
      targetPost['likes'] = newLikes;
      notifyListeners();
      
      await _firebaseService.updateDocument('community_posts', id, {
        'likedBy': likedBy,
        'likes': newLikes,
      });
    }
  }

  // Daily Check-in State
  int _dailyMood = 3; // 1-5
  int _dailyEnergy = 3; // 1-5
  int _dailyMotivation = 3; // 1-5
  int _dailyStress = 3; // 1-5
  int _dailySleep = 3; // 1-5
  bool _hasCheckedInToday = false;
  String _lastManualCheckInDate = '';

  int get dailyMood => _dailyMood;
  int get dailyEnergy => _dailyEnergy;
  int get dailyMotivation => _dailyMotivation;
  int get dailyStress => _dailyStress;
  int get dailySleep => _dailySleep;
  bool get hasCheckedInToday => _hasCheckedInToday;
  String get lastManualCheckInDate => _lastManualCheckInDate;

  void submitDailyCheckIn(int mood, int energy, int motivation, int stress, int sleep) {
    _dailyMood = mood;
    _dailyEnergy = energy;
    _dailyMotivation = motivation;
    _dailyStress = stress;
    _dailySleep = sleep;
    _hasCheckedInToday = true;
    _lastManualCheckInDate = DateTime.now().toIso8601String().split('T')[0];
    _xp += 30;
    if (_xp >= 100 * _level) {
      _xp -= 100 * _level;
      _level += 1;
    }
    _syncToFirebase();
    notifyListeners();
  }

  // Specialized modules and user profile roles
  String _userRole = 'Étudiant'; // Étudiant, Professionnel, Entrepreneur
  String _coachPersonality = 'Bienveillant'; // Bienveillant, Direct, Académique
  
  String get userRole => _userRole;
  String get coachPersonality => _coachPersonality;

  void setUserRole(String role) {
    _userRole = role;
    _syncToFirebase();
    notifyListeners();
  }

  void setCoachPersonality(String personality) {
    _coachPersonality = personality;
    _syncToFirebase();
    notifyListeners();
  }

  // Missions State
  final List<Map<String, dynamic>> _missions = [
    {
      'id': '1',
      'title': 'Méditer 10 minutes',
      'xp': 50,
      'description': 'Prenez du recul et respirez profondément pour calmer l\'esprit.',
      'progress': 1.0,
      'isCompleted': true,
      'claimed': false
    },
    {
      'id': '2',
      'title': 'Limiter le budget loisirs',
      'xp': 120,
      'description': 'Évitez les dépenses superflues aujourd\'hui.',
      'progress': 0.7,
      'isCompleted': false,
      'claimed': false
    },
    {
      'id': '3',
      'title': 'Compléter 15 tâches',
      'xp': 300,
      'description': 'Maintenez votre rythme de travail sans surcharge mentale.',
      'progress': 0.4,
      'isCompleted': false,
      'claimed': false
    },
  ];

  List<Map<String, dynamic>> get missions => _missions;

  // Budget State
  double _totalBudget = 0.0;
  final List<Map<String, dynamic>> _transactions = [];

  double get totalBudget => _totalBudget;
  List<Map<String, dynamic>> get transactions => _transactions;

  double get spentBudget {
    double spent = 0.0;
    for (var tx in _transactions) {
      final amt = tx['amount'] as num?;
      final isNeg = tx['isNegative'] as bool?;
      if (isNeg == true || (amt != null && amt < 0)) {
        spent += (amt ?? 0).toDouble().abs();
      }
    }
    return spent;
  }

  double get remainingBudget {
    double total = _totalBudget;
    for (var tx in _transactions) {
      total += (tx['amount'] as num).toDouble();
    }
    return total;
  }

  // Coach Chat State
  final List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages {
    if (_messages.isEmpty) {
      final name = _profileName.isNotEmpty ? _profileName : 'Ami';
      return [
        {
          'text': 'Bonjour $name ! Je suis Nexii, ton coach de vie IA. Comment puis-je t\'accompagner aujourd\'hui dans ton équilibre quotidien ? 🧘‍♂️✨',
          'isUser': false
        }
      ];
    }
    return _messages;
  }
  bool _isCoachTyping = false;
  bool get isCoachTyping => _isCoachTyping;

  // Agenda State
  final List<Map<String, dynamic>> _agendaEvents = [];

  List<Map<String, dynamic>> get agendaEvents => _agendaEvents;

  // Constructor
  AppStateProvider() {
    _initFirebase();
  }

  // Automatic Firebase Sign in check
  Future<void> _initFirebase() async {
    _isSyncing = false;
    notifyListeners();
  }

  Future<void> _hydrateData() async {
    final cloudData = await _firebaseService.fetchUserData();
    if (cloudData != null && cloudData.isNotEmpty) {
      // Hydrate local state from Firestore
      if (cloudData.containsKey('name')) _profileName = cloudData['name'];
      if (cloudData.containsKey('birthdate')) _profileBirthdate = cloudData['birthdate'];
      if (cloudData.containsKey('age')) _profileAge = cloudData['age'];
      if (cloudData.containsKey('userXp')) _xp = cloudData['userXp'];
      if (cloudData.containsKey('userLevel')) _level = cloudData['userLevel'];
      if (cloudData.containsKey('userStreak')) _streak = cloudData['userStreak'];
      if (cloudData.containsKey('totalBudget')) _totalBudget = (cloudData['totalBudget'] as num).toDouble();
      if (cloudData.containsKey('focusMinutesTotal')) _focusMinutesTotal = cloudData['focusMinutesTotal'];
      
      if (cloudData.containsKey('tasks')) {
        _tasks.clear();
        _tasks.addAll((cloudData['tasks'] as List).map((t) => Map<String, dynamic>.from(t)));
      }
      if (cloudData.containsKey('transactions')) {
        _transactions.clear();
        _transactions.addAll((cloudData['transactions'] as List).map((t) => Map<String, dynamic>.from(t)));
      }
      if (cloudData.containsKey('agendaEvents')) {
        _agendaEvents.clear();
        _agendaEvents.addAll((cloudData['agendaEvents'] as List).map((e) => Map<String, dynamic>.from(e)));
      }
      if (cloudData.containsKey('missions')) {
        _missions.clear();
        _missions.addAll((cloudData['missions'] as List).map((m) => Map<String, dynamic>.from(m)));
      }
      if (cloudData.containsKey('goals')) {
        _goals.clear();
        _goals.addAll((cloudData['goals'] as List).map((g) => Map<String, dynamic>.from(g)));
      }
      if (cloudData.containsKey('communityPosts')) {
        _communityPosts.clear();
        _communityPosts.addAll((cloudData['communityPosts'] as List).map((cp) => Map<String, dynamic>.from(cp)));
      }
      if (cloudData.containsKey('notifications')) {
        _notifications.clear();
        _notifications.addAll((cloudData['notifications'] as List).map((n) => Map<String, dynamic>.from(n)));
      }
      if (cloudData.containsKey('isDarkMode')) {
        _themeMode = cloudData['isDarkMode'] == true ? ThemeMode.dark : ThemeMode.light;
      }
      if (cloudData.containsKey('lang')) {
        _currentLocale = Locale(cloudData['lang']);
      }
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      if (cloudData.containsKey('lastManualCheckInDate')) {
        _lastManualCheckInDate = cloudData['lastManualCheckInDate'] ?? '';
        _hasCheckedInToday = _lastManualCheckInDate == todayStr;
      }
      if (cloudData.containsKey('checkInMood')) _dailyMood = cloudData['checkInMood'];
      if (cloudData.containsKey('checkInEnergy')) _dailyEnergy = cloudData['checkInEnergy'];
      if (cloudData.containsKey('checkInMotivation')) _dailyMotivation = cloudData['checkInMotivation'];
      if (cloudData.containsKey('checkInStress')) _dailyStress = cloudData['checkInStress'];
      if (cloudData.containsKey('checkInSleep')) _dailySleep = cloudData['checkInSleep'];
      _isOnboardingComplete = _profileName.isNotEmpty && _profileName != 'Bokam';
      await loadCommunityPosts();
    } else {
      _isOnboardingComplete = false;
      _profileName = '';
      _profileBirthdate = '';
      _profileAge = 0;
      await loadCommunityPosts();
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isSyncing = true;
    notifyListeners();
    final loggedIn = await _firebaseService.signIn(email, password);
    if (loggedIn) {
      await _hydrateData();
    }
    _isSyncing = false;
    notifyListeners();
    return loggedIn;
  }

  Future<bool> registerWithEmail(String email, String password) async {
    _isSyncing = true;
    notifyListeners();
    final loggedIn = await _firebaseService.signUp(email, password);
    if (loggedIn) {
      _isOnboardingComplete = false;
      _profileName = '';
      _profileBirthdate = '';
      _profileAge = 0;
      await _syncToFirebase();
    }
    _isSyncing = false;
    notifyListeners();
    return loggedIn;
  }

  Future<bool> continueAnonymously() async {
    _isSyncing = true;
    notifyListeners();
    final loggedIn = await _firebaseService.signInAnonymously();
    if (loggedIn) {
      await _hydrateData();
    }
    _isSyncing = false;
    notifyListeners();
    return loggedIn;
  }

  void logout() {
    _firebaseService.signOut();
    _isOnboardingComplete = false;
    _profileName = '';
    _profileBirthdate = '';
    _profileAge = 0;
    notifyListeners();
  }

  // Sync back to Firebase Firestore
  Future<void> _syncToFirebase() async {
    if (!_firebaseService.isLoggedIn) return;
    await _firebaseService.saveUserData({
      'name': _profileName,
      'birthdate': _profileBirthdate,
      'age': _profileAge,
      'userXp': _xp,
      'userLevel': _level,
      'userStreak': _streak,
      'tasks': _tasks,
      'transactions': _transactions,
      'totalBudget': _totalBudget,
      'missions': _missions,
      'agendaEvents': _agendaEvents,
      'goals': _goals,
      'communityPosts': _communityPosts,
      'notifications': _notifications,
      'focusMinutesTotal': _focusMinutesTotal,
      'isDarkMode': _themeMode == ThemeMode.dark,
      'lang': _currentLocale.languageCode,
      'lastManualCheckInDate': _lastManualCheckInDate,
      'checkInMood': _dailyMood,
      'checkInEnergy': _dailyEnergy,
      'checkInMotivation': _dailyMotivation,
      'checkInStress': _dailyStress,
      'checkInSleep': _dailySleep,
    });
  }

  // Global methods
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _syncToFirebase();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _syncToFirebase();
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _currentLocale = locale;
    _syncToFirebase();
    notifyListeners();
  }

  // Onboarding action
  void completeOnboarding(String name, String birthdate) {
    _profileName = name;
    _profileBirthdate = birthdate;
    try {
      final parts = birthdate.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        _profileAge = DateTime.now().year - year;
      } else {
        _profileAge = 26;
      }
    } catch (_) {
      _profileAge = 26;
    }
    _isOnboardingComplete = true;
    _syncToFirebase();
    notifyListeners();
  }

  void updateProfile(String name, String birthdate) {
    _profileName = name;
    _profileBirthdate = birthdate;
    try {
      final parts = birthdate.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        _profileAge = DateTime.now().year - year;
      }
    } catch (_) {}
    _syncToFirebase();
    notifyListeners();
  }

  // Task Actions
  void addTask(String title, String subtitle, String category, {
    String priority = 'Moyenne',
    String urgency = 'Moyenne',
    String difficulty = 'Moyen',
    int estimatedTime = 30,
    String energyNeeded = 'Moyenne',
    String linkedGoalId = '',
  }) {
    _tasks.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'isCompleted': false,
      'priority': priority,
      'urgency': urgency,
      'difficulty': difficulty,
      'estimatedTime': estimatedTime,
      'energyNeeded': energyNeeded,
      'linkedGoalId': linkedGoalId,
    });
    
    // Update weekly tasks mission progress
    double currProgress = (_missions[2]['progress'] as num).toDouble();
    if (currProgress < 1.0) {
      _missions[2]['progress'] = (currProgress + 0.1).clamp(0.0, 1.0);
      if (_missions[2]['progress'] >= 1.0) {
        _missions[2]['isCompleted'] = true;
      }
    }
    _syncToFirebase();
    notifyListeners();
  }

  void toggleTask(String id) {
    for (var task in _tasks) {
      if (task['id'] == id) {
        task['isCompleted'] = !task['isCompleted'];
        break;
      }
    }
    _syncToFirebase();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t['id'] == id);
    _syncToFirebase();
    notifyListeners();
  }

  // Mission Actions
  void claimMissionXp(String missionId) {
    for (var m in _missions) {
      if (m['id'] == missionId && m['isCompleted'] == true && m['claimed'] != true) {
        m['claimed'] = true;
        _xp += m['xp'] as int;
        if (_xp >= 100 * _level) {
          _xp -= 100 * _level;
          _level += 1;
        }
        break;
      }
    }
    _syncToFirebase();
    notifyListeners();
  }

  // Budget Actions
  void addTransaction(String title, double amount, String category, bool isNegative) {
    _transactions.insert(0, {
      'title': title,
      'amount': isNegative ? -amount.abs() : amount.abs(),
      'category': category,
      'isNegative': isNegative,
    });
    
    // Update daily mission
    if (remainingBudget > 0) {
      _missions[1]['progress'] = 0.9;
    }
    _syncToFirebase();
    notifyListeners();
  }

  void deleteTransaction(int index) {
    if (index >= 0 && index < _transactions.length) {
      _transactions.removeAt(index);
      _syncToFirebase();
      notifyListeners();
    }
  }

  void updateBudget(double newBudget) {
    _totalBudget = newBudget;
    _syncToFirebase();
    notifyListeners();
  }

  // Agenda Actions
  void addAgendaEvent(String title, String time) {
    _agendaEvents.add({
      'title': title,
      'time': time,
    });
    _syncToFirebase();
    notifyListeners();
  }

  void removeAgendaEvent(int index) {
    if (index >= 0 && index < _agendaEvents.length) {
      _agendaEvents.removeAt(index);
      _syncToFirebase();
      notifyListeners();
    }
  }

  // Day Validation
  void validateDay() {
    if (!_isDayValidated) {
      _isDayValidated = true;
      _streak += 1;
      _xp += 30;
      if (_xp >= 100 * _level) {
        _xp -= 100 * _level;
        _level += 1;
      }
      _syncToFirebase();
      notifyListeners();
    }
  }

  // Submit Feedback to Firestore
  Future<bool> submitFeedback(int rating, String comment) async {
    final String currentUid = userUid ?? '';
    if (currentUid.isEmpty) return false;

    final feedbackData = {
      'rating': rating,
      'comment': comment,
      'userEmail': userEmail ?? 'anonymous@nexii.app',
      'userLevel': _level,
      'userXp': _xp,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _isSyncing = true;
    notifyListeners();

    try {
      final doc = await _firebaseService.createDocument('users/$currentUid/feedback', feedbackData);
      _isSyncing = false;
      notifyListeners();
      return doc != null;
    } catch (e) {
      debugPrint("Error submitting feedback: $e");
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  // Coach AI Message Sender & responder
  String _getLocalHeuristicResponse(String text) {
    String reply = "En tant que votre compagnon Nexii, je suis à votre écoute. Analysons ensemble votre planning de la journée pour l'ajuster à votre niveau d'énergie actuel.";
    final lower = text.toLowerCase();
    if (lower.contains('fatigué') || lower.contains('tired') || lower.contains('fatigue')) {
      reply = "Je perçois votre fatigue. Pour aujourd'hui, je vous propose d'alléger le planning. Reportons les tâches complexes et activons une session de récupération active de 5 minutes dans l'onglet Focus.";
    } else if (lower.contains('stress') || lower.contains('angoissé') || lower.contains('anxiété') || lower.contains('overwhelmed') || lower.contains('stressé')) {
      reply = "Le stress est un indicateur de surcharge. Prenons ensemble une grande respiration inspirée. Je vous propose de réduire vos sessions Pomodoro à 15 minutes aujourd'hui pour garder un rythme confortable.";
    } else if (lower.contains('débordé') || lower.contains('deborde') || lower.contains('surcharge') || lower.contains('trop de travail')) {
      reply = "Je comprends tout à fait, la surcharge mentale est réelle. Commençons par prioriser : quelle est la tâche qui compte le plus aujourd'hui ? Je vous conseille de reporter les tâches de priorité Basse et de réserver 15 minutes pour souffler.";
    } else if (lower.contains('commencer') || lower.contains('par où') || lower.contains('sais pas')) {
      reply = "Pas de panique ! En analysant vos objectifs de la journée, je vous propose de commencer par la tâche la plus simple et à haute énergie. Que diriez-vous de débuter par : '${_tasks.isNotEmpty ? _tasks.first['title'] : 'Rédiger l\'introduction du projet'}' ?";
    } else if (lower.contains('argent') || lower.contains('budget') || lower.contains('finance')) {
      reply = "Pour vos finances, gardez un œil sur votre budget mensuel dans l'onglet Budget. Éviter les d'épargnes superflues aujourd'hui vous permettra de rester serein demain !";
    } else if (lower.contains('étudiant') || lower.contains('etudiant') || lower.contains('réviser') || lower.contains('cours') || lower.contains('examens')) {
      reply = "En tant qu'étudiant, l'organisation est cruciale. Votre module spécialisé de révisions propose des sessions de 25 minutes de focus suivies de 5 minutes de détente pour mémoriser sans fatigue.";
    } else if (lower.contains('professionnel') || lower.contains('travail') || lower.contains('réunion') || lower.contains('bureau')) {
      reply = "Pour votre profil professionnel, notre priorité est l'équilibre entre productivité et bien-être. J'ai configuré des blocages de temps focus pour protéger votre travail profond de toute interruption.";
    } else if (lower.contains('entrepreneur') || lower.contains('business') || lower.contains('lancement') || lower.contains('projet')) {
      reply = "Être entrepreneur demande une endurance extrême. Pour protéger votre équilibre vie pro/vie perso, je vous recommande de couper vos notifications de travail après 19h.";
    } else if (lower.contains('merci') || lower.contains('thanks') || lower.contains('super')) {
      reply = "Avec grand plaisir ! C'est un honneur de vous accompagner au quotidien. Continuez à avancer à votre propre rythme, c'est cela la vraie réussite !";
    }
    return reply;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _messages.add({
      'text': text,
      'isUser': true,
    });
    _isCoachTyping = true;
    _syncToFirebase();
    notifyListeners();

    try {
      final double spent = _totalBudget - remainingBudget;
      final int budgetProgressPct = _totalBudget > 0 ? ((spent / _totalBudget) * 100).round() : 0;
      final int completedTasksCount = _tasks.where((t) => t['isCompleted'] == true).length;
      final int totalTasksCount = _tasks.length;

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/coach'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userMessage': text,
          'nexiiState': auraPercentage.round(),
          'budgetProgress': budgetProgressPct,
          'completedTasksCount': completedTasksCount,
          'totalTasksCount': totalTasksCount,
          'contextMood': 'Productif',
          'provider': 'gemini',
          'userAge': _profileAge,
        }),
      ).timeout(const Duration(seconds: 15));

      _isCoachTyping = false;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText = data['text'] as String? ?? "Désolé, je n'ai pas pu formuler de réponse.";
        _messages.add({
          'text': replyText,
          'isUser': false,
        });
      } else {
        _messages.add({
          'text': _getLocalHeuristicResponse(text),
          'isUser': false,
        });
      }
    } catch (e) {
      debugPrint("Error calling coach API: $e");
      _isCoachTyping = false;
      _messages.add({
        'text': _getLocalHeuristicResponse(text),
        'isUser': false,
      });
    }

    _syncToFirebase();
    notifyListeners();
  }

  // Aura percentage calculation
  double get auraPercentage {
    // Pillar 1: Objectifs (25 pts)
    int goalsPillarScore = 20 + (_level > 2 ? 5 : 2);
    
    // Pillar 2: Gestion des tâches (25 pts)
    double tasksCompletedRatio = _tasks.isNotEmpty 
        ? (_tasks.where((tk) => tk['isCompleted'] == true).length / _tasks.length) 
        : 0.5;
    int tasksPillarScore = (tasksCompletedRatio * 25).round();
    
    // Pillar 3: Focus (20 pts)
    // Focus minutes can be high, normalize around 120 mins
    int focusPillarScore = ((_focusMinutesTotal / 120.0) * 20.0).round().clamp(0, 20);
    
    // Pillar 4: Bien-être (25 pts)
    int wellnessPillarScore = _hasCheckedInToday
        ? (((_dailyMood + _dailyEnergy + _dailyMotivation + (6 - _dailyStress)) / 20.0) * 25.0).round()
        : 18;
    
    // Pillar 5: Bonus (5 pts)
    int bonusPillarScore = (_streak >= 5 ? 5 : _streak).clamp(0, 5);
    
    double calculated = (goalsPillarScore + tasksPillarScore + focusPillarScore + wellnessPillarScore + bonusPillarScore).toDouble();
    return calculated.clamp(10.0, 100.0);
  }

  String get auraLabel {
    double percentage = auraPercentage;
    String langCode = _currentLocale.languageCode;
    
    if (percentage >= 85) {
      return langCode == 'fr' ? 'Sereine' : langCode == 'es' ? 'Serena' : 'Serene';
    } else if (percentage >= 65) {
      return langCode == 'fr' ? 'Équilibrée' : langCode == 'es' ? 'Equilibrada' : 'Balanced';
    } else if (percentage >= 45) {
      return langCode == 'fr' ? 'Neutre' : langCode == 'es' ? 'Neutra' : 'Neutral';
    } else if (percentage >= 25) {
      return langCode == 'fr' ? 'Agitée' : langCode == 'es' ? 'Agitada' : 'Restless';
    } else {
      return langCode == 'fr' ? 'Surchargée' : langCode == 'es' ? 'Sobrecargada' : 'Overloaded';
    }
  }

  String get auraDescription {
    double percentage = auraPercentage;
    String langCode = _currentLocale.languageCode;
    String baseDesc = '';
    
    if (percentage >= 85) {
      baseDesc = langCode == 'fr'
          ? 'Votre esprit est calme et vos objectifs sont atteints. Une harmonie parfaite !'
          : langCode == 'es'
          ? 'Tu mente está tranquila y tus objetivos cumplidos. ¡Armonía perfecta!'
          : 'Your mind is calm and your goals are met. Perfect harmony!';
    } else if (percentage >= 65) {
      baseDesc = langCode == 'fr'
          ? 'Bonne humeur et productivité stable. Vous avancez avec équilibre.'
          : langCode == 'es'
          ? 'Buen humor y productividad estable. Avanzas con...'
          : 'Good mood and stable productivity. You are moving forward with balance.';
    } else if (percentage >= 45) {
      baseDesc = langCode == 'fr'
          ? 'Journée tranquille. Continuez vos tâches à votre rythme sans stress.'
          : langCode == 'es'
          ? 'Día tranquilo. Sigue con tus tareas a tu propio ritmo sin estrés.'
          : 'Quiet day. Continue your tasks at your own pace without stress.';
    } else if (percentage >= 25) {
      baseDesc = langCode == 'fr'
          ? 'Quelques tensions ou retard de tâches. Prenez une micro-pause de respiration.'
          : langCode == 'es'
          ? 'Algunas tensiones o tareas retrasadas. Tómate un breve descanso para respirar.'
          : 'Some tensions or delayed tasks. Take a quick mindful breathing break.';
    } else {
      baseDesc = langCode == 'fr'
          ? 'Trop de stress ou de tâches en suspens. Laissez tomber le superflu pour aujourd\'hui !'
          : langCode == 'es'
          ? 'Demasiado estrés o tareas pendientes. ¡Olvida lo innecesario por hoy!'
          : 'Too much stress or pending tasks. Let go of the unnecessary for today!';
    }
    
    // Age custom message
    String ageMsg = '';
    if (_profileAge > 0) {
      if (_profileAge <= 18) {
        ageMsg = langCode == 'fr'
            ? " En tant qu'adolescent, l'équilibre entre vos études et votre bien-être est votre plus grande force."
            : langCode == 'es'
            ? " Como adolescente, el equilibrio entre tus estudios y tu bienestar es tu mayor fuerza."
            : " As a teenager, balancing your studies and your well-being is your greatest strength.";
      } else if (_profileAge <= 25) {
        ageMsg = langCode == 'fr'
            ? " À cette étape de jeune adulte, cultivez vos passions tout en restant ancré dans le présent."
            : langCode == 'es'
            ? " En esta etapa de joven adulto, cultiva tus pasiones mientras te mantienes conectado con el presente."
            : " At this young adult stage, cultivate your passions while staying grounded in the present.";
      } else if (_profileAge <= 45) {
        ageMsg = langCode == 'fr'
            ? " Pour un adulte actif, préserver votre santé mentale au milieu du tumulte est essentiel."
            : langCode == 'es'
            ? " Para un adulto activo, preservar tu salud mental en medio del ajetreo es esencial."
            : " For an active adult, preserving your mental health amidst the hustle is essential.";
      } else {
        ageMsg = langCode == 'fr'
            ? " Votre sagesse et votre expérience guident votre chemin vers une sérénité profonde."
            : langCode == 'es'
            ? " Tu sabiduría y experiencia guían tu camino hacia una profunda serenidad."
            : " Your wisdom and experience guide your path to deep serenity.";
      }
    }
    
    return baseDesc + ageMsg;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'birthday_title': "🎉 Joyeux Anniversaire !",
      'birthday_desc': "Toute l'équipe Nexii vous souhaite une magnifique journée d'équilibre et de bonheur ! En ce jour spécial, doublez vos gains d'XP et faites un vœu bien-être. 🌟",
      'birthday_action': "Faire un vœu de bien-être 💫",
      'birthday_wish_success': "Votre vœu a été envoyé dans l'univers ! ✨",
      'app_name': 'Nexii',
      'welcome_back': 'Bonjour',
      'calm_message': 'Prenez une grande inspiration. Tout est sous contrôle.',
      'tab_home': 'Accueil',
      'tab_missions': 'Missions',
      'tab_tasks': 'Tâches',
      'tab_focus': 'Focus',
      'tab_coach': 'Coach',
      'tab_budget': 'Budget',
      'tab_profile': 'Profil',
      'settings_theme': 'Thème Sombre',
      'settings_lang': 'Langue',
      'missions_title': 'Vos Défis Quotidiens',
      'tasks_title': 'Liste des Tâches',
      'focus_title': 'Espace Focus',
      'coach_title': 'Coach de Vie',
      'budget_title': 'Gestion Budgétaire',
      'profile_title': 'Votre Espace Nexii',
      'level_badge': 'Aventurier Niveau 5',
      'joined_date': 'Membre depuis Juillet 2026',
      'sound_picker': 'Sons d\'Ambiance',
      'start_timer': 'DÉMARRER',
      'pause_timer': 'PAUSE',
      'add_task': 'Ajouter une tâche',
      'placeholder_add_task': 'Faire de la cohérence cardiaque...',
      'placeholder_chat': 'Discutez avec votre coach...',
      'aura_title': 'Aura',
      'aura_desc': 'Votre score de bien-être est à 78% aujourd\'hui. Continuez ainsi !',
      'quick_view': 'Aperçu de votre journée',
      'remain_budget': 'RESTE À DÉPENSER CE MOIS-CI',
      'budget_total': 'Budget Total',
      'spent_amount': 'Dépensé',
      'recent_trans': 'DERNIÈRES TRANSACTIONS',
      'mood_title': 'VOTRE HUMEUR DU JOUR',
      'daily_tasks': 'Tâches quotidiennes',
      'all_completed': 'Toutes les tâches terminées !',
      'recommended_focus': 'Focus recommandé',
      'start_action': 'Démarrer',
      'overall_progress': 'Progression générale',
      'claim_xp': 'VALIDER ET RÉCLAMER XP',
      'reward_claimed': 'RECOMPENSE RECUPEREE',
      'cat_label': 'Cat :',
      'prio_label': 'Prio :',
      'difficulty_easy': 'Facile',
      'difficulty_medium': 'Moyen',
      'difficulty_hard': 'Difficile',
      'category_daily': 'Quotidien',
      'category_weekly': 'Hebdomadaire',
      'category_special': 'Spécial',
      'financial_stress': 'Stress Financier',
      'stress_index': 'Indice :',
      'savings_target': 'Cible d\'épargne',
      'activity_streak': 'Série d\'activité',
      'streak_desc': 'Restez actif chaque jour pour augmenter votre série !',
      'active_state': 'Actif',
      'recovery_action': 'Temps de récupération suggéré par l\'IA',
      'reduce_pomodoro': 'Réduire Pomodoro à 15m',
      'recover_5m': 'Récupérer 5 minutes',
      'validate_day': 'Faire mon Bilan / Check-In 🌸 (+30 XP)',
      'already_validated': 'Journée validée ! 🔥',
      'agenda_title': 'Mon Agenda Bien-être',
      'add_event': 'Ajouter à l\'agenda',
      'placeholder_event': 'Séance Yoga, Gym, Méditer...',
      'time_label': 'Heure :',
      'no_events': 'Aucun événement prévu pour ce jour.',
      'stats_title': 'Statistiques Générales',
      'focus_hours': 'Heures Focus',
      'challenges_completed': 'Défis Réussis',
      'success_rate': 'Taux Réussite',
      'cardiac_coherence_short': 'Cohérence Card.',
      'device_options': 'Options de l\'appareil',
      'onboarding_title': 'Complétez votre profil',
      'onboarding_desc': 'Veuillez entrer vos informations pour personnaliser votre expérience sur Nexii.',
      'onboarding_name_label': 'Nom complet',
      'onboarding_birthdate_label': 'Date de naissance',
      'onboarding_submit': 'Valider et démarrer',
      'edit_profile_btn': 'Modifier mes infos',
      'edit_profile_title': 'Modifier mes informations',
      'save_profile_btn': 'Enregistrer les modifications',
      'cancel_btn': 'Annuler',
    },
    'en': {
      'birthday_title': "🎉 Happy Birthday!",
      'birthday_desc': "The Nexii team wishes you a wonderful day of balance and happiness! On this special day, double your XP earnings and make a well-being wish. 🌟",
      'birthday_action': "Make a well-being wish 💫",
      'birthday_wish_success': "Your wish has been sent to the universe! ✨",
      'app_name': 'Nexii',
      'welcome_back': 'Hello',
      'calm_message': 'Take a deep breath. Everything is under control.',
      'tab_home': 'Home',
      'tab_missions': 'Missions',
      'tab_tasks': 'Tasks',
      'tab_focus': 'Focus',
      'tab_coach': 'Coach',
      'tab_budget': 'Budget',
      'tab_profile': 'Profile',
      'settings_theme': 'Dark Theme',
      'settings_lang': 'Language',
      'missions_title': 'Your Daily Quests',
      'tasks_title': 'Task Checklist',
      'focus_title': 'Concentration Space',
      'coach_title': 'Life Coach AI',
      'budget_title': 'Budget Planning',
      'profile_title': 'Your Nexii Hub',
      'level_badge': 'Adventurer Level 5',
      'joined_date': 'Member since July 2026',
      'sound_picker': 'Ambient Sounds',
      'start_timer': 'START TIMER',
      'pause_timer': 'PAUSE',
      'add_task': 'Add new task',
      'placeholder_add_task': 'Practice mindful breathing...',
      'placeholder_chat': 'Message your AI Coach...',
      'aura_title': 'Aura',
      'aura_desc': 'Your well-being score is at 78% today. Keep it up!',
      'quick_view': 'Overview of your day',
      'remain_budget': 'REMAINING TO SPEND THIS MONTH',
      'budget_total': 'Total Budget',
      'spent_amount': 'Spent',
      'recent_trans': 'RECENT TRANSACTIONS',
      'mood_title': 'YOUR MOOD TODAY',
      'daily_tasks': 'Daily tasks',
      'all_completed': 'All tasks completed!',
      'recommended_focus': 'Recommended focus',
      'start_action': 'Start',
      'overall_progress': 'Overall progress',
      'claim_xp': 'VALIDATE & CLAIM XP',
      'reward_claimed': 'REWARD CLAIMED',
      'cat_label': 'Cat:',
      'prio_label': 'Prio:',
      'difficulty_easy': 'Easy',
      'difficulty_medium': 'Medium',
      'difficulty_hard': 'Hard',
      'category_daily': 'Daily',
      'category_weekly': 'Weekly',
      'category_special': 'Special',
      'financial_stress': 'Financial Stress',
      'stress_index': 'Index:',
      'savings_target': 'Savings Target',
      'activity_streak': 'Activity Streak',
      'streak_desc': 'Stay active every day to increase your streak!',
      'active_state': 'Active',
      'recovery_action': 'AI Recovery Recommendation',
      'reduce_pomodoro': 'Reduce Pomodoro to 15m',
      'recover_5m': 'Recover 5 minutes',
      'validate_day': 'Daily check-in 🌸 (+30 XP)',
      'already_validated': 'Day Validated! 🔥',
      'agenda_title': 'My Well-being Agenda',
      'add_event': 'Add to Agenda',
      'placeholder_event': 'Yoga, Gym, Meditate...',
      'time_label': 'Time:',
      'no_events': 'No events scheduled for today.',
      'stats_title': 'General Statistics',
      'focus_hours': 'Focus Hours',
      'challenges_completed': 'Challenges Completed',
      'success_rate': 'Success Rate',
      'cardiac_coherence_short': 'Card. Coherence',
      'device_options': 'Device Options',
      'onboarding_title': 'Complete your profile',
      'onboarding_desc': 'Please enter your information to personalize your Nexii experience.',
      'onboarding_name_label': 'Full Name',
      'onboarding_birthdate_label': 'Birthdate',
      'onboarding_submit': 'Submit and start',
      'edit_profile_btn': 'Edit my info',
      'edit_profile_title': 'Edit my information',
      'save_profile_btn': 'Save changes',
      'cancel_btn': 'Cancel',
    },
    'es': {
      'birthday_title': "🎉 ¡Feliz Cumpleaños!",
      'birthday_desc': "¡El equipo de Nexii te desea un maravilloso día de equilibrio y felicidad! En este día especial, ¡duplica tus ganancias de XP y pide un deseo de bienestar! 🌟",
      'birthday_action': "Pedir un deseo de bienestar 💫",
      'birthday_wish_success': "¡Tu deseo ha sido enviado al universo! ✨",
      'app_name': 'Nexii',
      'welcome_back': 'Hola',
      'calm_message': 'Inhala profundamente. Todo está bajo control.',
      'tab_home': 'Inicio',
      'tab_missions': 'Misiones',
      'tab_tasks': 'Tareas',
      'tab_focus': 'Enfoque',
      'tab_coach': 'Coach',
      'tab_budget': 'Presupuesto',
      'tab_profile': 'Perfil',
      'settings_theme': 'Tema Oscuro',
      'settings_lang': 'Idioma',
      'missions_title': 'Tus Desafíos Diarios',
      'tasks_title': 'Lista de Tareas',
      'focus_title': 'Espacio de Enfoque',
      'coach_title': 'Coach de Vida',
      'budget_title': 'Gestión del Presupuesto',
      'profile_title': 'Tu Espacio Nexii',
      'level_badge': 'Aventurero Nivel 5',
      'joined_date': 'Miembro desde Julio 2026',
      'sound_picker': 'Sonidos de Ambiente',
      'start_timer': 'INICIAR',
      'pause_timer': 'PAUSA',
      'add_task': 'Añadir tarea',
      'placeholder_add_task': 'Hacer coherencia cardíaca...',
      'placeholder_chat': 'Chatea con tu coach...',
      'aura_title': 'Aura',
      'aura_desc': 'Tu puntuación de bienestar está en 78% hoy. ¡Sigue así!',
      'quick_view': 'Resumen de su día',
      'remain_budget': 'RESTANTE PARA GASTAR ESTE MES',
      'budget_total': 'Presupuesto Total',
      'spent_amount': 'Gastado',
      'recent_trans': 'ULTIMAS TRANSACCIONES',
      'mood_title': 'TU ESTADO DE ANIMO HOY',
      'daily_tasks': 'Tareas diarias',
      'all_completed': '¡Todas las tareas completadas!',
      'recommended_focus': 'Enfoque recomendado',
      'start_action': 'Iniciar',
      'overall_progress': 'Progreso general',
      'claim_xp': 'VALIDAR Y RECLAMAR XP',
      'reward_claimed': 'RECOMPENSA RECLAMADA',
      'cat_label': 'Cat:',
      'prio_label': 'Prio:',
      'difficulty_easy': 'Fácil',
      'difficulty_medium': 'Medio',
      'difficulty_hard': 'Difícil',
      'category_daily': 'Diario',
      'category_weekly': 'Semanal',
      'category_special': 'Especial',
      'financial_stress': 'Estrés Financiero',
      'stress_index': 'Índice:',
      'savings_target': 'Objetivo de ahorro',
      'activity_streak': 'Racha de actividad',
      'streak_desc': '¡Mantente activo todos los días para aumentar tu racha!',
      'active_state': 'Activo',
      'recovery_action': 'Recomendación de recuperación de IA',
      'reduce_pomodoro': 'Reducir Pomodoro a 15m',
      'recover_5m': 'Recuperar 5 minutos',
      'validate_day': 'Bilan de hoy 🌸 (+30 XP)',
      'already_validated': '¡Día validado! 🔥',
      'agenda_title': 'Mi Agenda de Bienestar',
      'add_event': 'Añadir a la Agenda',
      'placeholder_event': 'Yoga, Gimnasio, Meditación...',
      'time_label': 'Hora:',
      'no_events': 'No hay eventos programados hoy.',
      'stats_title': 'Estadísticas Generales',
      'focus_hours': 'Horas de Enfoque',
      'challenges_completed': 'Desafíos Completados',
      'success_rate': 'Tasa de Éxito',
      'cardiac_coherence_short': 'Coherencia Card.',
      'device_options': 'Opciones del dispositivo',
      'onboarding_title': 'Complete su perfil',
      'onboarding_desc': 'Por favor, ingrese sus datos para personalizar su experiencia en Nexii.',
      'onboarding_name_label': 'Nombre completo',
      'onboarding_birthdate_label': 'Fecha de nacimiento',
      'onboarding_submit': 'Validar e iniciar',
      'edit_profile_btn': 'Editar mis datos',
      'edit_profile_title': 'Editar mi información',
      'save_profile_btn': 'Guardar cambios',
      'cancel_btn': 'Cancelar',
    }
  };

  String translate(String key) {
    String langCode = _currentLocale.languageCode;
    if (!_localizedValues.containsKey(langCode)) {
      langCode = 'fr';
    }
    return _localizedValues[langCode]?[key] ?? key;
  }

  Future<void> signOut() async {
    // Sign out logic
    notifyListeners();
  }
}

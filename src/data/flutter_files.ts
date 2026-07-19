export interface FlutterFile {
  path: string;
  name: string;
  category: string;
  code: string;
}

export const FLUTTER_FILES: FlutterFile[] = [
  {
    path: "pubspec.yaml",
    name: "pubspec.yaml",
    category: "Config",
    code: `name: nexii
description: A modular Flutter app for productivity, well-being, and financial management.

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  provider: ^6.1.1
  google_fonts: ^6.2.0
  cupertino_icons: ^1.0.6
  hive_ce: ^2.2.3
  hive_ce_flutter: ^2.2.3
  http: ^1.2.2
  audioplayers: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/translations/`
  },
  {
    path: "lib/app.dart",
    name: "app.dart",
    category: "Entrée",
    code: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/missions_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/profile_screen.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    if (!state.isFirebaseConnected) {
      return const LoginScreen();
    }
    if (!state.isOnboardingComplete) {
      return const OnboardingScreen();
    }
    return const MainNavigationScreen();
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MissionsScreen(),
    TasksScreen(),
    FocusScreen(),
    CoachScreen(),
    BudgetScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: state.translate('tab_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events_outlined),
            activeIcon: const Icon(Icons.emoji_events),
            label: state.translate('tab_missions'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.playlist_add_check_outlined),
            activeIcon: const Icon(Icons.playlist_add_check),
            label: state.translate('tab_tasks'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timer_outlined),
            activeIcon: const Icon(Icons.timer),
            label: state.translate('tab_focus'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.psychology_outlined),
            activeIcon: const Icon(Icons.psychology),
            label: state.translate('tab_coach'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: state.translate('tab_budget'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: state.translate('tab_profile'),
          ),
        ],
      ),
    );
  }
}`
  },
  {
    path: "lib/core/constants/colors.dart",
    name: "colors.dart",
    category: "Core",
    code: `import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xff2563eb);
  static const Color backgroundLight = Color(0xfff8fafc);
  static const Color backgroundDark = Color(0xff0f172a);
  static const Color success = Color(0xff22c55e);
  static const Color warning = Color(0xffef4444);
  static const Color aiAccent = Color(0xff8b5cf6);
  static const Color borderLight = Color(0xffe2e8f0);
  static const Color borderDark = Color(0xff334155);
}`
  },
  {
    path: "lib/core/services/firebase_service.dart",
    name: "firebase_service.dart",
    category: "Core",
    code: `import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseService {
  static const String projectId = "gen-lang-client-0771099958";
  static const String apiKey = "AIzaSyA6MWlv5N1FspAMQdrbyYVCLI6GE1JZ13g";
  static const String databaseId = "ai-studio-nexii-afbc11c1-d55d-412e-ad80-12b6a417fe2b";

  String? _idToken;
  String? _uid;
  String? _email;
  bool _isLoggedIn = false;

  String? get uid => _uid;
  String? get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  // Firebase Auth: Sign in with Email & Password
  Future<bool> signIn(String email, String password) async {
    final url = Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _idToken = data['idToken'];
        _uid = data['localId'];
        _email = data['email'];
        _isLoggedIn = true;
        return true;
      } else {
        print("Sign in failed: \${response.body}");
        return false;
      }
    } catch (e) {
      print("Error signing in: $e");
      return false;
    }
  }

  // Firebase Auth: Sign up with Email & Password
  Future<bool> signUp(String email, String password) async {
    final url = Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _idToken = data['idToken'];
        _uid = data['localId'];
        _email = data['email'];
        _isLoggedIn = true;
        return true;
      } else {
        print("Sign up failed: \${response.body}");
        return false;
      }
    } catch (e) {
      print("Error signing up: $e");
      return false;
    }
  }

  // Firebase Auth: Anonymous login
  Future<bool> signInAnonymously() async {
    final url = Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "returnSecureToken": true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _idToken = data['idToken'];
        _uid = data['localId'];
        _email = "anonymous@nexii.app";
        _isLoggedIn = true;
        return true;
      } else {
        print("Anonymous sign in failed: \${response.body}");
        return false;
      }
    } catch (e) {
      print("Error signing in anonymously: $e");
      return false;
    }
  }

  void signOut() {
    _idToken = null;
    _uid = null;
    _email = null;
    _isLoggedIn = false;
  }

  // Firestore REST: Fetch entire user profile / data
  Future<Map<String, dynamic>?> fetchUserData() async {
    if (!_isLoggedIn || _uid == null) return null;

    final url = Uri.parse(
      "https://firestore.googleapis.com/v1/projects/$projectId/databases/$databaseId/documents/users/$_uid"
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (_idToken != null) "Authorization": "Bearer $_idToken",
        },
      );

      if (response.statusCode == 200) {
        final doc = jsonDecode(response.body);
        final fields = doc['fields'] as Map<String, dynamic>?;
        if (fields != null) {
          final result = <String, dynamic>{};
          fields.forEach((key, value) {
            result[key] = _fromFirestoreValue(value as Map<String, dynamic>);
          });
          return result;
        }
        return {};
      } else if (response.statusCode == 404) {
        // Document doesn't exist yet
        return {};
      } else {
        print("Failed to fetch user data: \${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Firestore REST: Save/Set entire user profile / data
  Future<bool> saveUserData(Map<String, dynamic> data) async {
    if (!_isLoggedIn || _uid == null) return false;

    final url = Uri.parse(
      "https://firestore.googleapis.com/v1/projects/$projectId/databases/$databaseId/documents/users/$_uid"
    );

    try {
      final fields = <String, dynamic>{};
      data.forEach((key, value) {
        fields[key] = _toFirestoreValue(value);
      });

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          if (_idToken != null) "Authorization": "Bearer $_idToken",
        },
        body: jsonEncode({
          "fields": fields,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to save user data: \${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saving user data: $e");
      return false;
    }
  }

  // Firestore REST: Fetch all documents from a collection
  Future<List<Map<String, dynamic>>?> fetchCollection(String collectionName) async {
    final url = Uri.parse(
      "https://firestore.googleapis.com/v1/projects/$projectId/databases/$databaseId/documents/$collectionName"
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (_idToken != null) "Authorization": "Bearer $_idToken",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List?;
        if (documents == null) return [];
        
        final List<Map<String, dynamic>> list = [];
        for (var doc in documents) {
          final fields = doc['fields'] as Map<String, dynamic>?;
          final String docPath = doc['name'] as String;
          final String docId = docPath.split('/').last;
          if (fields != null) {
            final converted = <String, dynamic>{'id': docId};
            fields.forEach((key, value) {
              converted[key] = _fromFirestoreValue(value as Map<String, dynamic>);
            });
            list.add(converted);
          }
        }
        return list;
      } else {
        print("Failed to fetch collection $collectionName: \${response.statusCode} - \${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching collection $collectionName: $e");
      return null;
    }
  }

  // Firestore REST: Create document in a collection
  Future<Map<String, dynamic>?> createDocument(String collectionName, Map<String, dynamic> data) async {
    final url = Uri.parse(
      "https://firestore.googleapis.com/v1/projects/$projectId/databases/$databaseId/documents/$collectionName"
    );

    try {
      final fields = <String, dynamic>{};
      data.forEach((key, value) {
        fields[key] = _toFirestoreValue(value);
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (_idToken != null) "Authorization": "Bearer $_idToken",
        },
        body: jsonEncode({
          "fields": fields,
        }),
      );

      if (response.statusCode == 200) {
        final doc = jsonDecode(response.body);
        final fieldsData = doc['fields'] as Map<String, dynamic>?;
        final String docPath = doc['name'] as String;
        final String docId = docPath.split('/').last;
        if (fieldsData != null) {
          final result = <String, dynamic>{'id': docId};
          fieldsData.forEach((key, value) {
            result[key] = _fromFirestoreValue(value as Map<String, dynamic>);
          });
          return result;
        }
        return {'id': docId};
      } else {
        print("Failed to create document in $collectionName: \${response.body}");
        return null;
      }
    } catch (e) {
      print("Error creating document: $e");
      return null;
    }
  }

  // Firestore REST: Update document field values
  Future<bool> updateDocument(String collectionName, String documentId, Map<String, dynamic> data) async {
    final fieldsQuery = data.keys.map((k) => "updateMask.fieldPaths=$k").join("&");
    final url = Uri.parse(
      "https://firestore.googleapis.com/v1/projects/$projectId/databases/$databaseId/documents/$collectionName/$documentId?$fieldsQuery"
    );

    try {
      final fields = <String, dynamic>{};
      data.forEach((key, value) {
        fields[key] = _toFirestoreValue(value);
      });

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          if (_idToken != null) "Authorization": "Bearer $_idToken",
        },
        body: jsonEncode({
          "fields": fields,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to update document $documentId: \${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating document: $e");
      return false;
    }
  }

  // Firestore Map Converter: Dart Map to Firestore REST nested values
  static Map<String, dynamic> _toFirestoreValue(dynamic val) {
    if (val == null) return {'nullValue': null};
    if (val is String) return {'stringValue': val};
    if (val is bool) return {'booleanValue': val};
    if (val is double) return {'doubleValue': val};
    if (val is int) return {'integerValue': val.toString()};
    if (val is List) {
      return {
        'arrayValue': {
          'values': val.map((item) => _toFirestoreValue(item)).toList()
        }
      };
    }
    if (val is Map) {
      final fields = <String, dynamic>{};
      val.forEach((key, value) {
        fields[key.toString()] = _toFirestoreValue(value);
      });
      return {
        'mapValue': {'fields': fields}
      };
    }
    return {'stringValue': val.toString()};
  }

  // Firestore Map Converter: Firestore REST nested values to Dart Map
  static dynamic _fromFirestoreValue(Map<String, dynamic> firestoreVal) {
    if (firestoreVal.containsKey('nullValue')) return null;
    if (firestoreVal.containsKey('stringValue')) return firestoreVal['stringValue'];
    if (firestoreVal.containsKey('booleanValue')) return firestoreVal['booleanValue'];
    if (firestoreVal.containsKey('doubleValue')) return firestoreVal['doubleValue'];
    if (firestoreVal.containsKey('integerValue')) {
      return int.tryParse(firestoreVal['integerValue']) ?? double.tryParse(firestoreVal['integerValue']) ?? 0;
    }
    if (firestoreVal.containsKey('arrayValue')) {
      final list = firestoreVal['arrayValue']['values'] as List?;
      if (list == null) return [];
      return list.map((item) => _fromFirestoreValue(item as Map<String, dynamic>)).toList();
    }
    if (firestoreVal.containsKey('mapValue')) {
      final fields = firestoreVal['mapValue']['fields'] as Map<String, dynamic>?;
      if (fields == null) return {};
      final result = <String, dynamic>{};
      fields.forEach((key, value) {
        result[key] = _fromFirestoreValue(value as Map<String, dynamic>);
      });
      return result;
    }
    return null;
  }
}
`
  },
  {
    path: "lib/core/theme/app_theme.dart",
    name: "app_theme.dart",
    category: "Core",
    code: `import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xff2563eb);
  static const Color backgroundColorLight = Color(0xfff8fafc);
  static const Color backgroundColorDark = Color(0xff0f172a);
  static const Color successColor = Color(0xff22c55e);
  static const Color warningColor = Color(0xffef4444);
  static const Color aiAccentColor = Color(0xff8b5cf6);
  static const Color borderColorLight = Color(0xffe2e8f0);
  static const Color borderColorDark = Color(0xff334155);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColorLight,
      cardColor: Colors.white,
      dividerColor: borderColorLight,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: const Color(0xff0f172a),
        ),
        titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: const Color(0xff0f172a),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xff475569),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: aiAccentColor,
        surface: backgroundColorLight,
        onPrimary: Colors.white,
        onError: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Color(0xff94a3b8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColorDark,
      cardColor: const Color(0xff1e293b),
      dividerColor: borderColorDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xff94a3b8),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: aiAccentColor,
        surface: backgroundColorDark,
        onPrimary: Colors.white,
        onError: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xff0f172a),
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xff475569),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}`
  },
  {
    path: "lib/core/theme/nexii_colors.dart",
    name: "nexii_colors.dart",
    category: "Core",
    code: `import 'package:flutter/material.dart';

class NexiiColors {
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color info = Color(0xFF3B82F6);
}
`
  },
  {
    path: "lib/core/utils/helpers.dart",
    name: "helpers.dart",
    category: "Core",
    code: `import 'package:flutter/material.dart';

class AppHelpers {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static String formatCurrency(double value) {
    return '\${value.toStringAsFixed(2)} €';
  }
}`
  },
  {
    path: "lib/main.dart",
    name: "main.dart",
    category: "Entrée",
    code: `import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const NexiiApp(),
    ),
  );
}

class NexiiApp extends StatelessWidget {
  const NexiiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return MaterialApp(
      title: 'Nexii',
      debugShowCheckedModeBanner: false,
      themeMode: state.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: state.currentLocale,
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppEntry(),
    );
  }
}`
  },
  {
    path: "lib/navigation/bottom_navigation.dart",
    name: "bottom_navigation.dart",
    category: "Navigation",
    code: `import 'package:flutter/material.dart';

class NexiiBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const NexiiBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
    );
  }
}`
  },
  {
    path: "lib/providers/app_state_provider.dart",
    name: "app_state_provider.dart",
    category: "Providers",
    code: `import 'dart:convert';
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
        return '\${baseUri.scheme}://\${baseUri.host}:\${baseUri.port}';
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
          'time': post['time'] ?? 'À l\\'instant',
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
      'time': 'À l\\'instant',
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
      'description': 'Prenez du recul et respirez profondément pour calmer l\\'esprit.',
      'progress': 1.0,
      'isCompleted': true,
      'claimed': false
    },
    {
      'id': '2',
      'title': 'Limiter le budget loisirs',
      'xp': 120,
      'description': 'Évitez les dépenses superflues aujourd\\'hui.',
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
          'text': 'Bonjour $name ! Je suis Nexii, ton coach de vie IA. Comment puis-je t\\'accompagner aujourd\\'hui dans ton équilibre quotidien ? 🧘‍♂️✨',
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
      reply = "Pas de panique ! En analysant vos objectifs de la journée, je vous propose de commencer par la tâche la plus simple et à haute énergie. Que diriez-vous de débuter par : '\${_tasks.isNotEmpty ? _tasks.first['title'] : 'Rédiger l\\'introduction du projet'}' ?";
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
          ? 'Trop de stress ou de tâches en suspens. Laissez tomber le superflu pour aujourd\\'hui !'
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
      'sound_picker': 'Sons d\\'Ambiance',
      'start_timer': 'DÉMARRER',
      'pause_timer': 'PAUSE',
      'add_task': 'Ajouter une tâche',
      'placeholder_add_task': 'Faire de la cohérence cardiaque...',
      'placeholder_chat': 'Discutez avec votre coach...',
      'aura_title': 'Aura',
      'aura_desc': 'Votre score de bien-être est à 78% aujourd\\'hui. Continuez ainsi !',
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
      'savings_target': 'Cible d\\'épargne',
      'activity_streak': 'Série d\\'activité',
      'streak_desc': 'Restez actif chaque jour pour augmenter votre série !',
      'active_state': 'Actif',
      'recovery_action': 'Temps de récupération suggéré par l\\'IA',
      'reduce_pomodoro': 'Réduire Pomodoro à 15m',
      'recover_5m': 'Récupérer 5 minutes',
      'validate_day': 'Faire mon Bilan / Check-In 🌸 (+30 XP)',
      'already_validated': 'Journée validée ! 🔥',
      'agenda_title': 'Mon Agenda Bien-être',
      'add_event': 'Ajouter à l\\'agenda',
      'placeholder_event': 'Séance Yoga, Gym, Méditer...',
      'time_label': 'Heure :',
      'no_events': 'Aucun événement prévu pour ce jour.',
      'stats_title': 'Statistiques Générales',
      'focus_hours': 'Heures Focus',
      'challenges_completed': 'Défis Réussis',
      'success_rate': 'Taux Réussite',
      'cardiac_coherence_short': 'Cohérence Card.',
      'device_options': 'Options de l\\'appareil',
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
`
  },
  {
    path: "lib/screens/budget_screen.dart",
    name: "budget_screen.dart",
    category: "Screens",
    code: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _budgetLimitController = TextEditingController();
  String _selectedCategory = 'Alimentation';
  bool _isExpense = true;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _budgetLimitController.dispose();
    super.dispose();
  }

  void _showAddTransactionDialog(BuildContext context, AppStateProvider state) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Ajouter une transaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre de la transaction',
                        hintText: 'Supermarché, Salaire, Cafétéria...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Montant (FCFA)',
                        hintText: '5000',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Dépense'),
                            selected: _isExpense,
                            selectedColor: const Color(0xffef4444).withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: _isExpense ? const Color(0xffef4444) : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              setDialogState(() {
                                _isExpense = true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Revenu'),
                            selected: !_isExpense,
                            selectedColor: const Color(0xff22c55e).withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: !_isExpense ? const Color(0xff22c55e) : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              setDialogState(() {
                                _isExpense = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            _selectedCategory = val;
                          });
                        }
                      },
                      items: ['Alimentation', 'Loisirs', 'Abonnements', 'Transport', 'Santé', 'Salaire', 'Autre']
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(state.translate('cancel_btn')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    final amountText = _amountController.text.trim();
                    final amount = double.tryParse(amountText);

                    if (title.isNotEmpty && amount != null && amount > 0) {
                      state.addTransaction(title, amount, _selectedCategory, _isExpense);
                      _titleController.clear();
                      _amountController.clear();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBudgetLimitDialog(BuildContext context, AppStateProvider state) {
    _budgetLimitController.text = state.totalBudget.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Définir le Budget Mensuel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez votre limite budgétaire globale pour ce mois en FCFA.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _budgetLimitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: InputDecoration(
                  labelText: 'Limite du Budget (FCFA)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(state.translate('cancel_btn')),
            ),
            ElevatedButton(
              onPressed: () {
                final text = _budgetLimitController.text.trim();
                final val = double.tryParse(text);
                if (val != null && val >= 0) {
                  state.updateBudget(val);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563eb),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    double progress = 0.0;
    if (state.totalBudget > 0) {
      progress = (state.spentBudget / state.totalBudget).clamp(0.0, 1.0);
    }

    // Stress index based on spending percentage
    double stressIndex = (progress * 10).clamp(0.0, 10.0);
    String stressLabel = "Calme";
    Color stressColor = const Color(0xff22c55e);

    if (stressIndex > 7.5) {
      stressLabel = "Stress Élevé";
      stressColor = const Color(0xffef4444);
    } else if (stressIndex > 4.5) {
      stressLabel = "Vigilance";
      stressColor = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Color(0xff22c55e)),
            const SizedBox(width: 8),
            Text(
              state.translate('budget_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget Main Visual Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            state.translate('remain_budget'),
                            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, size: 18, color: Colors.grey),
                          onPressed: () => _showEditBudgetLimitDialog(context, state),
                          tooltip: 'Modifier la limite',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\${state.remainingBudget.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: state.remainingBudget >= 0 ? const Color(0xff22c55e) : const Color(0xffef4444),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat(state.translate('budget_total'), '\${state.totalBudget.toStringAsFixed(0)} FCFA'),
                        _buildMiniStat(state.translate('spent_amount'), '\${state.spentBudget.toStringAsFixed(0)} FCFA'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Theme.of(context).dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.8 ? const Color(0xffef4444) : const Color(0xff2563eb),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stress Financier Indicator Card (matches React)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: stressColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.bolt, color: stressColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.translate('financial_stress'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Calculé par rapport au rythme d\\'achat',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          stressLabel,
                          style: TextStyle(fontWeight: FontWeight.bold, color: stressColor, fontSize: 13),
                        ),
                        Text(
                          'Indice : \${stressIndex.toStringAsFixed(1)}/10',
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.translate('recent_trans'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xff22c55e)),
                    onPressed: () => _showAddTransactionDialog(context, state),
                  )
                ],
              ),
              const SizedBox(height: 12),

              // Transaction List
              if (state.transactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      'Aucune transaction enregistrée.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = state.transactions[index];
                    final String title = tx['title'] ?? '';
                    final double amount = (tx['amount'] as num).toDouble();
                    final String category = tx['category'] ?? 'Autre';
                    final bool isNegative = tx['isNegative'] ?? true;

                    final amountSign = isNegative ? '-' : '+';
                    final amountText = "$amountSign\${amount.abs().toStringAsFixed(0)} FCFA";

                    return _buildTransactionTile(
                      context,
                      title,
                      amountText,
                      category,
                      isNegative,
                      onDelete: () {
                        state.deleteTransaction(index);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, state),
        backgroundColor: const Color(0xff22c55e),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    String title,
    String amount,
    String subtitle,
    bool isNegative, {
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isNegative ? const Color(0xffef4444).withOpacity(0.1) : const Color(0xff22c55e).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isNegative ? Icons.trending_down : Icons.trending_up,
            color: isNegative ? const Color(0xffef4444) : const Color(0xff22c55e),
            size: 18,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isNegative ? const Color(0xffef4444) : const Color(0xff22c55e),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
`
  },
  {
    path: "lib/screens/coach_screen.dart",
    name: "coach_screen.dart",
    category: "Screens",
    code: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVoiceMode = false;
  bool _isSimulatingSpeech = false;

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(AppStateProvider state) {
    final text = _chatController.text.trim();
    if (text.isNotEmpty) {
      state.sendMessage(text);
      _chatController.clear();
      _scrollToBottom();
      
      // Delay to scroll again after simulated reply starts typing/responding
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
      Future.delayed(const Duration(milliseconds: 1600), () {
        _scrollToBottom();
      });
    }
  }

  String _getLatestCoachMessage(AppStateProvider state) {
    if (state.messages.isEmpty) {
      return "Salut ! Je t'écoute. Comment te sens-tu aujourd'hui ?";
    }
    for (int i = state.messages.length - 1; i >= 0; i--) {
      final msg = state.messages[i];
      if (msg['isUser'] == false) {
        return msg['text'] as String;
      }
    }
    return "Salut ! Je t'écoute. Comment te sens-tu aujourd'hui ?";
  }

  void _simulateVoiceCommand(AppStateProvider state) {
    if (_isSimulatingSpeech) return;
    
    final simulatedInputs = [
      "Je me sens un peu fatigué aujourd'hui mais j'ai des devoirs importants à rendre.",
      "Aujourd'hui, j'ai une énergie au top ! Planifie mes tâches les plus dures.",
      "Je me sens stressé par mon budget."
    ];
    
    // Pick a random input
    final random = DateTime.now().millisecond % simulatedInputs.length;
    final randomInput = simulatedInputs[random];
    
    setState(() {
      _isSimulatingSpeech = true;
    });
    
    // Send user message and trigger response in State Provider
    state.sendMessage("🎤 [Vocal User] \\"$randomInput\\"");
    
    // After 1.5s, complete simulation animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isSimulatingSpeech = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // Call scroll on build if list changes and in chat mode
    if (!_isVoiceMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.psychology, color: Color(0xff8b5cf6)),
            const SizedBox(width: 8),
            Text(
              state.translate('coach_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceMode ? Icons.chat_bubble : Icons.mic,
              color: const Color(0xff8b5cf6),
            ),
            onPressed: () {
              setState(() {
                _isVoiceMode = !_isVoiceMode;
                if (_isVoiceMode) {
                  // Pre-fill voice greeting if last message isn't already vocal
                  final latest = _getLatestCoachMessage(state);
                  if (!latest.startsWith('🎤')) {
                    state.sendMessage("🎤 [Coach Vocal] Salut ! Je t'écoute. Comment te sens-tu aujourd'hui ?");
                  }
                }
              });
            },
            tooltip: _isVoiceMode ? 'Passer en mode Chat' : 'Passer en mode Vocal',
          )
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isVoiceMode) ...[
              // Vocal dashboard Layout
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xff8b5cf6).withOpacity(0.12),
                        const Color(0xff2563eb).withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xff8b5cf6).withOpacity(0.25)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulsing Mic Icon
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: const Color(0xff8b5cf6).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff8b5cf6), Color(0xff3b82f6)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff8b5cf6).withOpacity(0.35),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.mic, color: Colors.white, size: 36),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Status Texts
                      Text(
                        _isSimulatingSpeech ? 'Nexii écoute...' : 'Nexii Vocal est à l\\'écoute...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff8b5cf6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Exprimez-vous ou simulez une commande vocale pour continuer',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      
                      // Waveform Animation
                      WaveformBouncer(active: !_isSimulatingSpeech),
                      const SizedBox(height: 24),
                      
                      // Latest response bubble
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.record_voice_over, size: 14, color: Color(0xff8b5cf6)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Réponse du Coach Vocal :',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff8b5cf6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getLatestCoachMessage(state),
                                  style: const TextStyle(fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Simuler button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2563eb),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.record_voice_over, size: 18),
                        label: const Text(
                          'Simuler une commande vocale',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: () {
                          _simulateVoiceCommand(state);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // AI coach header tip
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff8b5cf6).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xff8b5cf6).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xff8b5cf6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.spa, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Compagnon IA Nexii',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff8b5cf6)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Je suis là pour vous aider à équilibrer votre vie, gérer vos émotions et atteindre vos buts calmement.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Messages list
              Expanded(
                child: state.messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun message. Dites bonjour à votre coach !',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          final bool isUser = msg['isUser'] as bool;
                          final String text = msg['text'] as String;
                          return _buildMessageBubble(context, text: text, isUser: isUser);
                        },
                      ),
              ),

              // Typing Indicator
              if (state.isCoachTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff8b5cf6)),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Le coach réfléchit...',
                              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Chat entry box
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: TextField(
                          controller: _chatController,
                          onSubmitted: (_) => _handleSend(state),
                          decoration: InputDecoration(
                            hintText: state.translate('placeholder_chat'),
                            hintStyle: const TextStyle(fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xff2563eb),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: () => _handleSend(state),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, {required String text, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser 
              ? const Color(0xff2563eb) 
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: isUser 
              ? null 
              : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class WaveformBouncer extends StatefulWidget {
  final bool active;
  const WaveformBouncer({super.key, required this.active});

  @override
  State<WaveformBouncer> createState() => _WaveformBouncerState();
}

class _WaveformBouncerState extends State<WaveformBouncer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.active) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WaveformBouncer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(15, (index) {
            final double progress = _controller.value;
            final double factor = (index % 3 + 1) * 0.3;
            double heightFactor = 0.2 + 0.8 * (0.5 + 0.5 * progress * factor);
            if (heightFactor > 1.0) heightFactor = 1.0;
            if (!widget.active) heightFactor = 0.2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: 4,
              height: 25 * heightFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xff8b5cf6),
                    Color(0xff3b82f6),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
`
  },
  {
    path: "lib/screens/focus_screen.dart",
    name: "focus_screen.dart",
    category: "Screens",
    code: `import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/app_state_provider.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 1500; // 25 minutes default
  bool _isRunning = false;
  String _mode = 'Pomodoro'; // 'Pomodoro' or 'Coherence'
  
  // Audio Players
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _chimePlayer = AudioPlayer();

  final Map<String, String> _soundUrls = {
    'Pluie': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'Océan': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    'Forêt Zen': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
    'Feu de Bois': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
    'Bruit Blanc': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
  };
  final String _chimeUrl = 'https://assets.mixkit.co/active_storage/sfx/911/911-84.wav';

  // For Cardiac Coherence Breathing Animation
  AnimationController? _breathController;
  Animation<double>? _breathAnimation;
  String _breathText = 'Inspirez'; // 'Inspirez' (Inhale) or 'Expirez' (Exhale)

  @override
  void initState() {
    super.initState();
    _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    _initBreathingAnimation();
  }

  void _initBreathingAnimation() {
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _breathAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breathController!, curve: Curves.easeInOut),
    );

    _breathController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _breathText = 'Expirez';
        });
        _playChime();
        _breathController!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _breathText = 'Inspirez';
        });
        _playChime();
        _breathController!.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController?.dispose();
    _ambientPlayer.dispose();
    _chimePlayer.dispose();
    super.dispose();
  }

  void _playAmbient(String sound) async {
    final url = _soundUrls[sound];
    if (url != null) {
      try {
        await _ambientPlayer.stop();
        await _ambientPlayer.play(UrlSource(url));
      } catch (e) {
        debugPrint('Error playing ambient audio: $e');
      }
    }
  }

  void _stopAmbient() async {
    try {
      await _ambientPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping ambient audio: $e');
    }
  }

  void _playChime() async {
    try {
      await _chimePlayer.stop();
      await _chimePlayer.play(UrlSource(_chimeUrl));
    } catch (e) {
      debugPrint('Error playing chime: $e');
    }
  }

  void _startTimer(AppStateProvider state) {
    if (_isRunning) return;

    _timer?.cancel(); // Cancel any existing timer before starting a new one

    setState(() {
      _isRunning = true;
    });

    _playAmbient(state.selectedSound);

    if (_mode == 'Coherence') {
      _playChime();
      _breathController!.forward();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _stopTimer();
        // Finished! Add focus minutes
        final mins = _mode == 'Pomodoro' ? 25 : 2;
        state.addFocusMinutes(mins);
        
        // Push local in-app notification
        state.addNotification(
          _mode == 'Pomodoro' ? 'Concentration Complétée 🍅' : 'Cohérence Réussie 🧘',
          _mode == 'Pomodoro'
              ? 'Excellent ! Vous avez complété une session de concentration de $mins minutes (+50 XP).'
              : 'Félicitations ! Vous avez complété une session de respiration de $mins minutes (+4 XP).',
          _mode == 'Pomodoro' ? 'success' : 'info',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mode == 'Pomodoro'
                ? 'Excellent ! Session Pomodoro complétée (+25 min, +50 XP)'
                : 'Session Cohérence Cardiaque complétée (+2 min, +4 XP)'),
            backgroundColor: const Color(0xff22c55e),
          ),
        );
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _breathController?.stop();
    _stopAmbient();
    setState(() {
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _breathController?.reset();
    _stopAmbient();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _mode == 'Pomodoro' ? 1500 : 120;
    });
  }

  void _toggleMode(String newMode) {
    _pauseTimer();
    setState(() {
      _mode = newMode;
      _secondsRemaining = newMode == 'Pomodoro' ? 1500 : 120;
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '\${mins.toString().padLeft(2, '0')}:\${secs.toString().padLeft(2, '0')}';
  }

  void _showSoundPicker(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final sounds = ['Pluie', 'Océan', 'Forêt Zen', 'Feu de Bois', 'Bruit Blanc'];
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.translate('sound_picker'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ...sounds.map((sound) {
                  final isSelected = state.selectedSound == sound;
                  return ListTile(
                    leading: Icon(
                      Icons.music_note,
                      color: isSelected ? const Color(0xff8b5cf6) : Colors.grey,
                    ),
                    title: Text(
                      sound,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xff8b5cf6) : null,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xff8b5cf6)) : null,
                    onTap: () {
                      state.setSound(sound);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.timer, color: Color(0xff8b5cf6)),
            const SizedBox(width: 8),
            Text(
              state.translate('focus_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mode Selectors
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton('Pomodoro', _mode == 'Pomodoro'),
                    const SizedBox(width: 12),
                    _buildModeButton('Coherence', _mode == 'Coherence'),
                  ],
                ),
                const SizedBox(height: 40),

                // Timer Visual Ring or Cardiac breathing circle
                _mode == 'Coherence' && _isRunning
                    ? AnimatedBuilder(
                        animation: _breathAnimation!,
                        builder: (context, child) {
                          return Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xff8b5cf6).withOpacity(0.1 * _breathAnimation!.value),
                              border: Border.all(
                                color: const Color(0xff8b5cf6).withOpacity(0.3 * _breathAnimation!.value),
                                width: 4.0 + (16.0 * _breathAnimation!.value),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff8b5cf6).withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 10 * _breathAnimation!.value,
                                )
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _breathText,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff8b5cf6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatTime(_secondsRemaining),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: const Color(0xff8b5cf6).withOpacity(0.2),
                            width: 10,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff8b5cf6).withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTime(_secondsRemaining),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _mode == 'Pomodoro' ? 'Focus Actif' : 'Cohérence Card.',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 40),

                // Sound selector
                GestureDetector(
                  onTap: () => _showSoundPicker(context, state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.music_note, color: Color(0xff8b5cf6), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          state.selectedSound,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.rotate_left, size: 28),
                      onPressed: _stopTimer,
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? Colors.amber : const Color(0xff2563eb),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 2,
                      ),
                      onPressed: _isRunning ? _pauseTimer : () => _startTimer(state),
                      child: Text(
                        _isRunning ? 'PAUSE' : 'DÉMARRER',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 28),
                      onPressed: () {
                        setState(() {
                          _secondsRemaining = 0;
                        });
                        _startTimer(state); // will trigger finish next second
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String modeName, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleMode(modeName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff8b5cf6) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xff8b5cf6) : Colors.grey.shade400,
          ),
        ),
        child: Text(
          modeName == 'Coherence' ? 'Cohérence Cardiaque' : 'Pomodoro',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
`
  },
  {
    path: "lib/screens/home_screen.dart",
    name: "home_screen.dart",
    category: "Screens",
    code: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _agendaController = TextEditingController();
  bool _hasMadeWish = false;

  @override
  void dispose() {
    _agendaController.dispose();
    super.dispose();
  }

  void _showNotificationsBottomSheet(BuildContext context, AppStateProvider state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final unreadCount = state.notifications.where((n) => n['read'] == false).length;
            
            return FractionallySizedBox(
              heightFactor: 0.75,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active, color: Color(0xff8b5cf6)),
                              const SizedBox(width: 8),
                              const Text(
                                'Notifications',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$unreadCount non lues',
                                    style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Actions row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: state.notifications.isEmpty ? null : () {
                              state.markAllNotificationsAsRead();
                              setModalState(() {});
                            },
                            child: const Text('Tout marquer lu', style: TextStyle(color: Color(0xff8b5cf6), fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: state.notifications.isEmpty ? null : () {
                              state.clearAllNotifications();
                              setModalState(() {});
                            },
                            child: const Text('Tout effacer', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      // Notification List
                      Expanded(
                        child: state.notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    const Text('Aucune notification pour le moment', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.notifications.length,
                                itemBuilder: (context, index) {
                                  final n = state.notifications[index];
                                  final isUnread = n['read'] == false;
                                  
                                  // Determine type icon & color
                                  IconData iconData = Icons.info_outline;
                                  Color typeColor = Colors.blue;
                                  if (n['type'] == 'success') {
                                    iconData = Icons.check_circle_outline;
                                    typeColor = Colors.green;
                                  } else if (n['type'] == 'warning') {
                                    iconData = Icons.warning_amber_outlined;
                                    typeColor = Colors.amber;
                                  } else if (n['type'] == 'xp') {
                                    iconData = Icons.star_border;
                                    typeColor = Colors.purple;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isUnread 
                                          ? const Color(0xff8b5cf6).withOpacity(0.04)
                                          : Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isUnread 
                                            ? const Color(0xff8b5cf6).withOpacity(0.15)
                                            : Theme.of(context).dividerColor.withOpacity(0.5),
                                        width: isUnread ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: typeColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(iconData, color: typeColor, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      n['title'] ?? '',
                                                      style: TextStyle(
                                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isUnread)
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      decoration: const BoxDecoration(
                                                        color: Color(0xff8b5cf6),
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                n['content'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                n['date'] != null 
                                                    ? DateTime.parse(n['date']).toLocal().toString().substring(0, 16)
                                                    : '',
                                                style: TextStyle(
                                                  color: Colors.grey.shade400,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate task completion rate
    double completionRate = 0.0;
    if (state.tasks.isNotEmpty) {
      final completed = state.tasks.where((t) => t['isCompleted'] == true).length;
      completionRate = (completed / state.tasks.length) * 100;
    }

    // Completed challenges
    final completedChallenges = state.missions.where((m) => m['isCompleted'] == true || m['claimed'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xff2563eb)),
            const SizedBox(width: 8),
            Text(
              state.translate('app_name'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Notification Bell Icon with dynamic Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 24),
                onPressed: () => _showNotificationsBottomSheet(context, state),
              ),
              if (state.notifications.where((n) => n['read'] == false).isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: Chip(
              label: Text(
                'Niv. \${state.level}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              backgroundColor: const Color(0xff8b5cf6).withOpacity(0.1),
              side: const BorderSide(color: Color(0xff8b5cf6), width: 0.5),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome text
              Text(
                '\${state.translate('welcome_back')}\${state.profileName.isNotEmpty ? ", \${state.profileName}" : ""}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                state.translate('calm_message'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              if (state.isTodayBirthday) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xfff59e0b), Color(0xffec4899), Color(0xff8b5cf6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffec4899).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '🎉 🎂 🎈',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.translate('birthday_title'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.translate('birthday_desc'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_hasMadeWish)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xffec4899),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.star, color: Color(0xfff59e0b)),
                            label: Text(
                              state.translate('birthday_action'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () {
                              setState(() {
                                _hasMadeWish = true;
                              });
                              state.addFocusMinutes(10); // Award XP and minutes as a gift
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.translate('birthday_wish_success')),
                                  backgroundColor: const Color(0xffec4899),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                state.translate('birthday_wish_success'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              // Aura Status Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff2563eb), Color(0xff8b5cf6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff2563eb).withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.spa, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '\${state.translate('aura_title')} (\${state.auraLabel})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.auraDescription,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 68,
                          height: 68,
                          child: CircularProgressIndicator(
                            value: state.auraPercentage / 100,
                            strokeWidth: 6,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff22c55e)),
                          ),
                        ),
                        Text(
                          '\${state.auraPercentage.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Streak & Validation Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_fire_department, color: Colors.amber, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.translate('activity_streak'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.translate('streak_desc'),
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\${state.streak} \${state.translate('active_state')}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isDayValidated ? null : () => state.validateDay(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2563eb),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xff22c55e).withOpacity(0.2),
                          disabledForegroundColor: const Color(0xff22c55e),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          state.isDayValidated
                              ? state.translate('already_validated')
                              : state.translate('validate_day'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 😊 Check-in Quotidien Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: state.hasCheckedInToday 
                      ? const Color(0xff22c55e).withOpacity(0.08)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: state.hasCheckedInToday 
                        ? const Color(0xff22c55e).withOpacity(0.2)
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: state.hasCheckedInToday
                    ? Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xff22c55e), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bilan quotidien complété !',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff16a34a)),
                                ),
                                Text(
                                  'Humeur : \${state.dailyMood}/5 • Énergie : \${state.dailyEnergy}/5 • Stress : \${state.dailyStress}/5',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emoji_emotions, color: Color(0xffeab308), size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Check-in Quotidien',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Prenez 10 secondes pour évaluer votre état afin que le Coach IA ajuste votre journée.',
                            style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.3),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _showCheckInDialog(context, state);
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: Color(0xff2563eb)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: const Text(
                                'Faire mon bilan',
                                style: TextStyle(color: Color(0xff2563eb), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 20),

              // Overview Header
              Text(
                state.translate('quick_view'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Overview List (Tasks Completion Indicator)
              _buildOverviewCard(
                context,
                icon: Icons.playlist_add_check,
                iconColor: const Color(0xff2563eb),
                title: '\${state.tasks.length} \${state.translate('daily_tasks')}',
                subtitle: state.tasks.isNotEmpty
                    ? state.tasks.map((t) => t['title']).join(' • ')
                    : state.translate('all_completed'),
                trailing: '\${completionRate.toInt()}%',
              ),
              const SizedBox(height: 12),

              // Focus recommendation
              _buildOverviewCard(
                context,
                icon: Icons.timer,
                iconColor: const Color(0xff8b5cf6),
                title: state.translate('recommended_focus'),
                subtitle: '25 mins • Ambiance \${state.selectedSound}',
                trailing: state.translate('start_action'),
              ),
              const SizedBox(height: 24),

              // Objectives (Objectifs) Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🎯 Vos Objectifs Actifs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xff2563eb)),
                    onPressed: () {
                      _showAddGoalDialog(context, state);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: state.goals.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'Aucun objectif actif. Ajoutez-en un !',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                    : Column(
                        children: state.goals.map<Widget>((goal) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                _showEditGoalDialog(context, state, goal);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            goal['title'] as String,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '\${((goal['progress'] as num) * 100).toInt()}%',
                                          style: const TextStyle(color: Color(0xff2563eb), fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (goal['progress'] as num).toDouble(),
                                        minHeight: 6,
                                        backgroundColor: Colors.grey.withOpacity(0.1),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff2563eb)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // Agenda Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.translate('agenda_title'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),

              // Agenda Items
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    if (state.agendaEvents.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          state.translate('no_events'),
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    else
                      ...state.agendaEvents.map((event) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xff2563eb).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  event['time'] ?? '08:00',
                                  style: const TextStyle(
                                    color: Color(0xff2563eb),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  event['title'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const Divider(height: 24),
                    // Quick add agenda
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _agendaController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: state.translate('placeholder_event'),
                              hintStyle: const TextStyle(fontSize: 12),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xff2563eb)),
                          onPressed: () {
                            final text = _agendaController.text.trim();
                            if (text.isNotEmpty) {
                              // Generate random hour/time
                              final hour = 8 + (state.agendaEvents.length * 2) % 12;
                              final timeStr = "\${hour.toString().padLeft(2, '0')}:00";
                              state.addAgendaEvent(text, timeStr);
                              _agendaController.clear();
                            }
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // General Stats block
              Text(
                state.translate('stats_title'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildStatItem(context, state.translate('focus_hours'), '\${(state.focusMinutesTotal / 60).toStringAsFixed(1)} h', Icons.access_time),
                  const SizedBox(width: 12),
                  _buildStatItem(context, state.translate('challenges_completed'), '$completedChallenges', Icons.emoji_events),
                  const SizedBox(width: 12),
                  _buildStatItem(context, state.translate('success_rate'), '\${completionRate.toInt()}%', Icons.trending_up),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xff2563eb).withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
                color: Color(0xff2563eb),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String val, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xff2563eb)),
            const SizedBox(height: 8),
            Text(
              val,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckInDialog(BuildContext context, AppStateProvider state) {
    int mood = 3;
    int energy = 3;
    int motivation = 3;
    int stress = 3;
    int sleep = 3;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildRatingRow(String label, int currentVal, Function(int) onChanged) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$label : $currentVal/5', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final val = index + 1;
                      final isSelected = val == currentVal;
                      return IconButton(
                        icon: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          color: isSelected ? const Color(0xffeab308) : Colors.grey,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            onChanged(val);
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Check-in Quotidien', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildRatingRow('Humeur', mood, (v) => mood = v),
                    buildRatingRow('Énergie', energy, (v) => energy = v),
                    buildRatingRow('Motivation', motivation, (v) => motivation = v),
                    buildRatingRow('Stress', stress, (v) => stress = v),
                    buildRatingRow('Sommeil', sleep, (v) => sleep = v),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.submitDailyCheckIn(mood, energy, motivation, stress, sleep);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddGoalDialog(BuildContext context, AppStateProvider state) {
    final titleController = TextEditingController();
    String category = 'Scolaire';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Ajouter un Objectif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Ex: Finir mon projet d\\'art',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          category = val;
                        });
                      }
                    },
                    items: ['Scolaire', 'Professionnel', 'Financier', 'Sportif', 'Personnel']
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isNotEmpty) {
                      state.addGoal(title, category);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditGoalDialog(BuildContext context, AppStateProvider state, Map<String, dynamic> goal) {
    double progress = (goal['progress'] as num).toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(goal['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catégorie: \${goal['category']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  Text('Progression: \${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Slider(
                    value: progress,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) {
                      setDialogState(() {
                        progress = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    state.deleteGoal(goal['id'] as String);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Objectif supprimé')),
                    );
                  },
                  child: const Text('Supprimer', style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.updateGoalProgress(goal['id'] as String, progress);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
`
  },
  {
    path: "lib/screens/login_screen.dart",
    name: "login_screen.dart",
    category: "Screens",
    code: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppStateProvider state) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool success = false;

    if (_isSignUp) {
      success = await state.registerWithEmail(email, password);
    } else {
      success = await state.loginWithEmail(email, password);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (!success) {
        setState(() {
          _errorMessage = _isSignUp
              ? "L'inscription a échoué. Veuillez vérifier vos informations ou si le compte existe déjà."
              : "La connexion a échoué. Veuillez vérifier votre e-mail et votre mot de passe.";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSignUp ? 'Inscription réussie !' : 'Connexion réussie !'),
            backgroundColor: const Color(0xff22c55e),
          ),
        );
      }
    }
  }

  Future<void> _continueAsGuest(AppStateProvider state) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final success = await state.continueAnonymously();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (!success) {
        setState(() {
          _errorMessage = "Impossible d'initier le mode invité.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xff6366f1); // Modern Indigo

    return Scaffold(
      backgroundColor: isDark ? const Color(0xff0f172a) : const Color(0xfff8fafc),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding Logo with premium App-Icon style
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff1e293b) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(4), // Subtle inner padding
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // High-quality fallback if asset is missing or loading
                            return Container(
                              color: primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.auto_awesome,
                                size: 40,
                                color: primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nexii',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontFamily: 'Montserrat',
                      color: isDark ? Colors.white : const Color(0xff1e293b),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Votre compagnon de productivité, bien-être et budget',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xff94a3b8) : const Color(0xff64748b),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Mode Tab Selector with glassmorphism/pill style
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isSignUp = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isSignUp 
                                    ? (isDark ? const Color(0xff0f172a) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isSignUp ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                              child: Text(
                                'Se connecter',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: !_isSignUp 
                                      ? (isDark ? Colors.white : const Color(0xff1e293b))
                                      : (isDark ? const Color(0xff64748b) : const Color(0xff64748b)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isSignUp = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isSignUp 
                                    ? (isDark ? const Color(0xff0f172a) : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isSignUp ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                              child: Text(
                                "S'inscrire",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _isSignUp 
                                      ? (isDark ? Colors.white : const Color(0xff1e293b))
                                      : (isDark ? const Color(0xff64748b) : const Color(0xff64748b)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xffef4444).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xffef4444).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xffef4444), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Color(0xffef4444),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email input
                  Text(
                    'Adresse E-mail',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 11, 
                      color: isDark ? const Color(0xff64748b) : const Color(0xff64748b),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'votre.email@domaine.com',
                      prefixIcon: Icon(Icons.email_outlined, color: primaryColor.withOpacity(0.7)),
                      filled: true,
                      fillColor: isDark ? const Color(0xff1e293b) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xff334155) : const Color(0xffcbd5e1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Veuillez saisir votre e-mail';
                      }
                      if (!RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$').hasMatch(val.trim())) {
                        return 'Veuillez saisir un e-mail valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Password input
                  Text(
                    'Mot de passe',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 11, 
                      color: isDark ? const Color(0xff64748b) : const Color(0xff64748b),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline, color: primaryColor.withOpacity(0.7)),
                      filled: true,
                      fillColor: isDark ? const Color(0xff1e293b) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xff334155) : const Color(0xffcbd5e1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xff1e293b) : const Color(0xffe2e8f0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Veuillez saisir votre mot de passe';
                      }
                      if (val.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Submit Button with sleek design
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _submit(state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isSignUp ? "Créer mon compte" : "Se connecter",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.2),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Or Guest Mode Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            color: isDark ? const Color(0xff64748b) : const Color(0xff94a3b8), 
                            fontSize: 11, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Continue as Guest Button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _continueAsGuest(state),
                    icon: Icon(Icons.person_outline, size: 18, color: primaryColor),
                    label: Text(
                      'Continuer en tant qu\\'invité (Anonyme)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xff1e293b),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(
                        color: isDark ? const Color(0xff334155) : const Color(0xffcbd5e1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
`
  },
  {
    path: "lib/screens/missions_screen.dart",
    name: "missions_screen.dart",
    category: "Screens",
    code: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  String _selectedTimeHour = '09';
  String _selectedTimeMin = '00';
  int _selectedDayIndex = 3; // default: JEU 16

  final List<Map<String, String>> _weekDays = [
    {'day': 'LUN', 'num': '13'},
    {'day': 'MAR', 'num': '14'},
    {'day': 'MER', 'num': '15'},
    {'day': 'JEU', 'num': '16'},
    {'day': 'VEN', 'num': '17'},
    {'day': 'SAM', 'num': '18'},
    {'day': 'DIM', 'num': '19'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // Open Agenda tab by default to match screenshot
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _eventController.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _triggerAutoPlan(AppStateProvider state) {
    // Add default balanced activities
    state.addAgendaEvent('Méditation du matin 🧘', '08:30');
    state.addAgendaEvent('Repas conscient 🍎', '12:30');
    state.addAgendaEvent('Yoga de fin de journée 🤸', '18:00');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nexii a synchronisé 3 activités équilibrées dans votre agenda !'),
        backgroundColor: Color(0xff2563eb),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            const Text(
              'Mon Agenda Bien-être',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xff2563eb),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xff2563eb),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Défis & XP'),
            Tab(text: 'Agenda'),
            Tab(text: 'Communauté'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Défis & XP
            _buildDefisTab(context, state),

            // Tab 2: Agenda
            _buildAgendaTab(context, state),

            // Tab 3: Communauté
            _buildCommunityTab(context, state, isDark),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: DEFIS & XP ---
  Widget _buildDefisTab(BuildContext context, AppStateProvider state) {
    final dailyMissions = state.missions.where((m) => m['id'] != '3').toList();
    final weeklyMissions = state.missions.where((m) => m['id'] == '3').toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // XP Progress Header Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xff8b5cf6),
                        radius: 14,
                        child: Icon(Icons.star, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Niveau \${state.level}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Text(
                    '\${state.xp} / \${100 * state.level} XP',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: state.xp / (100 * state.level),
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff8b5cf6)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.translate('overall_progress'),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),

        _buildSectionHeader(context, 'Missions Quotidiennes'),
        if (dailyMissions.isEmpty)
          const Center(child: Text('Aucune mission quotidienne active.'))
        else
          ...dailyMissions.map((m) => _buildMissionCard(context, state, m)),

        const SizedBox(height: 16),
        _buildSectionHeader(context, 'Missions Hebdomadaires'),
        if (weeklyMissions.isEmpty)
          const Center(child: Text('Aucune mission hebdomadaire active.'))
        else
          ...weeklyMissions.map((m) => _buildMissionCard(context, state, m)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15, color: Colors.grey),
      ),
    );
  }

  Widget _buildMissionCard(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> mission,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double progress = (mission['progress'] as num).toDouble();
    final bool isCompleted = mission['isCompleted'] as bool;
    final bool claimed = mission['claimed'] as bool;
    final String missionId = mission['id'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  mission['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff8b5cf6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+\${mission['xp']} XP',
                  style: const TextStyle(color: Color(0xff8b5cf6), fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mission['description'] ?? '',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? const Color(0xff22c55e) : const Color(0xff2563eb),
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isCompleted ? '100%' : '\${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: isCompleted ? const Color(0xff22c55e) : const Color(0xff2563eb),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (isCompleted) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: claimed ? null : () => state.claimMissionXp(missionId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8b5cf6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xff22c55e).withOpacity(0.1),
                  disabledForegroundColor: const Color(0xff22c55e),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                child: Text(
                  claimed ? state.translate('reward_claimed') : state.translate('claim_xp'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 2: MON AGENDA ---
  Widget _buildAgendaTab(BuildContext context, AppStateProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Calendar selector (Image 5)
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weekDays.length,
              itemBuilder: (context, idx) {
                final day = _weekDays[idx];
                final isSelected = idx == _selectedDayIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = idx;
                    });
                  },
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xff2563eb)
                          : (isDark ? const Color(0xff1e293b) : const Color(0xfff1f5f9)),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? null
                          : Border.all(color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day['day']!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day['num']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Planning header (Image 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PLANNINGS DE LA JOURNÉE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
              TextButton.icon(
                onPressed: () => _triggerAutoPlan(state),
                icon: const Icon(Icons.auto_awesome, size: 14, color: Color(0xff2563eb)),
                label: const Text(
                  '+ Nexii Auto-Plan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2563eb),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Events list
          if (state.agendaEvents.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: const Column(
                children: [
                  Icon(Icons.calendar_today, size: 36, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Aucune activité planifiée pour aujourd\\'hui.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...state.agendaEvents.asMap().entries.map((entry) {
              final idx = entry.key;
              final ev = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563eb).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ev['time'] ?? '08:00',
                        style: const TextStyle(
                          color: Color(0xff2563eb),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        ev['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                      onPressed: () {
                        state.removeAgendaEvent(idx);
                      },
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // Add to Agenda Section (Image 5)
          const Text(
            'AJOUTER À L\\'AGENDA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _eventController,
                  decoration: InputDecoration(
                    hintText: 'Séance Yoga, Gym, Méditer...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _selectedTimeHour,
                            underline: const SizedBox(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedTimeHour = val;
                                });
                              }
                            },
                            items: List.generate(24, (index) => index.toString().padLeft(2, '0'))
                                .map((hour) => DropdownMenuItem(value: hour, child: Text(hour)))
                                .toList(),
                          ),
                          const Text(' : '),
                          DropdownButton<String>(
                            value: _selectedTimeMin,
                            underline: const SizedBox(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedTimeMin = val;
                                });
                              }
                            },
                            items: ['00', '15', '30', '45']
                                .map((min) => DropdownMenuItem(value: min, child: Text(min)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final title = _eventController.text.trim();
                        if (title.isNotEmpty) {
                          state.addAgendaEvent(title, '$_selectedTimeHour:$_selectedTimeMin');
                          _eventController.clear();
                          FocusScope.of(context).unfocus();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2563eb),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: 4),
                          Text('Planifier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: COMMUNAUTE ---
  Widget _buildCommunityTab(BuildContext context, AppStateProvider state, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Peer guidance intro card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff8b5cf6), Color(0xffa855f7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, color: Colors.white, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Réseau d\\'Entraide Nexii',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Partagez vos victoires, inspirez vos pairs et restez motivé ensemble !',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Write a post card
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xff6366f1),
                    radius: 16,
                    child: Icon(Icons.edit, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Quoi de neuf aujourd\\'hui ? Partagez une réussite...',
                        hintStyle: TextStyle(fontSize: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  final text = _postController.text.trim();
                  if (text.isNotEmpty) {
                    state.addCommunityPost(text);
                    _postController.clear();
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Votre message a été partagé !')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563eb),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                ),
                icon: const Icon(Icons.send, size: 12),
                label: const Text('Partager', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        const Text(
          'FLUX BIEN-ÊTRE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        ...state.communityPosts.map((post) {
          final int colorVal = post['avatarColorValue'] as int? ?? 0xff8b5cf6;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(colorVal),
                      radius: 16,
                      child: Text(
                        (post['author'] as String? ?? 'M')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['author'] as String? ?? 'Anonyme',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            post['time'] as String? ?? 'À l\\'instant',
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563eb).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post['tag'] as String? ?? '#BienEtre',
                        style: const TextStyle(color: Color(0xff2563eb), fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post['text'] as String? ?? '',
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        state.toggleLikePost(post['id'] as String);
                      },
                      child: Row(
                        children: [
                          Icon(
                            (post['hasLiked'] as bool? ?? false) ? Icons.favorite : Icons.favorite_border,
                            color: (post['hasLiked'] as bool? ?? false) ? Colors.red : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '\${post['likes'] ?? 0}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
                        SizedBox(width: 4),
                        Text('Commenter', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
`
  },
  {
    path: "lib/screens/onboarding_screen.dart",
    name: "onboarding_screen.dart",
    category: "Screens",
    code: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff2563eb),
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text =
            "\${picked.year}-\${picked.month.toString().padLeft(2, '0')}-\${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top logo or icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff2563eb).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 48,
                      color: Color(0xff2563eb),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  state.translate('onboarding_title'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  state.translate('onboarding_desc'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 32),

                // Full Name Input
                Text(
                  state.translate('onboarding_name_label'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Alexandre Nexii',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),

                // Birthdate Input
                Text(
                  state.translate('onboarding_birthdate_label'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _birthdateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final birthdate = _birthdateController.text.trim();
                    if (name.isNotEmpty && birthdate.isNotEmpty) {
                      state.completeOnboarding(name, birthdate);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez remplir tous les champs'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    state.translate('onboarding_submit'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLangButton(state, const Locale('fr', 'FR'), 'FR'),
                    _buildLangButton(state, const Locale('en', 'US'), 'EN'),
                    _buildLangButton(state, const Locale('es', 'ES'), 'ES'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(AppStateProvider state, Locale locale, String label) {
    final isSelected = state.currentLocale.languageCode == locale.languageCode;
    return GestureDetector(
      onTap: () => state.setLocale(locale),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff2563eb) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xff2563eb) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
`
  },
  {
    path: "lib/screens/profile_screen.dart",
    name: "profile_screen.dart",
    category: "Screens",
    code: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  int _feedbackRating = 5;
  bool _isSubmittingFeedback = false;
  String _selectedSubTab = 'badges'; // 'badges', 'stats', 'prefs'

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff2563eb),
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text =
            "\${picked.year}-\${picked.month.toString().padLeft(2, '0')}-\${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showEditProfileDialog(BuildContext context, AppStateProvider state) {
    _nameController.text = state.profileName;
    _birthdateController.text = state.profileBirthdate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(state.translate('edit_profile_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.translate('onboarding_name_label'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.translate('onboarding_birthdate_label'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _birthdateController,
                      readOnly: true,
                      style: const TextStyle(fontSize: 13),
                      onTap: () async {
                        await _selectDate(context);
                        setDialogState(() {});
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.calendar_today, size: 16),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(state.translate('cancel_btn'), style: const TextStyle(fontSize: 13)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final birthdate = _birthdateController.text.trim();
                    if (name.isNotEmpty && birthdate.isNotEmpty) {
                      state.updateProfile(name, birthdate);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(state.translate('save_profile_btn'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // Initial letters
    String initials = 'NX';
    final name = state.profileName.isNotEmpty ? state.profileName : 'Alexandre Nexii';
    final parts = name.split(' ');
    if (parts.length > 1) {
      initials = "\${parts[0][0]}\${parts[1][0]}".toUpperCase();
    } else if (name.isNotEmpty) {
      initials = name.substring(0, (name.length > 1 ? 2 : 1)).toUpperCase();
    }

    // Active sub-tab title translations
    final langCode = state.currentLocale.languageCode;
    final tabBadgesLabel = langCode == 'fr' ? 'Badges' : 'Badges';
    final tabStatsLabel = langCode == 'fr' ? 'Stats' : 'Stats';
    final tabPrefsLabel = langCode == 'fr' ? 'Préférences' : langCode == 'es' ? 'Preferencias' : 'Settings';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person, color: Color(0xff2563eb)),
            const SizedBox(width: 8),
            Text(
              state.translate('profile_title'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            // Profile Hero Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xff2563eb), Color(0xff8b5cf6)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).cardColor,
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xff2563eb),
                            child: Text(
                              initials,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff8b5cf6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Niveau \${state.level}',
                                    style: const TextStyle(color: Color(0xff8b5cf6), fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                                if (state.profileAge > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff2563eb).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '\${state.profileAge} ans',
                                      style: const TextStyle(color: Color(0xff2563eb), fontWeight: FontWeight.bold, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.translate('joined_date'),
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 6),
                  
                  // XP Level Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progression Niveau',
                            style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\${state.xp} / \${state.level * 100} XP',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xff8b5cf6)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (state.xp / (state.level * 100)).clamp(0.0, 1.0),
                          backgroundColor: Theme.of(context).dividerColor,
                          color: const Color(0xff8b5cf6),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  
                  // Edit Info Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditProfileDialog(context, state),
                      icon: const Icon(Icons.edit, size: 14),
                      label: Text(
                        state.translate('edit_profile_btn'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: const Color(0xff2563eb).withOpacity(0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Activity Streak Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xfff59e0b).withOpacity(0.08),
                    const Color(0xffef4444).withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xfff59e0b).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.translate('activity_streak'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          state.translate('streak_desc'),
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xfff59e0b).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\${state.streak} \${langCode == 'fr' ? 'Jours' : 'Days'}',
                      style: const TextStyle(color: Color(0xffd97706), fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Sub-tabs Navigation
            Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildSubTabButton(context, 'badges', tabBadgesLabel),
                  _buildSubTabButton(context, 'stats', tabStatsLabel),
                  _buildSubTabButton(context, 'prefs', tabPrefsLabel),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Active Sub-tab View Rendering
            _buildActiveSubTabContent(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabButton(BuildContext context, String id, String label) {
    final isSelected = _selectedSubTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSubTab = id;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? const Color(0xff2563eb)
                  : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSubTabContent(BuildContext context, AppStateProvider state) {
    switch (_selectedSubTab) {
      case 'badges':
        return _buildBadgesTab(context, state);
      case 'stats':
        return _buildStatsTab(context, state);
      case 'prefs':
        return _buildPrefsTab(context, state);
      default:
        return _buildBadgesTab(context, state);
    }
  }

  // SUBTAB 1: BADGES
  Widget _buildBadgesTab(BuildContext context, AppStateProvider state) {
    final langCode = state.currentLocale.languageCode;
    
    // Dynamic lists of achievements checking values from app state
    final productivityBadges = [
      {
        'name': langCode == 'fr' ? 'Maître d’œuvre' : 'Task Master',
        'desc': langCode == 'fr' ? 'Compléter au moins une tâche dans l’application.' : 'Complete at least one task.',
        'xp': '50 XP',
        'icon': '🎯',
        'unlocked': state.tasks.any((t) => t['isCompleted'] == true),
      },
      {
        'name': langCode == 'fr' ? 'Grand Organisateur' : 'Super Organizer',
        'desc': langCode == 'fr' ? 'Compléter 3 tâches ou plus.' : 'Complete 3 or more tasks.',
        'xp': '100 XP',
        'icon': '👑',
        'unlocked': state.tasks.where((t) => t['isCompleted'] == true).length >= 3,
      },
    ];

    final wellbeingBadges = [
      {
        'name': langCode == 'fr' ? 'Esprit Calme' : 'Calm Mind',
        'desc': langCode == 'fr' ? 'Déclarer une humeur sereine ou positive.' : 'Log a serene or positive mood.',
        'xp': '50 XP',
        'icon': '🧘',
        'unlocked': state.auraPercentage >= 70,
      },
      {
        'name': langCode == 'fr' ? 'Aura Étoilée' : 'Star Aura',
        'desc': langCode == 'fr' ? 'Atteindre un score d’aura de 75% ou plus.' : 'Achieve an aura score of 75% or higher.',
        'xp': '100 XP',
        'icon': '✨',
        'unlocked': state.auraPercentage >= 75,
      },
    ];

    final financeBadges = [
      {
        'name': langCode == 'fr' ? 'Épargne Nexii' : 'Nexii Savings',
        'desc': langCode == 'fr' ? 'Avoir dépensé moins de 50% de son budget total.' : 'Spend less than 50% of total budget.',
        'xp': '100 XP',
        'icon': '💰',
        'unlocked': state.totalBudget > 0 && state.spentBudget <= (state.totalBudget * 0.5),
      },
      {
        'name': langCode == 'fr' ? 'Sérénité Financière' : 'Financial Serenity',
        'desc': langCode == 'fr' ? 'Garder un stress financier faible (budget non dépassé).' : 'Keep financial stress low (within budget).',
        'xp': '80 XP',
        'icon': '🛡️',
        'unlocked': state.totalBudget > 0 && state.spentBudget < state.totalBudget,
      },
    ];

    final focusBadges = [
      {
        'name': langCode == 'fr' ? 'Focus Booster' : 'Focus Starter',
        'desc': langCode == 'fr' ? 'Accumuler au moins 15 minutes de concentration.' : 'Accumulate 15+ minutes of focus.',
        'xp': '50 XP',
        'icon': '⚡',
        'unlocked': state.focusMinutesTotal >= 15,
      },
      {
        'name': langCode == 'fr' ? 'Zen Laser' : 'Zen Laser Focus',
        'desc': langCode == 'fr' ? 'Accumuler au moins 60 minutes de concentration.' : 'Accumulate 60+ minutes of focus.',
        'xp': '120 XP',
        'icon': '🔮',
        'unlocked': state.focusMinutesTotal >= 60,
      },
    ];

    final streakBadges = [
      {
        'name': langCode == 'fr' ? 'Flambeau' : 'Activity Spark',
        'desc': langCode == 'fr' ? 'Maintenir une série d’activité de 3 jours ou plus.' : 'Maintain a 3+ day activity streak.',
        'xp': '100 XP',
        'icon': '🔥',
        'unlocked': state.streak >= 3,
      },
      {
        'name': langCode == 'fr' ? 'Constance Nexii' : 'Nexii Consistency',
        'desc': langCode == 'fr' ? 'Atteindre une série d’activité de 10 jours ou plus.' : 'Achieve a 10+ day activity streak.',
        'xp': '200 XP',
        'icon': '⏳',
        'unlocked': state.streak >= 10,
      },
    ];

    int unlockedCount = 0;
    for (var b in [...productivityBadges, ...wellbeingBadges, ...financeBadges, ...focusBadges, ...streakBadges]) {
      if (b['unlocked'] == true) unlockedCount++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Count Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langCode == 'fr' ? 'Badges & Succès' : 'Badges & Achievements',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xff2563eb).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$unlockedCount / 10 Unlocked',
                style: const TextStyle(fontSize: 10, color: Color(0xff2563eb), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildBadgeGroup(context, langCode == 'fr' ? 'Productivité' : 'Productivity', productivityBadges),
        _buildBadgeGroup(context, langCode == 'fr' ? 'Bien-être' : 'Well-being', wellbeingBadges),
        _buildBadgeGroup(context, langCode == 'fr' ? 'Finance' : 'Finance', financeBadges),
        _buildBadgeGroup(context, langCode == 'fr' ? 'Focus' : 'Focus', focusBadges),
        _buildBadgeGroup(context, langCode == 'fr' ? 'Série' : 'Streak', streakBadges),
      ],
    );
  }

  Widget _buildBadgeGroup(BuildContext context, String groupTitle, List<Map<String, dynamic>> badges) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupTitle.toUpperCase(),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.1),
          ),
          const SizedBox(height: 6),
          ...badges.map((b) {
            final isUnlocked = b['unlocked'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isUnlocked
                      ? const Color(0xff3b82f6).withOpacity(0.15)
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.55,
                child: Row(
                  children: [
                    Text(b['icon'], style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b['desc'],
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? const Color(0xff2563eb).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isUnlocked ? '+\${b['xp']}' : '🔒 Locked',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? const Color(0xff2563eb) : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // SUBTAB 2: STATS
  Widget _buildStatsTab(BuildContext context, AppStateProvider state) {
    final langCode = state.currentLocale.languageCode;
    
    // Line chart mock history data incorporating the real current wellness/aura score
    final double currentAura = state.auraPercentage;
    final List<double> wellnessHistory = [70, 75, 68, 80, 85, 78, currentAura];
    
    // Focus hours history incorporating real current total focus minutes
    final int currentFocus = state.focusMinutesTotal;
    final List<int> focusHistory = [30, 45, 15, 60, 40, 90, currentFocus > 90 ? 90 : currentFocus];

    // Expense breakdown calculation from transactions
    final totals = _getCategoryTotals(state.transactions);
    final totalSpent = totals.values.fold(0.0, (sum, val) => sum + val);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wellness History Line Chart Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    langCode == 'fr' ? 'Évolution Bien-être (Nexii State)' : 'Well-being Evolution (Nexii State)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    '\${currentAura.round()}% \${langCode == 'fr' ? 'Actuel' : 'Now'}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xff2563eb)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                width: double.infinity,
                child: CustomPaint(
                  painter: WellnessChartPainter(wellnessHistory),
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lun', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Mar', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Mer', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Jeu', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Ven', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Sam', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                  Text('Dim', style: TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace')),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Focus Pomodoro Bar Chart Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    langCode == 'fr' ? 'Heures Concentration (Pomodoro)' : 'Focus Hours (Pomodoro)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                  ),
                  Text(
                    '$currentFocus mins',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xff8b5cf6)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 100,
                child: FocusBarChart(focusHistory),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Expense Breakdown progress bars
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                langCode == 'fr' ? 'RÉPARTITION DES DÉPENSES' : 'EXPENSE BREAKDOWN',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.grey, letterSpacing: 1.1),
              ),
              const SizedBox(height: 10),
              if (totalSpent == 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor, style: BorderStyle.none),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    langCode == 'fr'
                        ? 'Aucune dépense enregistrée. Ajoutez des transactions.'
                        : 'No expenses recorded yet. Add some transactions.',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...totals.entries.where((e) => e.value > 0).map((e) {
                  final catName = e.key;
                  final amt = e.value;
                  final pct = (amt / totalSpent).clamp(0.0, 1.0);
                  Color catColor = const Color(0xff3b82f6);
                  if (catName == 'Alimentation') catColor = const Color(0xff10b981);
                  if (catName == 'Loisirs') catColor = const Color(0xff6366f1);
                  if (catName == 'Maison') catColor = const Color(0xfff59e0b);
                  if (catName == 'Abonnement') catColor = const Color(0xff8b5cf6);
                  if (catName == 'Bonus') catColor = const Color(0xffec4899);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(catName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(
                              '\${amt.toStringAsFixed(1)} € (\${(pct * 100).round()}%)',
                              style: const TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: Theme.of(context).dividerColor,
                            color: catColor,
                          ),
                        )
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // AI coaching insights (Fonction 7)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xff2563eb).withOpacity(0.06),
                const Color(0xff8b5cf6).withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xff2563eb).withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xff2563eb), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    langCode == 'fr' ? 'NEXII AI REPORTS & TENDANCES' : 'NEXII AI REPORTS & TRENDS',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xff2563eb), letterSpacing: 1.0),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currentAura < 50
                    ? (langCode == 'fr'
                        ? "🚨 Votre niveau d'énergie est particulièrement bas aujourd'hui. L'IA vous conseille de réduire la difficulté de vos tâches actives, de prioriser le sommeil, et de déléguer ou reporter les tâches non-essentielles."
                        : "🚨 Your energy level is particularly low today. The AI advises you to reduce the difficulty of active tasks, prioritize sleep, and delegate non-essential work.")
                    : (langCode == 'fr'
                        ? "✨ Vos indicateurs de bien-être et de motivation sont excellents ! C'est le moment idéal pour aborder vos tâches complexes à haute valeur ajoutée."
                        : "✨ Your well-being and motivation indicators are excellent! This is the perfect time to tackle your high-value complex tasks."),
                style: const TextStyle(fontSize: 10.5, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Map<String, double> _getCategoryTotals(List<Map<String, dynamic>> transactions) {
    Map<String, double> totals = {
      'Alimentation': 0.0,
      'Loisirs': 0.0,
      'Maison': 0.0,
      'Abonnement': 0.0,
      'Bonus': 0.0,
    };
    for (var tx in transactions) {
      if (tx['isNegative'] == true) {
        String cat = tx['category'] ?? 'Loisirs';
        if (cat == 'Food') cat = 'Alimentation';
        if (cat == 'Leisure' || cat == 'Ocio') cat = 'Loisirs';
        if (cat == 'Home' || cat == 'Casa') cat = 'Maison';
        if (cat == 'Subscription' || cat == 'Suscripción') cat = 'Abonnement';
        
        double amt = (tx['amount'] as num).toDouble().abs();
        totals[cat] = (totals[cat] ?? 0.0) + amt;
      }
    }
    return totals;
  }

  // SUBTAB 3: PREFERENCES (SETTINGS)
  Widget _buildPrefsTab(BuildContext context, AppStateProvider state) {
    final langCode = state.currentLocale.languageCode;
    
    // Success rate computation
    final completedTasks = state.tasks.where((t) => t['isCompleted'] == true).length;
    final totalTasks = state.tasks.length;
    final rate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // General Statistics Grid Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.translate('stats_title'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.8,
                children: [
                  _buildStatGridItem('Heures Focus', '\${(state.focusMinutesTotal / 60).floor()}h \${(state.focusMinutesTotal % 60).toString().padLeft(2, '0')}m'),
                  _buildStatGridItem('Défis Réussis', '\${state.missions.where((m) => m['isCompleted'] == true).length} / \${state.missions.length}'),
                  _buildStatGridItem('Taux Réussite', '$rate%'),
                  _buildStatGridItem('Cohérence Card.', '\${state.auraPercentage.round()}%'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionHeader(context, state.translate('device_options')),

        // Server URL preference Card
        Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff2563eb).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.dns, color: Color(0xff2563eb), size: 18),
            ),
            title: Text(
              langCode == 'fr' ? 'Adresse du Serveur API' : 'API Server URL',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              state.customServerUrl,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Color(0xff2563eb)),
              onPressed: () {
                final controller = TextEditingController(text: state.customServerUrl);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text(
                        langCode == 'fr' ? 'Modifier l\\'adresse du Serveur' : 'Edit Server URL',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            langCode == 'fr'
                                ? 'Saisissez l\\'URL complète du serveur backend (ex: https://ais-pre-...)'
                                : 'Enter the complete URL of your backend server',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: controller,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              labelText: 'URL Serveur',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(state.translate('cancel_btn')),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            state.updateServerUrl(controller.text);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(langCode == 'fr' ? 'Serveur mis à jour avec succès !' : 'Server updated successfully!'),
                                backgroundColor: const Color(0xff10b981),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2563eb),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Dark mode preference
        Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: SwitchListTile(
            title: Text(
              state.translate('settings_theme'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: const Text(
              'Basculez entre l\\'affichage clair et sombre',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            value: state.isDarkMode,
            activeColor: const Color(0xff2563eb),
            onChanged: (val) {
              state.toggleTheme();
            },
          ),
        ),
        const SizedBox(height: 8),

        // Language Preference
        Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: ListTile(
            title: Text(
              state.translate('settings_lang'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              _getLocaleName(state.currentLocale),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            trailing: DropdownButton<Locale>(
              value: state.currentLocale,
              underline: const SizedBox(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  state.setLocale(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('fr', 'FR'),
                  child: Text('Français (FR)', style: TextStyle(fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: Locale('en', 'US'),
                  child: Text('English (US)', style: TextStyle(fontSize: 12)),
                ),
                DropdownMenuItem(
                  value: Locale('es', 'ES'),
                  child: Text('Español (ES)', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Feedback / Customer form
        _buildSectionHeader(context, langCode == 'fr' ? 'Formulaire de retour utilisateur' : 'Send feedback'),
        Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langCode == 'fr' ? 'Votre avis compte énormément !' : 'Your feedback counts!',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  langCode == 'fr'
                      ? 'Aidez-nous à améliorer Nexii en partageant votre expérience ou en signalant un bug.'
                      : 'Help us improve Nexii by sharing your experience or reporting an issue.',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                // Star Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return IconButton(
                      icon: Icon(
                        starValue <= _feedbackRating ? Icons.star : Icons.star_border,
                        color: starValue <= _feedbackRating ? Colors.amber : Colors.grey.shade400,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _feedbackRating = starValue;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 10),

                // Comment area
                TextField(
                  controller: _feedbackController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: langCode == 'fr' ? 'Écrivez votre message ici...' : 'Write your message here...',
                    hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 12),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8b5cf6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    icon: _isSubmittingFeedback
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: 14),
                    label: Text(
                      _isSubmittingFeedback
                          ? (langCode == 'fr' ? 'Envoi en cours...' : 'Sending...')
                          : (langCode == 'fr' ? 'Envoyer mon avis' : 'Submit feedback'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                    onPressed: _isSubmittingFeedback
                        ? null
                        : () async {
                            final text = _feedbackController.text.trim();
                            if (text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(langCode == 'fr' ? 'Veuillez saisir un commentaire avant d\\'envoyer.' : 'Please write a comment first.'),
                                  backgroundColor: Colors.amber,
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isSubmittingFeedback = true;
                            });

                            final success = await state.submitFeedback(_feedbackRating, text);

                            if (mounted) {
                              setState(() {
                                _isSubmittingFeedback = false;
                              });
                              if (success) {
                                _feedbackController.clear();
                                setState(() {
                                  _feedbackRating = 5;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(langCode == 'fr' ? 'Merci pour vos retours ! Votre avis a bien été enregistré. 💜' : 'Thank you for your feedback! 💜'),
                                    backgroundColor: const Color(0xff10b981),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(langCode == 'fr' ? 'Une erreur est survenue lors de l\\'envoi.' : 'An error occurred while sending.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Disconnect button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffef4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            icon: const Icon(Icons.logout, size: 14),
            label: Text(
              langCode == 'fr' ? 'Se déconnecter de Nexii' : 'Log out from Nexii',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: () {
              state.signOut();
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildStatGridItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8.5, color: Colors.grey, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Français';
    }
  }
}

// -------------------------------------------------------------
// Beautiful Bezier Curve Custom Painter for Wellness Evolution
// -------------------------------------------------------------
class WellnessChartPainter extends CustomPainter {
  final List<double> dataPoints;
  WellnessChartPainter(this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;
    
    final paintLine = Paint()
      ..color = const Color(0xff2563eb)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintArea = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xff2563eb).withOpacity(0.2),
          const Color(0xff2563eb).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final areaPath = Path();

    double stepX = size.width / (dataPoints.length - 1);
    double maxY = 100.0;
    
    double getY(double val) {
      double pct = (val / maxY).clamp(0.0, 1.0);
      return size.height - (pct * size.height * 0.8) - 10; // offset inside area
    }

    path.moveTo(0, getY(dataPoints[0]));
    areaPath.moveTo(0, size.height);
    areaPath.lineTo(0, getY(dataPoints[0]));

    for (int i = 1; i < dataPoints.length; i++) {
      double x = i * stepX;
      double y = getY(dataPoints[i]);
      
      double prevX = (i - 1) * stepX;
      double prevY = getY(dataPoints[i - 1]);
      
      // Control points
      double cx1 = prevX + stepX / 2;
      double cy1 = prevY;
      double cx2 = prevX + stepX / 2;
      double cy2 = y;
      
      path.cubicTo(cx1, cy1, cx2, cy2, x, y);
      areaPath.cubicTo(cx1, cy1, cx2, cy2, x, y);
    }

    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, paintArea);
    canvas.drawPath(path, paintLine);

    // Draw dots at points
    final dotPaint = Paint()..color = const Color(0xff2563eb);
    final bgDotPaint = Paint()..color = Colors.white;
    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * stepX;
      double y = getY(dataPoints[i]);
      canvas.drawCircle(Offset(x, y), 4, bgDotPaint);
      canvas.drawCircle(Offset(x, y), 2.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// -------------------------------------------------------------
// Rounded Focus hours bar chart
// -------------------------------------------------------------
class FocusBarChart extends StatelessWidget {
  final List<int> focusMinutes;
  const FocusBarChart(this.focusMinutes, {super.key});

  @override
  Widget build(BuildContext context) {
    final maxMin = 90;
    final weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final val = focusMinutes[index];
        final pct = (val / maxMin).clamp(0.1, 1.0);
        final isToday = index == DateTime.now().weekday - 1;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 14,
                  height: 80 * pct, // scaling height
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xff8b5cf6) : const Color(0xff8b5cf6).withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              weekdays[index],
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? const Color(0xff8b5cf6) : Colors.grey,
              ),
            ),
          ],
        );
      }),
    );
  }
}
`
  },
  {
    path: "lib/screens/tasks_screen.dart",
    name: "tasks_screen.dart",
    category: "Screens",
    code: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  String _selectedCategory = 'Travail';
  String _selectedPriority = 'Haute';

  @override
  void dispose() {
    _taskTitleController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog(BuildContext context, AppStateProvider state) {
    String selectedCategory = 'Travail';
    String selectedPriority = 'Haute';
    String selectedUrgency = 'Haute';
    String selectedDifficulty = 'Moyen';
    int selectedDuration = 30;
    String selectedEnergy = 'Moyenne';
    String selectedGoalId = '';
    bool showAdvanced = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(state.translate('add_task'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _taskTitleController,
                      decoration: InputDecoration(
                        hintText: state.translate('placeholder_add_task'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                      items: ['Travail', 'Bien-être', 'Santé', 'Finance', 'Loisirs']
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Priorité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedPriority = val;
                          });
                        }
                      },
                      items: ['Haute', 'Moyenne', 'Basse']
                          .map((prio) => DropdownMenuItem(value: prio, child: Text(prio)))
                          .toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            showAdvanced = !showAdvanced;
                          });
                        },
                        icon: Icon(
                          showAdvanced ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: const Color(0xff8b5cf6),
                        ),
                        label: Text(
                          showAdvanced ? 'Options simples' : 'Options avancées',
                          style: const TextStyle(
                            color: Color(0xff8b5cf6),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    if (showAdvanced) ...[
                      const SizedBox(height: 8),
                      const Text('Urgence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedUrgency,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedUrgency = val;
                            });
                          }
                        },
                        items: ['Haute', 'Moyenne', 'Basse']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Difficulté', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedDifficulty,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedDifficulty = val;
                            });
                          }
                        },
                        items: ['Facile', 'Moyen', 'Difficile']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Temps estimé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: selectedDuration,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedDuration = val;
                            });
                          }
                        },
                        items: [10, 15, 30, 45, 60, 90, 120]
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d min')))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Énergie nécessaire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedEnergy,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedEnergy = val;
                            });
                          }
                        },
                        items: ['Basse', 'Moyenne', 'Haute']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Lier à un objectif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedGoalId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedGoalId = val;
                            });
                          }
                        },
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Aucun')),
                          ...state.goals.map((g) => DropdownMenuItem(value: g['id'] as String, child: Text(g['title'] as String))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(state.translate('cancel_btn')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _taskTitleController.text.trim();
                    if (title.isNotEmpty) {
                      final subtitle = "Aujourd'hui • $selectedPriority";
                      state.addTask(
                        title, 
                        subtitle, 
                        selectedCategory,
                        priority: selectedPriority,
                        urgency: selectedUrgency,
                        difficulty: selectedDifficulty,
                        estimatedTime: selectedDuration,
                        energyNeeded: selectedEnergy,
                        linkedGoalId: selectedGoalId,
                      );
                      _taskTitleController.clear();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.check_box, color: Color(0xff2563eb)),
            const SizedBox(width: 8),
            Text(
              state.translate('tasks_title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xff2563eb), size: 30),
            onPressed: () => _showAddTaskDialog(context, state),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: state.tasks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      state.translate('all_completed'),
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return _buildTaskTile(
                    context,
                    state,
                    task,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, state),
        backgroundColor: const Color(0xff2563eb),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskTile(
    BuildContext context,
    AppStateProvider state,
    Map<String, dynamic> task,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = task['id'] as String;
    final title = task['title'] as String;
    final subtitle = task['subtitle'] as String;
    final category = task['category'] as String;
    final isCompleted = task['isCompleted'] as bool;
    
    final priority = task['priority'] ?? 'Moyenne';
    final urgency = task['urgency'] ?? 'Moyenne';
    final difficulty = task['difficulty'] ?? 'Moyen';
    final estimatedTime = task['estimatedTime'] ?? 30;
    final energyNeeded = task['energyNeeded'] ?? 'Moyenne';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffe2e8f0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Checkbox(
              value: isCompleted,
              activeColor: const Color(0xff2563eb),
              onChanged: (val) {
                state.toggleTask(id);
              },
            ),
            title: Text(
              title,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isCompleted
                    ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              "$subtitle • $category • 🕒 \${estimatedTime}m",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () {
                state.deleteTask(id);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 58.0, bottom: 12.0, right: 16.0),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildSmallChip("Prio : $priority", const Color(0xffef4444)),
                _buildSmallChip("Urgence : $urgency", const Color(0xfff97316)),
                _buildSmallChip("Diff : $difficulty", const Color(0xff8b5cf6)),
                _buildSmallChip("Énergie : $energyNeeded", const Color(0xff22c55e)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSmallChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
`
  },
  {
    path: "test/widget_test.dart",
    name: "widget_test.dart",
    category: "Test",
    code: `import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nexii/main.dart';
import 'package:nexii/providers/app_state_provider.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ],
        child: const NexiiApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
`
  },
];

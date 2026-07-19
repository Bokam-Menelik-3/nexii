import 'dart:convert';
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
        print("Sign in failed: ${response.body}");
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
        print("Sign up failed: ${response.body}");
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
        print("Anonymous sign in failed: ${response.body}");
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
        print("Failed to fetch user data: ${response.body}");
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
        print("Failed to save user data: ${response.body}");
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
        print("Failed to fetch collection $collectionName: ${response.statusCode} - ${response.body}");
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
        print("Failed to create document in $collectionName: ${response.body}");
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
        print("Failed to update document $documentId: ${response.body}");
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

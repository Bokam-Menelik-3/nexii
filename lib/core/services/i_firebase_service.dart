abstract class IFirebaseService {
  bool get isLoggedIn;
  String? get uid;
  String? get email;

  Future<void> waitForInitialization();

  Future<bool> signIn(String email, String password);
  Future<bool> signUp(String email, String password);
  Future<bool> signInAnonymously();
  void signOut();

  // Firestore helpers used by services
  Future<Map<String, dynamic>?> fetchUserData();
  Future<bool> saveUserData(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>?> fetchUserSubcollection(
      String subcollectionName);
  Future<bool> saveUserSubcollectionDocument(
      String subcollectionName, String docId, Map<String, dynamic> data);
  Future<bool> deleteUserSubcollectionDocument(
      String subcollectionName, String docId);
}

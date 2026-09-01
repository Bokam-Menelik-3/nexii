import '../../models/user_profile_model.dart';
import 'i_firebase_service.dart';

class ProfileService {
  final IFirebaseService _firebaseService;

  ProfileService(this._firebaseService);

  Future<UserProfile?> fetchProfile() async {
    if (_firebaseService.uid == null) return null;
    final data = await _firebaseService.fetchUserData();
    if (data == null || data.isEmpty) return null;
    return UserProfile.fromMap(data, _firebaseService.uid!);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _firebaseService.saveUserData(profile.toMap());
  }
}

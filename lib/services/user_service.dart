import '../models/models.dart';

class UserService {
  // Mock data untuk simulasi
  static User? _currentUser = User(
    id: '1',
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+62 812 3456 7890',
    profilePicture: 'assets/profile_placeholder.png',
    bio: 'Travel enthusiast exploring beautiful Bali',
    createdAt: DateTime(2023, 1, 15),
    updatedAt: DateTime.now(),
  );
  
  static Map<String, dynamic> _userSettings = {
    'notificationsEnabled': true,
    'locationEnabled': true,
    'darkModeEnabled': false,
    'selectedLanguage': 'Indonesian',
    'autoBackup': true,
    'highQualityImages': true,
    'dataUsage': 'WiFi Only',
  };
  
  Future<User?> getCurrentUser() async {
    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }
  
  Future<Map<String, dynamic>> getUserSettings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Map.from(_userSettings);
  }
  
  Future<void> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = user;
  }
  
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _userSettings = Map.from(settings);
  }
  
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simulasi validasi password
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      throw Exception('Password cannot be empty');
    }
    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    // Dalam implementasi nyata, password akan di-hash dan disimpan
  }
  
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Dalam implementasi nyata, akan menghapus token dan session
  }
  
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = null;
    _userSettings.clear();
    // Dalam implementasi nyata, akan menghapus semua data user dari server
  }
  
  Future<void> updateProfilePicture(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(profilePicture: imagePath);
    }
  }
  
  Future<List<String>> getAvailableLanguages() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['Indonesian', 'English', 'Balinese'];
  }
  
  Future<Map<String, dynamic>> exportUserData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {
      'user': _currentUser?.toJson(),
      'settings': _userSettings,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
}

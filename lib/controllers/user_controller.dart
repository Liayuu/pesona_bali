import '../models/models.dart';
import '../services/services.dart';

class UserController {
  final UserService _userService = UserService();
  
  User? _currentUser;
  Map<String, dynamic> _userSettings = {};
  bool _isLoading = false;
  
  User? get currentUser => _currentUser;
  Map<String, dynamic> get userSettings => _userSettings;
  bool get isLoading => _isLoading;
  
  // Singleton pattern
  static final UserController _instance = UserController._internal();
  factory UserController() => _instance;
  UserController._internal() {
    _loadDefaultSettings();
  }
  
  void _loadDefaultSettings() {
    _userSettings = {
      'notificationsEnabled': true,
      'locationEnabled': true,
      'darkModeEnabled': false,
      'selectedLanguage': 'Indonesian',
      'autoBackup': true,
      'highQualityImages': true,
      'dataUsage': 'WiFi Only',
    };
  }
  
  Future<void> loadUser() async {
    _isLoading = true;
    try {
      _currentUser = await _userService.getCurrentUser();
      _userSettings = await _userService.getUserSettings();
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? profilePicture,
  }) async {
    if (_currentUser == null) return;
    
    try {
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        profilePicture: profilePicture ?? _currentUser!.profilePicture,
      );
      
      await _userService.updateUser(updatedUser);
      _currentUser = updatedUser;
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
  
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      _userSettings[key] = value;
      await _userService.updateUserSettings(_userSettings);
    } catch (e) {
      print('Error updating setting: $e');
      rethrow;
    }
  }
  
  Future<void> updateMultipleSettings(Map<String, dynamic> settings) async {
    try {
      _userSettings.addAll(settings);
      await _userService.updateUserSettings(_userSettings);
    } catch (e) {
      print('Error updating settings: $e');
      rethrow;
    }
  }
  
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _userService.changePassword(currentPassword, newPassword);
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      await _userService.logout();
      _currentUser = null;
      _loadDefaultSettings();
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }
  
  Future<void> deleteAccount() async {
    try {
      await _userService.deleteAccount();
      _currentUser = null;
      _loadDefaultSettings();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
  
  // Convenience getters for specific settings
  bool get notificationsEnabled => _userSettings['notificationsEnabled'] ?? true;
  bool get locationEnabled => _userSettings['locationEnabled'] ?? true;
  bool get darkModeEnabled => _userSettings['darkModeEnabled'] ?? false;
  String get selectedLanguage => _userSettings['selectedLanguage'] ?? 'Indonesian';
  bool get autoBackup => _userSettings['autoBackup'] ?? true;
  bool get highQualityImages => _userSettings['highQualityImages'] ?? true;
  String get dataUsage => _userSettings['dataUsage'] ?? 'WiFi Only';
}

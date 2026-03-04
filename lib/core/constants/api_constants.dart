class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web/Windows
  static const String baseUrl = 'http://10.0.2.2:5000/api'; 
  // static const String baseUrl = 'http://localhost:5000/api'; 

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String userProfile = '/auth/profile';
  
  // Admin
  static const String adminUsers = '/admin/users';
  static const String adminGroups = '/admin/groups';
  static const String adminSchedule = '/schedule'; 
  
  // Schedule
  static const String schedule = '/schedule';
}

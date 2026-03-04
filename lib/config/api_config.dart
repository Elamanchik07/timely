class ApiConfig {
  // Base URL - change for production
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS Simulator
  // static const String baseUrl = 'http://YOUR_SERVER_IP:5000/api'; // Real Device
  
  // Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String schedule = '/schedule';
  static const String rooms = '/rooms';
  static const String roomsSearch = '/rooms/search';
  static const String adminStudents = '/admin/students';
  static const String adminSchedule = '/schedule';
  
  // Timeout
  static const Duration timeout = Duration(seconds: 30);
}

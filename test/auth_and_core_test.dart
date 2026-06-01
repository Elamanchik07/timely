// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_project_app/features/auth/domain/entities/user.dart';

/// Validates email format (mirrors login_screen.dart regex)
bool isValidEmail(String email) {
  return RegExp(r'^[\w.\-]+@[\w.\-]+\.\w{2,}$').hasMatch(email);
}

/// Validates password strength
bool isPasswordValid(String password) => password.length >= 8;

/// Validates that passwords match
bool doPasswordsMatch(String password, String confirm) =>
    password == confirm;

/// Validates 6-digit code format
bool isValidCode(String code) =>
    code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code);

/// Password strength calculator (mirrors reset_password_screen.dart)
double passwordStrength(String password) {
  if (password.isEmpty) return 0;
  double strength = 0;
  if (password.length >= 8) strength += 0.25;
  if (password.length >= 12) strength += 0.15;
  if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
  if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
  if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;
  return strength.clamp(0, 1);
}

void main() {
  // ═══════════════════════════════════════════════════════════════
  //  1. AUTH / FORGOT PASSWORD — Email Validation
  // ═══════════════════════════════════════════════════════════════

  group('Auth — Email Validation', () {
    test('1. Empty email is invalid', () {
      expect(isValidEmail(''), false);
    });

    test('2. Invalid email without @ is invalid', () {
      expect(isValidEmail('usergmail.com'), false);
    });

    test('3. Invalid email without domain is invalid', () {
      expect(isValidEmail('user@'), false);
    });

    test('4. Valid email is accepted', () {
      expect(isValidEmail('test@example.com'), true);
    });

    test('5. Valid email with subdomain', () {
      expect(isValidEmail('user@mail.example.com'), true);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  //  2. AUTH / FORGOT PASSWORD — Code Validation
  // ═══════════════════════════════════════════════════════════════

  group('Auth — Code Validation', () {
    test('6. Empty code is invalid', () {
      expect(isValidCode(''), false);
    });

    test('7. Code shorter than 6 digits is invalid', () {
      expect(isValidCode('12345'), false);
    });

    test('8. Code longer than 6 digits is invalid', () {
      expect(isValidCode('1234567'), false);
    });

    test('9. Code with non-digits is invalid', () {
      expect(isValidCode('12345a'), false);
    });

    test('10. Valid 6-digit code is accepted', () {
      expect(isValidCode('123456'), true);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  //  3. AUTH / FORGOT PASSWORD — Password Validation
  // ═══════════════════════════════════════════════════════════════

  group('Auth — Password Validation', () {
    test('11. Empty password is invalid', () {
      expect(isPasswordValid(''), false);
    });

    test('12. Password shorter than 8 chars is invalid', () {
      expect(isPasswordValid('short'), false);
    });

    test('13. Password with exactly 8 chars is valid', () {
      expect(isPasswordValid('12345678'), true);
    });

    test('14. Long password is valid', () {
      expect(isPasswordValid('MySecurePassword123!'), true);
    });

    test('15. Confirm password mismatch fails', () {
      expect(doPasswordsMatch('password1', 'password2'), false);
    });

    test('16. Confirm password match succeeds', () {
      expect(doPasswordsMatch('same_pass', 'same_pass'), true);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  //  4. PASSWORD STRENGTH
  // ═══════════════════════════════════════════════════════════════

  group('Password Strength', () {
    test('17. Empty password has zero strength', () {
      expect(passwordStrength(''), 0);
    });

    test('18. Short password has low strength', () {
      final s = passwordStrength('abc');
      expect(s, lessThan(0.3));
    });

    test('19. Mixed-case + digits = medium strength', () {
      final s = passwordStrength('Abc12345');
      expect(s, greaterThanOrEqualTo(0.5));
    });

    test('20. Complex password has high strength', () {
      final s = passwordStrength('MyStr0ng!Pass');
      expect(s, greaterThanOrEqualTo(0.8));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  //  5. USER MODEL — Domain Entity
  // ═══════════════════════════════════════════════════════════════

  group('User Model', () {
    test('21. User.fromJson parses correctly', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'role': 'STUDENT',
        'status': 'APPROVED',
        'course': 2,
        'groupCode': 'CS-24',
        'phone': '+77001112233',
      };
      final user = User.fromJson(json);
      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.role, 'STUDENT');
      expect(user.status, 'APPROVED');
      expect(user.course, 2);
      expect(user.groupCode, 'CS-24');
      expect(user.isAdmin, false);
    });

    test('22. User.isAdmin is true for ADMIN role', () {
      const user = User(
        id: 'a1',
        email: 'admin@test.com',
        fullName: 'Admin',
        role: 'ADMIN',
        status: 'APPROVED',
      );
      expect(user.isAdmin, true);
    });

    test('23. User.isAdmin is false for STUDENT role', () {
      const user = User(
        id: 's1',
        email: 'student@test.com',
        fullName: 'Student',
        role: 'STUDENT',
        status: 'APPROVED',
      );
      expect(user.isAdmin, false);
    });

    test('24. User defaults: role=STUDENT, status=PENDING', () {
      const user = User(
        id: 'x',
        email: 'x@x.com',
        fullName: 'X',
      );
      expect(user.role, 'STUDENT');
      expect(user.status, 'PENDING');
      expect(user.isBlocked, false);
    });

    test('25. User.toJson round-trip preserves data', () {
      const user = User(
        id: '42',
        email: 'round@trip.com',
        fullName: 'Round Trip',
        role: 'STUDENT',
        status: 'APPROVED',
        course: 3,
        groupCode: 'IT-23',
        phone: '+77009998877',
      );
      final json = user.toJson();
      final restored = User.fromJson(json);
      expect(restored.id, user.id);
      expect(restored.email, user.email);
      expect(restored.fullName, user.fullName);
      expect(restored.role, user.role);
      expect(restored.course, user.course);
      expect(restored.groupCode, user.groupCode);
    });
  });
}

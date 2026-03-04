# Testing Guide — Timely App

## Overview

The Timely project includes **25 automated tests** covering authentication, password reset, validation logic, and the User domain model. All tests are pure unit tests that run without network, emulator, or timing dependencies.

---

## Running Tests

### Run all tests

```bash
flutter test
```

### Run a single test file

```bash
flutter test test/auth_and_core_test.dart
```

### Run tests with verbose output

```bash
flutter test --reporter expanded
```

### Run tests with coverage

```bash
flutter test --coverage
```

Coverage report is stored at:

```
coverage/lcov.info
```

To generate an HTML report (requires `lcov` or `genhtml`):

```bash
genhtml coverage/lcov.info -o coverage/html
```

---

## Test Structure

All tests are located in the `test/` directory:

| File                        | Tests | Coverage Area                                  |
|-----------------------------|-------|------------------------------------------------|
| `auth_and_core_test.dart`   | 25    | Email validation, code validation, password validation, password strength, User model |

### Test Breakdown

#### Auth — Email Validation (5 tests)
1. Empty email is invalid
2. Email without `@` is invalid
3. Email without domain is invalid
4. Valid standard email is accepted
5. Valid email with subdomain is accepted

#### Auth — Code Validation (5 tests)
6. Empty code is invalid
7. Code shorter than 6 digits is invalid
8. Code longer than 6 digits is invalid
9. Code with non-digits is invalid
10. Valid 6-digit code is accepted

#### Auth — Password Validation (6 tests)
11. Empty password is invalid
12. Password shorter than 8 chars is invalid
13. Password with exactly 8 chars is valid
14. Long password is valid
15. Confirm password mismatch fails
16. Confirm password match succeeds

#### Password Strength (4 tests)
17. Empty password has zero strength
18. Short password has low strength
19. Mixed-case with digits = medium strength
20. Complex password has high strength

#### User Model (5 tests)
21. `User.fromJson` parses all fields correctly
22. `isAdmin` returns true for ADMIN role
23. `isAdmin` returns false for STUDENT role
24. Default values: role=STUDENT, status=PENDING, isBlocked=false
25. `toJson` → `fromJson` round-trip preserves data

---

## Architecture Notes for Testing

- **State management**: Riverpod (`flutter_riverpod`)
- **DI**: Riverpod providers (can be overridden in tests via `ProviderScope.overrides`)
- **HTTP client**: Dio (mock via `mocktail` for integration tests)
- **Secure storage**: `flutter_secure_storage` (mock for widget tests)
- **Routing**: `go_router`

### Mocking Dependencies

The project uses `mocktail` for mocks. Example:

```dart
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}
```

You can override Riverpod providers in tests:

```dart
ProviderScope(
  overrides: [
    apiClientProvider.overrideWithValue(mockApiClient),
  ],
  child: MaterialApp(home: YourWidget()),
)
```

---

## Environment

- No environment variables are required for running tests
- Tests do not require a running backend
- Tests do not require an emulator or physical device
- All tests run headless (CI-compatible)

---

## CI Integration

Add to your CI pipeline:

```yaml
- name: Run Flutter Tests
  run: |
    flutter pub get
    flutter test
```

---

## Last Verified

- **Date**: 2026-03-03
- **Result**: `00:38 +25: All tests passed!`
- **Flutter version**: 3.x (SDK ^3.9.2)

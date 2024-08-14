import 'package:test/test.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
  });

  group('FirebaseAuthProvider', () {
    test('createUser throws exception if Firebase is not initialized',
        () async {
      expect(
        () async => await mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'firebase-not-initialized')),
      );
    });

    test('logIn throws exception if Firebase is not initialized', () async {
      expect(
        () async => await mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'firebase-not-initialized')),
      );
    });

    test('logOut throws exception if Firebase is not initialized', () async {
      expect(
        () async => await mockFirebaseAuth.signOut(),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'firebase-not-initialized')),
      );
    });

    test(
        'sendEmailVerification throws exception if Firebase is not initialized',
        () async {
      expect(
        () async => await mockFirebaseAuth.sendEmailVerification(),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'firebase-not-initialized')),
      );
    });

    test('initialize sets isInitialized to true', () async {
      await mockFirebaseAuth.initialize();
      expect(mockFirebaseAuth.isInitialized, isTrue);
    });

    test('createUser succeeds if Firebase is initialized', () async {
      await mockFirebaseAuth.initialize();
      final user = await mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(user.email, 'test@example.com');
    });

    test('logIn succeeds if Firebase is initialized', () async {
      await mockFirebaseAuth.initialize();
      final user = await mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(user.email, 'test@example.com');
    });

    test('logOut succeeds if Firebase is initialized', () async {
      await mockFirebaseAuth.initialize();
      await mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
      await mockFirebaseAuth.signOut();
      expect(mockFirebaseAuth.currentUser, isNull);
    });

    test('sendEmailVerification succeeds if Firebase is initialized', () async {
      await mockFirebaseAuth.initialize();
      await mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(
        () async => await mockFirebaseAuth.sendEmailVerification(),
        returnsNormally,
      );
    });
  });
}

// Mock classes to simulate Firebase's behavior

class MockFirebaseAuth {
  AuthUser? currentUser;
  bool isInitialized = false;

  Future<void> initialize() async {
    isInitialized = true;
  }

  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw FirebaseAuthException(code: 'firebase-not-initialized');
    }
    if (email == 'existing@example.com') {
      throw FirebaseAuthException(code: 'email-already-in-use');
    }
    if (password.length < 6) {
      throw FirebaseAuthException(code: 'weak-password');
    }
    currentUser = AuthUser(email: email);
    return currentUser!;
  }

  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw FirebaseAuthException(code: 'firebase-not-initialized');
    }
    if (email == 'notfound@example.com') {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    currentUser = AuthUser(email: email);
    return currentUser!;
  }

  Future<void> signOut() async {
    if (!isInitialized) {
      throw FirebaseAuthException(code: 'firebase-not-initialized');
    }
    currentUser = null;
  }

  Future<void> sendEmailVerification() async {
    if (!isInitialized) {
      throw FirebaseAuthException(code: 'firebase-not-initialized');
    }
    if (currentUser == null) {
      throw FirebaseAuthException(code: 'user-not-logged-in');
    }
    // Simulate sending email verification
  }

  void reloadUser() {
    if (!isInitialized) {
      throw FirebaseAuthException(code: 'firebase-not-initialized');
    }
    // Simulate reloading the user
  }
}

class AuthUser {
  final String email;

  AuthUser({required this.email});
}

class FirebaseAuthException implements Exception {
  final String code;

  FirebaseAuthException({required this.code});
}

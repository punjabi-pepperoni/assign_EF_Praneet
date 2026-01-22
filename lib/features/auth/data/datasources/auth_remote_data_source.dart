import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> logout();
  Future<void> forgotPassword(String email);
}

/// Maps Firebase error codes to user-friendly messages
String _mapFirebaseErrorToMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Invalid email ID format';
    case 'user-disabled':
      return 'This account has been disabled';
    case 'user-not-found':
      return 'No account found with this email';
    case 'wrong-password':
      return 'Incorrect password';
    case 'invalid-credential':
      return 'Invalid email or password';
    case 'email-already-in-use':
      return 'Email ID already registered';
    case 'weak-password':
      return 'Password is too weak';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later';
    case 'network-request-failed':
      return 'Network error. Check your connection';
    default:
      return 'An error occurred. Please try again';
  }
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user!;
      final token = await user.getIdToken();
      return UserModel(
        email: user.email!,
        accessToken: token ?? '',
        refreshToken: '',
      );
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(message: _mapFirebaseErrorToMessage(e.code));
    } catch (e) {
      throw ServerFailure(message: _mapFirebaseErrorToMessage(e.toString()));
    }
  }

  @override
  Future<UserModel> register(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user!;
      final token = await user.getIdToken();
      return UserModel(
        email: user.email!,
        accessToken: token ?? '',
        refreshToken: '',
      );
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(message: _mapFirebaseErrorToMessage(e.code));
    } catch (e) {
      throw ServerFailure(message: _mapFirebaseErrorToMessage(e.toString()));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw ServerFailure(message: 'Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;
      final token = await user.getIdToken();

      return UserModel(
        email: user.email!,
        accessToken: token ?? '',
        refreshToken: '',
      );
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(message: _mapFirebaseErrorToMessage(e.code));
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Google sign-in failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      throw ServerFailure(message: 'Logout failed');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(message: _mapFirebaseErrorToMessage(e.code));
    } catch (e) {
      throw ServerFailure(message: 'Failed to send reset email');
    }
  }
}

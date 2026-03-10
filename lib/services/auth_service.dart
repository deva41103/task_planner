import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class AuthService extends GetxService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '597389104992-khv8en7tfa4p04eur7i8eee2f9v72n7o.apps.googleusercontent.com',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<User?> currentUser = Rx<User?>(null);

  Future<AuthService> init() async {
    currentUser.bindStream(_auth.authStateChanges());
    return this;
  }

  @override
  void onReady() {
    super.onReady();
    // Initial check to handle auto-login on startup/restart
    _handleAuthStateChanged(currentUser.value);
    // Worker: Automatically handle navigation when auth state changes
    ever(currentUser, _handleAuthStateChanged);
  }

  void _handleAuthStateChanged(User? user) {
    if (user != null) {
      if (Get.currentRoute != AppRoutes.DASHBOARD) {
        Get.offAllNamed(AppRoutes.DASHBOARD);
      }
    } else {
      if (Get.currentRoute != AppRoutes.LOGIN) {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    }
  }

  Future<bool> login() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user != null;
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

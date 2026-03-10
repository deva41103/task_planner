import 'package:get/get.dart';
import '../services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxBool isLoading = false.obs;

  void login() async {
    isLoading.value = true;
    await _authService.login();
    isLoading.value = false;
  }

  void logout() async {
    await _authService.logout();
  }
}

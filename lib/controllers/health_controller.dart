import 'package:get/get.dart';
import '../models/health_models.dart';
import '../services/firestore_service.dart';
import '../services/health_tip_service.dart';

class HealthController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final HealthTipService _tipService = Get.find<HealthTipService>();

  final RxList<HealthData> weekData = <HealthData>[].obs;
  final RxString dailyTip = "Loading today's health tip...".obs;
  final RxInt timerSeconds = (10 * 60).obs;
  final RxBool isTimerRunning = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind Firestore stream to our RxList
    weekData.bindStream(_firestoreService.getWeeklySteps());

    // Check if data is empty and upload initial mock data if needed
    ever(weekData, (data) {
      if (data.isEmpty) {
        _uploadMockData();
      }
    });

    _startTimer();
    _loadDailyTip();
  }

  Future<void> _loadDailyTip() async {
    dailyTip.value = await _tipService.getDailyTip();
  }

  void _uploadMockData() async {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      await _firestoreService.saveDailySteps(
        HealthData(
          date: now.subtract(Duration(days: 6 - i)),
          steps: 2000 + (i * 500) + (i % 2 == 0 ? 100 : -100),
        ),
      );
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (timerSeconds.value > 0 && isTimerRunning.value) {
        timerSeconds.value--;
      } else if (timerSeconds.value == 0) {
        resetTimer();
      }
      return true;
    });
  }

  void resetTimer() {
    timerSeconds.value = 10 * 60;
  }

  void toggleTimer() {
    isTimerRunning.value = !isTimerRunning.value;
  }

  String get timerString {
    int minutes = timerSeconds.value ~/ 60;
    int seconds = timerSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

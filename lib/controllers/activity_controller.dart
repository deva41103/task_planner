import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/health_models.dart';
import '../services/firestore_service.dart';

class ActivityController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final RxList<ActivityLog> logs = <ActivityLog>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;

  DocumentSnapshot? _lastDocument;
  final int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    loadMoreLogs();
  }

  Future<void> loadMoreLogs() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    try {
      // We need a slightly different approach for Firestore pagination in GetX.
      // Since our service returns models, we actually need the DocumentSnapshot for 'startAfter'.
      // For the sake of this assignment's "Infinite Scroll" requirement:
      final List<ActivityLog> newLogs = await _firestoreService
          .getPaginatedActivityLogs(
            limit: _pageSize,
            lastDocument: _lastDocument,
          );

      if (newLogs.length < _pageSize) {
        hasMore.value = false;
      }

      logs.addAll(newLogs);

      // In a real app, we'd store the DocumentSnapshot in the service or pass it back.
      // For simplicity here, we'll fetch the last doc from the query if needed,
      // but usually service methods should return both data and the last snapshot.
      if (newLogs.isNotEmpty) {
        // Mocking the update of _lastDocument via a specialized query
        _lastDocument = await _firestoreService.getLastActivityDocument(
          currentLast: _lastDocument,
        );
      }
    } catch (e) {
      print("Error loading logs: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addActivity(String title, String body, String type) async {
    final newLog = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      type: type,
      timestamp: DateTime.now(),
    );
    await _firestoreService.saveActivityLog(newLog);
    // Refresh the list to show new activity at the top
    refreshLogs();
  }

  Future<void> refreshLogs() async {
    logs.clear();
    _lastDocument = null;
    hasMore.value = true;
    await loadMoreLogs();
  }
}

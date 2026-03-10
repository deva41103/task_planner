import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/health_models.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // HEALTH DATA
  Future<void> saveDailySteps(HealthData data) async {
    if (_userId.isEmpty) return;
    final dateStr = '${data.date.year}-${data.date.month}-${data.date.day}';
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('health_data')
        .doc(dateStr)
        .set(data.toMap());
  }

  Stream<List<HealthData>> getWeeklySteps() {
    if (_userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('health_data')
        .orderBy('date', descending: true)
        .limit(7)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => HealthData.fromJson(doc.data()))
              .toList()
              .reversed
              .toList();
        });
  }

  // ACTIVITY LOGS
  Future<void> saveActivityLog(ActivityLog log) async {
    if (_userId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('activity_logs')
        .add(log.toMap());
  }

  // ACTIVITY LOGS - Paginated for Lazy Loading
  Future<List<ActivityLog>> getPaginatedActivityLogs({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    if (_userId.isEmpty) return [];

    Query query = _firestore
        .collection('users')
        .doc(_userId)
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => ActivityLog.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Helper to get the last document for pagination
  Future<DocumentSnapshot?> getLastActivityDocument({
    DocumentSnapshot? currentLast,
  }) async {
    if (_userId.isEmpty) return null;

    Query query = _firestore
        .collection('users')
        .doc(_userId)
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(1);

    if (currentLast != null) {
      query = query.startAfterDocument(currentLast);
    }

    final snp = await query.get();
    return snp.docs.isNotEmpty ? snp.docs.last : null;
  }

  Stream<List<ActivityLog>> getActivityLogs() {
    if (_userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(20) // Limit to 20 for the stream-based view if used
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ActivityLog.fromJson(doc.data()))
              .toList();
        });
  }
}

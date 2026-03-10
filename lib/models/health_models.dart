import 'package:cloud_firestore/cloud_firestore.dart';

class HealthData {
  final DateTime date;
  final int steps;

  HealthData({required this.date, required this.steps});

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date']),
      steps: json['steps'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': Timestamp.fromDate(date), 'steps': steps};
  }
}

class ActivityLog {
  final int id;
  final String title;
  final String body;
  final String type; // e.g., 'Walking', 'Running'
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'] ?? ((json['id'] % 2 == 0) ? 'Running' : 'Walking'),
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now().subtract(Duration(hours: json['id'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

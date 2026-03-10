import 'package:get/get.dart';

class HealthTipService extends GetConnect {
  Future<String> getDailyTip() async {
    try {
      // Mocking a tip fetch from JSONPlaceholder (using a post title as a tip)
      final response = await get(
        'https://jsonplaceholder.typicode.com/posts/${(DateTime.now().day % 100) + 1}',
      );
      if (response.status.hasError) {
        return "Stay hydrated and keep moving!";
      }
      return response.body['title'] ?? "Consistency is key to health.";
    } catch (e) {
      return "Listen to your body and rest when needed.";
    }
  }
}

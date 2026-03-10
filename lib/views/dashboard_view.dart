import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/health_controller.dart';
import '../controllers/activity_controller.dart';
import '../services/auth_service.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/step_graph.dart';
import '../widgets/fade_in_animation.dart';
import '../routes/app_routes.dart';

class DashboardView extends GetView<HealthController> {
  const DashboardView({super.key});

  void _showAddActivityDialog(BuildContext context) {
    final titleController = TextEditingController();
    final RxString selectedType = 'Walking'.obs;
    final List<String> activityTypes = [
      'Walking',
      'Running',
      'Cycling',
      'Swimming',
      'Workout',
      'Other',
    ];

    Get.dialog(
      AlertDialog(
        title: const Text('Add Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                hintText: 'e.g., Morning Walk',
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedType.value,
                decoration: const InputDecoration(labelText: 'Activity Type'),
                items: activityTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedType.value = value;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Get.find<ActivityController>().addActivity(
                  titleController.text,
                  'Activity logged at ${DateTime.now().hour}:${DateTime.now().minute}',
                  selectedType.value,
                );
                Get.back();
                Get.snackbar(
                  'Success',
                  'Activity added successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user?.photoURL != null
                        ? CachedNetworkImageProvider(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user?.displayName ?? 'User'}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? 'health@tracker.com',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily tip section - REST API proof
            FadeInAnimation(
              delay: const Duration(milliseconds: 200),
              child: CustomCard(
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.orange, size: 30),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Health Tip of the Day',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                          Obx(
                            () => Text(
                              controller.dailyTip.value,
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Graph Section
            const FadeInAnimation(
              delay: Duration(milliseconds: 400),
              child: Text(
                'Your Weekly Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            FadeInAnimation(
              delay: const Duration(milliseconds: 600),
              child: CustomCard(
                height: 250,
                child: Obx(() {
                  if (controller.weekData.isEmpty) {
                    return const Center(
                      child: Text(
                        'No progress data yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return StepGraph(data: controller.weekData.toList());
                }),
              ),
            ),
            const SizedBox(height: 30),

            FadeInAnimation(
              delay: const Duration(milliseconds: 800),
              child: Row(
                children: [
                  Expanded(
                    child: CustomCard(
                      child: Column(
                        children: [
                          const Text(
                            'Next Activity In',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Obx(
                            () => Text(
                              controller.timerString,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedScaleButton(
                            onTap: controller.toggleTimer,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Obx(
                                () => Text(
                                  controller.isTimerRunning.value
                                      ? 'PAUSE'
                                      : 'RESUME',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: AnimatedScaleButton(
                      onTap: () => Get.toNamed(AppRoutes.ACTIVITY_LOGS),
                      child: CustomCard(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.list_alt, size: 40, color: Colors.green),
                            SizedBox(height: 10),
                            Text(
                              'Activity Logs',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'View All',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:local_notification_demo/notification/notification_service.dart';
import 'package:local_notification_demo/widgets/notification_sheet.dart';

void main() async {
  /// 通史機能を使用するには、WidgetsFlutterBindingを初期化する必要があります
  /// main関数の中でNotificationServiceクラスのinitializeメソッドを呼び出し、
  /// 通知サービスを初期化します
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Notification Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const NotificationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知デモ'),
        actions: [
          TextButton(
            onPressed: () => _showNotificationSheet(context),
            child: const Text(
              '通知設定',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '右上の「通知設定」ボタンから\n通知時間を設定できます',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

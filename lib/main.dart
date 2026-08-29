import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initial_binding.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service for offline caching
  await Get.putAsync<StorageService>(() => StorageService().init());

  runApp(const JamendoMusicApp());
}

class JamendoMusicApp extends StatelessWidget {
  const JamendoMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jamendo Music Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialBinding: InitialBinding(),
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'state/auth_provider.dart';
import 'state/product_provider.dart';
import 'state/artisan_provider.dart';
import 'state/notification_provider.dart';
import 'screens/home_nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiConfig.init();

  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),
        ChangeNotifierProvider<ArtisanProvider>(create: (_) => ArtisanProvider()),
        ChangeNotifierProvider<NotificationProvider>(create: (_) => NotificationProvider()),
      ],
      child: const ArtisanConnectApp(),
    ),
  );
}

class ArtisanConnectApp extends StatelessWidget {
  const ArtisanConnectApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artisan Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeNavScreen(),
    );
  }
}

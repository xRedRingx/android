import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/customer/customer_dashboard.dart';
import 'screens/barber/barber_dashboard.dart';
import 'screens/customer/barber_profile_screen.dart';
import 'screens/customer/booking_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/services_provider.dart';
import 'providers/barber_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/financials_provider.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(BarberFlowApp());
}

class BarberFlowApp extends StatelessWidget {
  const BarberFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BarberProvider()),

        ChangeNotifierProxyProvider<AuthProvider, ServicesProvider>(
          create: (_) => ServicesProvider(null),
          update: (_, auth, _) => ServicesProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ScheduleProvider>(
          create: (_) => ScheduleProvider(null),
          update: (_, auth, _) => ScheduleProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FinancialsProvider>(
          create: (_) => FinancialsProvider(null),
          update: (_, auth, _) => FinancialsProvider(auth),
        ),
        // BookingProvider now depends on AuthProvider AND FinancialsProvider
        ChangeNotifierProxyProvider2<AuthProvider, FinancialsProvider, BookingProvider>(
          create: (_) => BookingProvider(null, null),
          update: (_, auth, financials, _) => BookingProvider(auth, financials),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BarberFlow',
            theme: AppTheme.boldTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: '/role-selection',
            routes: {
              '/role-selection': (context) => RoleSelectionScreen(),
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
              '/customer-dashboard': (context) => CustomerDashboard(),
              '/barber-dashboard': (context) => BarberDashboard(),
              '/barber-profile': (context) => BarberProfileScreen(),
              '/booking-screen': (context) => BookingScreen(),
            },
          );
        },
      ),
    );
  }
}

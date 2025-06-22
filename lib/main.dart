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
import 'providers/review_provider.dart';
import 'providers/notification_provider.dart'; // Add this import
import 'screens/shared/edit_profile_screen.dart';
import 'screens/shared/auth_wrapper.dart';
import 'providers/schedule_provider.dart';
import 'providers/financials_provider.dart';
import 'utils/app_theme.dart';
import 'utils/fade_route.dart';

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
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        ChangeNotifierProxyProvider<AuthProvider, ServicesProvider>(
          create: (_) => ServicesProvider(null),
          update: (_, auth, __) => ServicesProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ScheduleProvider>(
          create: (_) => ScheduleProvider(null),
          update: (_, auth, __) => ScheduleProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FinancialsProvider>(
          create: (_) => FinancialsProvider(null),
          update: (_, auth, __) => FinancialsProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ReviewProvider>(
          create: (_) => ReviewProvider(null),
          update: (_, auth, __) => ReviewProvider(auth),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, FinancialsProvider, BookingProvider>(
          create: (_) => BookingProvider(null, null),
          update: (_, auth, financials, __) => BookingProvider(auth, financials),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BarberFlow',
            theme: AppTheme.lightTheme,  // Changed from boldTheme to lightTheme
            darkTheme: AppTheme.darkTheme, // Optional: add dark theme support
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Optional: use theme provider
            debugShowCheckedModeBanner: false,
            home: AuthWrapper(),
            onGenerateRoute: (settings) {
              Widget page;
              switch (settings.name) {
                case '/role-selection':
                  page = RoleSelectionScreen();
                  break;
                case '/login':
                  page = LoginScreen();
                  break;
                case '/register':
                  page = RegisterScreen();
                  break;
                case '/customer-dashboard':
                  page = CustomerDashboard();
                  break;
                case '/barber-dashboard':
                  page = BarberDashboard();
                  break;
                case '/barber-profile':
                  page = BarberProfileScreen();
                  break;
                case '/booking-screen':
                  page = BookingScreen();
                  break;
                case '/edit-profile':
                  page = EditProfileScreen();
                  break;
                default:
                  page = AuthWrapper();
              }
              return FadeScaleRoute(page: page);
            },
          );
        },
      ),
    );
  }
}
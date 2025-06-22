import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../customer/customer_dashboard.dart';
import '../barber/barber_dashboard.dart';
import '../auth/role_selection_screen.dart';
import '../../utils/app_theme.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // While the app is first checking the auth state, show a loading screen.
        if (authProvider.isAuthLoading) {
          return Scaffold(
            backgroundColor: AppTheme.primaryColor,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.ctaColor),
              ),
            ),
          );
        }

        // After the check, if the user is authenticated, navigate to their dashboard.
        if (authProvider.isAuthenticated && authProvider.currentUser != null) {
          if (authProvider.currentUser!.role == UserRole.customer) {
            return CustomerDashboard();
          } else {
            return BarberDashboard();
          }
        }

        // Otherwise, show the role selection screen.
        else {
          return RoleSelectionScreen();
        }
      },
    );
  }
}

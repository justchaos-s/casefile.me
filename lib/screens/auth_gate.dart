import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'home_shell.dart';
import 'login_screen.dart';

/// Shows the app when signed in, the login screen otherwise.
/// Logging in or out anywhere automatically switches the screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: C.red)));
        }
        return snap.hasData ? const HomeShell() : const LoginScreen();
      },
    );
  }
}

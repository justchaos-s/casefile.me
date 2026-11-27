import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import '../models/case_model.dart';
import '../services/case_service.dart';
import 'case_files_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'threat_intel_screen.dart';

/// Bottom-navigation container for the four main tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  // One shared Firestore listener for every tab
  late final Stream<List<CaseModel>> _cases = CaseService()
      .watchCases(FirebaseAuth.instance.currentUser!.uid)
      .asBroadcastStream();

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(stream: _cases, goTo: (i) => setState(() => _index = i)),
      CaseFilesScreen(stream: _cases),
      const ThreatIntelScreen(),
      ProfileScreen(stream: _cases),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.folder_open_outlined), label: 'Cases'),
          NavigationDestination(
              icon: Icon(Icons.shield_outlined), label: 'Threat intel'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

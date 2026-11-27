import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import '../models/case_model.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  final Stream<List<CaseModel>> stream;
  const ProfileScreen({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Investigator profile')),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snap) {
            final d = snap.data?.data() ?? {};
            final name = (d['name'] ?? user.displayName ?? 'Investigator') as String;
            final email = (d['email'] ?? user.email ?? '') as String;
            final created = (d['createdAt'] as Timestamp?)?.toDate() ??
                user.metadata.creationTime;

            return ListView(padding: const EdgeInsets.all(20), children: [
              Row(children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: C.panel,
                    border: Border.all(color: C.red, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: C.red)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(email,
                            style: const TextStyle(color: C.muted)),
                      ]),
                ),
              ]),
              const SizedBox(height: 24),
              Panel(
                title: 'Account',
                child: Column(children: [
                  _row('Investigator ID', user.uid.substring(0, 8), mono: true),
                  _row('Member since',
                      created == null ? '-' : fmtDate(created),
                      mono: true),
                  _row('Sign-in method', 'Email and password', last: true),
                ]),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<CaseModel>>(
                stream: stream,
                builder: (context, cs) {
                  final cases = cs.data ?? [];
                  return Panel(
                    title: 'Investigation record',
                    child: Row(children: [
                      _num('Created', cases.length, C.text),
                      _num('Active',
                          cases.where((c) => c.status != 'Closed').length,
                          statusColor('In Progress')),
                      _num('Closed',
                          cases.where((c) => c.status == 'Closed').length,
                          statusColor('Closed')),
                    ]),
                  );
                },
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: C.red,
                    side: const BorderSide(color: C.red)),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Log out'),
                onPressed: () async {
                  final ok = await confirm(context,
                      title: 'Log out?',
                      message: 'You can log back in any time to see your cases.',
                      action: 'Log out');
                  if (ok) await AuthService().logout();
                  // AuthGate returns to the login screen automatically
                },
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _row(String k, String v, {bool mono = false, bool last = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: last
                ? null
                : const Border(bottom: BorderSide(color: C.border))),
        child: Row(children: [
          SizedBox(
              width: 120,
              child: Text(k,
                  style: const TextStyle(color: C.muted, fontSize: 13))),
          Expanded(
              child: Text(v,
                  style: mono
                      ? _mono13
                      : const TextStyle(fontSize: 14))),
        ]),
      );

  static final _mono13 = mono(13, C.text);

  Widget _num(String label, int n, Color color) => Expanded(
        child: Column(children: [
          Text('$n', style: mono(26, color, FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12.5, color: C.muted)),
        ]),
      );
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import '../models/case_model.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'case_details_screen.dart';
import 'case_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Stream<List<CaseModel>> stream;
  final void Function(int tab) goTo;
  const DashboardScreen({super.key, required this.stream, required this.goTo});

  @override
  Widget build(BuildContext context) {
    final name =
        FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ??
            'Investigator';
    return SafeArea(
      child: StreamBuilder<List<CaseModel>>(
        stream: stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const EmptyState(
                icon: Icons.cloud_off,
                title: 'Could not load cases',
                message: 'Check your connection and Firestore rules.');
          }
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: C.red));
          }
          final cases = snap.data!;
          int count(String s) => cases.where((c) => c.status == s).length;
          final recent = cases.take(5).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Welcome back, $name',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Here is where your investigations stand.',
                  style: TextStyle(color: C.muted)),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                    child: _Stat('Total cases', cases.length, C.text,
                        Icons.folder_copy_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _Stat('Open', count('Open'),
                        statusColor('Open'), Icons.radio_button_unchecked)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _Stat('In progress', count('In Progress'),
                        statusColor('In Progress'), Icons.timelapse)),
                const SizedBox(width: 12),
                Expanded(
                    child: _Stat('Closed', count('Closed'),
                        statusColor('Closed'), Icons.check_circle_outline)),
              ]),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                  child: _Action(
                    icon: Icons.add_circle_outline,
                    label: 'New investigation',
                    primary: true,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CaseFormScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Action(
                    icon: Icons.shield_outlined,
                    label: 'Threat intel',
                    onTap: () => goTo(2),
                  ),
                ),
              ]),
              const SizedBox(height: 28),
              Row(children: [
                const Text('Recent cases',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (cases.length > 5)
                  TextButton(
                      onPressed: () => goTo(1), child: const Text('View all')),
              ]),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                const Panel(
                  child: Text(
                      'No investigations yet. Create your first case to start building your case file.',
                      style: TextStyle(color: C.muted, height: 1.4)),
                )
              else
                for (final c in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CaseTile(
                      c: c,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CaseDetailsScreen(docId: c.id))),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const _Stat(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Panel(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(fontSize: 12.5, color: C.muted)),
          ]),
          const SizedBox(height: 10),
          Text('$value',
              style: mono(30, color, FontWeight.w700)),
        ]),
      );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _Action(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.primary = false});

  @override
  Widget build(BuildContext context) => Material(
        color: primary ? C.red : C.panel,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: primary ? C.red : C.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: [
              Icon(icon, size: 22),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}

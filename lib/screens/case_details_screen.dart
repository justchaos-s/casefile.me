import 'package:material_ui/material_ui.dart';
import '../models/case_model.dart';
import '../services/case_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'case_form_screen.dart';

class CaseDetailsScreen extends StatelessWidget {
  final String docId;
  const CaseDetailsScreen({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CaseModel?>(
      stream: CaseService().watchCase(docId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(
                  child: CircularProgressIndicator(color: C.red)));
        }
        final c = snap.data;
        if (c == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                  icon: Icons.folder_off_outlined,
                  title: 'Case not found',
                  message: 'It may have been deleted.'));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(c.caseId, style: mono(15, C.red, FontWeight.w700)),
            actions: [
              IconButton(
                tooltip: 'Edit case',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CaseFormScreen(existing: c))),
              ),
              IconButton(
                tooltip: 'Delete case',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final nav = Navigator.of(context);
                  final ok = await confirm(context,
                      title: 'Delete ${c.caseId}?',
                      message: 'This permanently removes the case and its notes.',
                      action: 'Delete');
                  if (ok) {
                    await CaseService().deleteCase(c.id);
                    nav.pop();
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Text(c.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, height: 1.25)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                Tag(c.status, statusColor(c.status)),
                Tag('${c.priority} priority', priorityColor(c.priority)),
              ]),
              const SizedBox(height: 20),
              Panel(
                title: 'Case summary',
                child: Column(children: [
                  _row('Case ID', c.caseId, isMono: true),
                  _row('Category', c.category),
                  _row('Priority', c.priority),
                  _row('Status', c.status),
                  _row('Created', fmtDate(c.createdAt), isMono: true, last: true),
                ]),
              ),
              const SizedBox(height: 16),
              Panel(
                title: 'Description',
                child: Text(c.description,
                    style: const TextStyle(height: 1.5, fontSize: 14.5)),
              ),
              const SizedBox(height: 16),
              Panel(
                title: 'Investigation notes',
                child: Text(
                  c.notes.isEmpty ? 'No notes recorded yet.' : c.notes,
                  style: TextStyle(
                      height: 1.5,
                      fontSize: 14.5,
                      color: c.notes.isEmpty ? C.muted : C.text),
                ),
              ),
              const SizedBox(height: 16),
              Panel(
                title: 'Update status',
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final s in kStatuses)
                    ChoiceChip(
                      label: Text(s),
                      selected: c.status == s,
                      showCheckmark: false,
                      onSelected: (_) async {
                        if (c.status == s) return;
                        await CaseService()
                            .updateCase(c.id, {'status': s});
                        if (context.mounted) {
                          toast(context, '${c.caseId} marked $s');
                        }
                      },
                      labelStyle: TextStyle(
                          color: c.status == s ? Colors.white : C.muted),
                      selectedColor: statusColor(s),
                      backgroundColor: C.surface,
                      side: BorderSide(
                          color: c.status == s ? statusColor(s) : C.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _row(String k, String v, {bool isMono = false, bool last = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: last
                ? null
                : const Border(bottom: BorderSide(color: C.border))),
        child: Row(children: [
          SizedBox(
              width: 92,
              child: Text(k,
                  style: const TextStyle(color: C.muted, fontSize: 13))),
          Expanded(
              child: Text(v,
                  style: isMono
                      ? mono(13, C.text)
                      : const TextStyle(fontSize: 14))),
        ]),
      );
}

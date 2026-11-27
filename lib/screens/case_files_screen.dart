import 'package:material_ui/material_ui.dart';
import '../models/case_model.dart';
import '../services/case_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'case_details_screen.dart';
import 'case_form_screen.dart';

class CaseFilesScreen extends StatefulWidget {
  final Stream<List<CaseModel>> stream;
  const CaseFilesScreen({super.key, required this.stream});
  @override
  State<CaseFilesScreen> createState() => _CaseFilesScreenState();
}

class _CaseFilesScreenState extends State<CaseFilesScreen> {
  String _query = '';
  String _status = 'All';
  String _priority = 'All';

  List<CaseModel> _apply(List<CaseModel> all) {
    final q = _query.toLowerCase();
    return all.where((c) {
      final matchesText = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.caseId.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q);
      final matchesStatus = _status == 'All' || c.status == _status;
      final matchesPriority = _priority == 'All' || c.priority == _priority;
      return matchesText && matchesStatus && matchesPriority;
    }).toList();
  }

  Widget _chips(String label, List<String> options, String value,
      void Function(String) onPick) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(label,
                style: const TextStyle(fontSize: 12.5, color: C.muted)),
          )),
          for (final o in ['All', ...options])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(o),
                selected: value == o,
                onSelected: (_) => onPick(o),
                showCheckmark: false,
                labelStyle: TextStyle(
                    fontSize: 12.5, color: value == o ? Colors.white : C.muted),
                selectedColor: C.red,
                backgroundColor: C.panel,
                side: BorderSide(color: value == o ? C.red : C.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Case files')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CaseFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New case'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Column(children: [
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search by title, case ID or category',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            _chips('Status', kStatuses, _status,
                (v) => setState(() => _status = v)),
            const SizedBox(height: 8),
            _chips('Priority', kPriorities, _priority,
                (v) => setState(() => _priority = v)),
          ]),
        ),
        Expanded(
          child: StreamBuilder<List<CaseModel>>(
            stream: widget.stream,
            builder: (context, snap) {
              if (snap.hasError) {
                return const EmptyState(
                    icon: Icons.cloud_off,
                    title: 'Could not load cases',
                    message: 'Check your connection and try again.');
              }
              if (!snap.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: C.red));
              }
              final all = snap.data!;
              final list = _apply(all);

              if (all.isEmpty) {
                return EmptyState(
                  icon: Icons.folder_off_outlined,
                  title: 'No cases yet',
                  message: 'Create an investigation to start your case file.',
                  action: FilledButton(
                    style: FilledButton.styleFrom(
                        minimumSize: const Size(180, 46)),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CaseFormScreen())),
                    child: const Text('New investigation'),
                  ),
                );
              }
              if (list.isEmpty) {
                return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No matching cases',
                    message: 'Try a different search or clear the filters.');
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final c = list[i];
                  return Dismissible(
                    key: ValueKey(c.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => confirm(context,
                        title: 'Delete ${c.caseId}?',
                        message:
                            'This permanently removes the case and its notes.',
                        action: 'Delete'),
                    onDismissed: (_) {
                      CaseService().deleteCase(c.id);
                      toast(context, '${c.caseId} deleted');
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                          color: C.red.withOpacity(.18),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.delete_outline, color: C.red),
                    ),
                    child: CaseTile(
                      c: c,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CaseDetailsScreen(docId: c.id))),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

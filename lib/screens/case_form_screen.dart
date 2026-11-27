import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import '../models/case_model.dart';
import '../services/case_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Used for both "New investigation" and "Edit case".
class CaseFormScreen extends StatefulWidget {
  final CaseModel? existing;
  const CaseFormScreen({super.key, this.existing});
  @override
  State<CaseFormScreen> createState() => _CaseFormScreenState();
}

class _CaseFormScreenState extends State<CaseFormScreen> {
  final _key = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _desc = TextEditingController(text: widget.existing?.description);
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late String _category = widget.existing?.category ?? kCategories.first;
  late String _priority = widget.existing?.priority ?? 'Medium';
  late String _status = widget.existing?.status ?? 'Open';
  bool _busy = false;

  bool get _editing => widget.existing != null;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final svc = CaseService();
      if (_editing) {
        await svc.updateCase(widget.existing!.id, {
          'title': _title.text.trim(),
          'description': _desc.text.trim(),
          'category': _category,
          'priority': _priority,
          'status': _status,
          'notes': _notes.text.trim(),
        });
      } else {
        await svc.createCase(
          uid: FirebaseAuth.instance.currentUser!.uid,
          title: _title.text.trim(),
          description: _desc.text.trim(),
          category: _category,
          priority: _priority,
          status: _status,
          notes: _notes.text.trim(),
        );
      }
      if (!mounted) return;
      toast(context, _editing ? 'Case updated' : 'Case created');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        toast(context, 'Could not save the case. Check your connection.');
        setState(() => _busy = false);
      }
    }
  }

  Widget _dropdown(String label, String value, List<String> items,
      void Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: C.panel,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final i in items) DropdownMenuItem(value: i, child: Text(i))
      ],
      onChanged: (v) => onChanged(v!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_editing
              ? 'Edit ${widget.existing!.caseId}'
              : 'New investigation')),
      body: SafeArea(
        child: Form(
          key: _key,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Panel(
              title: 'Incident',
              child: Column(children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Case title',
                      hintText: 'e.g. Suspicious login activity'),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Give the case a title'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _desc,
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      hintText: 'What happened? Which systems or accounts?'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Describe the incident'
                      : null,
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Panel(
              title: 'Classification',
              child: Column(children: [
                _dropdown('Category', _category, kCategories,
                    (v) => setState(() => _category = v)),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: _dropdown('Priority', _priority, kPriorities,
                          (v) => setState(() => _priority = v))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _dropdown('Status', _status, kStatuses,
                          (v) => setState(() => _status = v))),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            Panel(
              title: 'Investigation notes',
              child: TextFormField(
                controller: _notes,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Findings, evidence, next steps (optional)'),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_editing ? 'Save changes' : 'Create case'),
            ),
          ]),
        ),
      ),
    );
  }
}

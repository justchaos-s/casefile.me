import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import '../models/case_model.dart';
import '../theme.dart';

final _fmt = DateFormat('dd MMM yyyy, HH:mm');
String fmtDate(DateTime d) => _fmt.format(d);

Color priorityColor(String p) {
  switch (p) {
    case 'Critical':
      return C.red;
    case 'High':
      return const Color(0xFFE8803A);
    case 'Medium':
      return const Color(0xFFD9A93B);
    default:
      return const Color(0xFF7C93AB);
  }
}

Color statusColor(String s) {
  switch (s) {
    case 'In Progress':
      return const Color(0xFFD9A93B);
    case 'Closed':
      return const Color(0xFF4FAE82);
    default:
      return const Color(0xFF4DA3FF);
  }
}

/// Small outlined label used for status, priority, category.
class Tag extends StatelessWidget {
  final String label;
  final Color color;
  const Tag(this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          border: Border.all(color: color.withOpacity(.55)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}

/// Structured information panel with a red tick beside its title.
class Panel extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets padding;
  const Panel(
      {super.key,
      this.title,
      required this.child,
      this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: C.panel,
          border: Border.all(color: C.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: C.border))),
              child: Row(children: [
                Container(width: 3, height: 13, color: C.red),
                const SizedBox(width: 9),
                Text(title!,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: C.text)),
              ]),
            ),
          Padding(padding: padding, child: child),
        ]),
      );
}

/// One row in a case list.
class CaseTile extends StatelessWidget {
  final CaseModel c;
  final VoidCallback onTap;
  const CaseTile({super.key, required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.panel,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: C.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IntrinsicHeight(
            child: Row(children: [
              // left edge colour = priority at a glance
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: priorityColor(c.priority),
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(8)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(c.caseId, style: mono(12, C.red, FontWeight.w700)),
                          const Spacer(),
                          Text(fmtDate(c.createdAt), style: mono(10.5)),
                        ]),
                        const SizedBox(height: 6),
                        Text(c.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(c.category,
                            style: const TextStyle(
                                fontSize: 12.5, color: C.muted)),
                        const SizedBox(height: 10),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          Tag(c.status, statusColor(c.status)),
                          Tag(c.priority, priorityColor(c.priority)),
                        ]),
                      ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final Widget? action;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.action});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 44, color: C.border),
            const SizedBox(height: 14),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: C.muted)),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ]),
        ),
      );
}

Future<bool> confirm(BuildContext context,
    {required String title, required String message, required String action}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: C.panel,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: C.border)),
      title: Text(title, style: const TextStyle(fontSize: 17)),
      content: Text(message, style: const TextStyle(color: C.muted)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: C.muted))),
        TextButton(
            onPressed: () => Navigator.pop(context, true), child: Text(action)),
      ],
    ),
  );
  return res ?? false;
}

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

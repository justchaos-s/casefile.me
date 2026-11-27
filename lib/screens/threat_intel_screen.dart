import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../services/threat_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ThreatIntelScreen extends StatefulWidget {
  const ThreatIntelScreen({super.key});
  @override
  State<ThreatIntelScreen> createState() => _ThreatIntelScreenState();
}

class _ThreatIntelScreenState extends State<ThreatIntelScreen> {
  final _svc = ThreatService();
  late Future<List<Vulnerability>> _future = _svc.fetch();
  String _query = '';
  bool _ransomwareOnly = false;
  int _limit = 40;

  void _reload() => setState(() {
        _future = _svc.fetch(force: true);
        _limit = 40;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat intelligence'),
        actions: [
          IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: _reload),
        ],
      ),
      body: FutureBuilder<List<Vulnerability>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: C.red));
          }
          if (snap.hasError) {
            return EmptyState(
              icon: Icons.wifi_off,
              title: 'Could not load threat data',
              message:
                  'The CISA catalogue did not respond. Check your connection and try again.',
              action: FilledButton(
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 46)),
                  onPressed: _reload,
                  child: const Text('Retry')),
            );
          }

          final q = _query.toLowerCase();
          final all = snap.data!;
          final list = all.where((v) {
            if (_ransomwareOnly && !v.ransomware) return false;
            return q.isEmpty ||
                v.cve.toLowerCase().contains(q) ||
                v.name.toLowerCase().contains(q) ||
                v.vendor.toLowerCase().contains(q) ||
                v.product.toLowerCase().contains(q);
          }).toList();
          final shown = list.take(_limit).toList();

          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(children: [
                TextField(
                  onChanged: (v) => setState(() {
                    _query = v;
                    _limit = 40;
                  }),
                  decoration: const InputDecoration(
                      hintText: 'Search CVE, vendor or product',
                      prefixIcon: Icon(Icons.search, size: 20)),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  FilterChip(
                    label: const Text('Ransomware-linked'),
                    selected: _ransomwareOnly,
                    showCheckmark: false,
                    onSelected: (v) => setState(() {
                      _ransomwareOnly = v;
                      _limit = 40;
                    }),
                    labelStyle: TextStyle(
                        fontSize: 12.5,
                        color: _ransomwareOnly ? Colors.white : C.muted),
                    selectedColor: C.red,
                    backgroundColor: C.panel,
                    side: BorderSide(
                        color: _ransomwareOnly ? C.red : C.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  const Spacer(),
                  Text('${list.length} of ${all.length}', style: mono(11.5)),
                ]),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Source: CISA Known Exploited Vulnerabilities',
                      style: TextStyle(fontSize: 11.5, color: C.muted)),
                ),
              ]),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'No matches',
                      message: 'Try a different CVE, vendor or product.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: shown.length + (list.length > _limit ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        if (i == shown.length) {
                          return OutlinedButton(
                            onPressed: () => setState(() => _limit += 40),
                            child: const Text('Show more'),
                          );
                        }
                        return _VulnCard(shown[i]);
                      },
                    ),
            ),
          ]);
        },
      ),
    );
  }
}

class _VulnCard extends StatelessWidget {
  final Vulnerability v;
  const _VulnCard(this.v);

  @override
  Widget build(BuildContext context) {
    final risk = v.ransomware ? C.red : const Color(0xFFD9A93B);
    return Container(
      decoration: BoxDecoration(
        color: C.panel,
        border: Border.all(color: C.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: C.muted,
          collapsedIconColor: C.muted,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(v.cve, style: mono(12.5, C.red, FontWeight.w700)),
              const Spacer(),
              Text('Added ${v.dateAdded}', style: mono(10.5)),
            ]),
            const SizedBox(height: 6),
            Text(v.name,
                style:
                    const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${v.vendor} · ${v.product}',
                style: const TextStyle(fontSize: 12.5, color: C.muted)),
            const SizedBox(height: 8),
            Tag(v.ransomware ? 'Used in ransomware' : 'Actively exploited', risk),
          ]),
          children: [
            const Divider(color: C.border),
            const SizedBox(height: 6),
            Text(v.description,
                style: const TextStyle(height: 1.5, fontSize: 13.5)),
            const SizedBox(height: 12),
            const Text('Required action',
                style: TextStyle(
                    fontSize: 12.5, color: C.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(v.requiredAction,
                style: const TextStyle(height: 1.45, fontSize: 13.5)),
            const SizedBox(height: 12),
            Text('Remediation due: ${v.dueDate}', style: mono(11.5)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: v.cve));
                  toast(context, '${v.cve} copied');
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy CVE ID'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

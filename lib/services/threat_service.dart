import 'dart:convert';
import 'package:http/http.dart' as http;

class Vulnerability {
  final String cve, name, vendor, product, description;
  final String dateAdded, dueDate, requiredAction, notes;
  final bool ransomware;

  Vulnerability({
    required this.cve,
    required this.name,
    required this.vendor,
    required this.product,
    required this.description,
    required this.dateAdded,
    required this.dueDate,
    required this.requiredAction,
    required this.notes,
    required this.ransomware,
  });

  factory Vulnerability.fromJson(Map<String, dynamic> j) => Vulnerability(
        cve: j['cveID'] ?? '',
        name: j['vulnerabilityName'] ?? '',
        vendor: j['vendorProject'] ?? '',
        product: j['product'] ?? '',
        description: j['shortDescription'] ?? '',
        dateAdded: j['dateAdded'] ?? '',
        dueDate: j['dueDate'] ?? '',
        requiredAction: j['requiredAction'] ?? '',
        notes: j['notes'] ?? '',
        ransomware: (j['knownRansomwareCampaignUse'] ?? '') == 'Known',
      );
}

/// CISA Known Exploited Vulnerabilities (KEV) catalogue. Free, no API key.
class ThreatService {
  static const _url =
      'https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json';

  static List<Vulnerability>? _cache; // avoids re-downloading on every visit

  Future<List<Vulnerability>> fetch({bool force = false}) async {
    if (_cache != null && !force) return _cache!;

    final res =
        await http.get(Uri.parse(_url)).timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw Exception('CISA returned status ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['vulnerabilities'] as List)
        .map((e) => Vulnerability.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded)); // ISO dates
    return _cache = list;
  }
}

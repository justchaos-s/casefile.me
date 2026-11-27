import 'package:cloud_firestore/cloud_firestore.dart';

const kCategories = [
  'Phishing',
  'Data Breach',
  'Malware',
  'Ransomware',
  'Account Compromise',
  'Network Intrusion',
  'Insider Threat',
  'Other',
];
const kPriorities = ['Low', 'Medium', 'High', 'Critical'];
const kStatuses = ['Open', 'In Progress', 'Closed'];

class CaseModel {
  final String id; // Firestore document id
  final String caseId; // Human readable, e.g. CASE-001
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String notes;
  final String userId;
  final DateTime createdAt;

  CaseModel({
    required this.id,
    required this.caseId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.notes,
    required this.userId,
    required this.createdAt,
  });

  factory CaseModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return CaseModel(
      id: doc.id,
      caseId: d['caseId'] ?? 'CASE-???',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      category: d['category'] ?? 'Other',
      priority: d['priority'] ?? 'Low',
      status: d['status'] ?? 'Open',
      notes: d['notes'] ?? '',
      userId: d['userId'] ?? '',
      // createdAt is null for a split second while the server timestamp resolves
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

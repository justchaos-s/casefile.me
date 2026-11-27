import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case_model.dart';

class CaseService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _cases =>
      _db.collection('cases');

  /// All cases of one investigator, newest first.
  /// Sorting happens on the device so no composite index is needed.
  Stream<List<CaseModel>> watchCases(String uid) {
    return _cases.where('userId', isEqualTo: uid).snapshots().map((snap) {
      final list = snap.docs.map(CaseModel.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<CaseModel?> watchCase(String docId) {
    return _cases
        .doc(docId)
        .snapshots()
        .map((d) => d.exists ? CaseModel.fromDoc(d) : null);
  }

  /// Creates a case and gives it the next sequential ID (CASE-001...).
  /// A transaction keeps the counter safe even if two writes happen at once.
  Future<void> createCase({
    required String uid,
    required String title,
    required String description,
    required String category,
    required String priority,
    required String status,
    required String notes,
  }) {
    return _db.runTransaction((tx) async {
      final userRef = _db.collection('users').doc(uid);
      final snap = await tx.get(userRef);
      final next = ((snap.data()?['caseCounter'] ?? 0) as int) + 1;
      tx.set(userRef, {'caseCounter': next}, SetOptions(merge: true));

      tx.set(_cases.doc(), {
        'caseId': 'CASE-${next.toString().padLeft(3, '0')}',
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'status': status,
        'notes': notes,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateCase(String docId, Map<String, dynamic> data) =>
      _cases.doc(docId).update(data);

  Future<void> deleteCase(String docId) => _cases.doc(docId).delete();
}

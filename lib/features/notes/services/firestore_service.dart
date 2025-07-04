import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_on_short/features/authentication/controllers/auth_service.dart';
import 'package:notes_on_short/features/notes/models/note.dart';
import 'package:notes_on_short/utils/logger/logger.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class FirestoreService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = AuthService().instance;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<bool> hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  Future<bool> canSync() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) return false;
    if (!await hasInternetAccess()) return false;
    if (currentUserId == null) return false;
    return true;
  }

  Future<void> uploadNotes(List<Note> notes) async {
    if (!await canSync()) return;
    final userId = currentUserId!;
    for (final note in notes) {
      await _fireStore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(note.id.toString())
          .set({
        'title': note.title,
        'content': note.content,
        'lastUpdated': note.lastModified.toIso8601String(),
        'isSynced': true,
        'noteColor': note.noteColor,
        'isStarred': note.isStarred,
        'created': note.created.toIso8601String(),


      });
    }
  }

  Future<void> deleteCloudNotes(Set<String> noteIds) async {
    if (!await canSync()) return;
    final userId = currentUserId!;
    for (final id in noteIds) {
      await _fireStore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(id)
          .delete();
    }
  }

  Future<List<Note>> getCloudNotes() async {
    if (!await canSync()) return [];

    final userId = currentUserId!;
    try {
      final cloudSnapshot = await _fireStore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .get();

      return cloudSnapshot.docs.map((doc) {
        final data = doc.data();

        return Note()
          ..id = int.parse(doc.id)
          ..title = data['title'] ?? ''
          ..content = data['content']
          ..noteColor = data['noteColor'] ?? 'default' 
          ..created = DateTime.tryParse(data['created'] ?? '') ?? DateTime.now()
          ..lastModified = DateTime.tryParse(data['lastUpdated'] ?? '') ?? DateTime.now()
          ..isStarred = data['isStarred'] ?? false
          ..isSynced = true;
      }).toList();
    } catch (e) {
      return [];
    }
  }

}

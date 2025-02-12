import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:notes_on_short/models/note.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class NotesRepository extends ChangeNotifier {
  static late Isar isar;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static Future<void> initialize() async{
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([NoteSchema], directory: dir.path);
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    note.lastModified = DateTime.now();
    await isar.writeTxn(() async {
      await isar.notes.put(note);  // Save note locally (Isar)
    });

    notifyListeners();
    await syncNotes();
  }

  // Update a note
  Future<void> updateNote(Note note) async {
    note.lastModified = DateTime.now();
    await isar.writeTxn(() async {
      await isar.notes.put(note);  // Update note locally
    });

    notifyListeners();
    await syncNotes();
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() async {
      await isar.notes.delete(id);  // Delete note locally (Isar)
    });
    notifyListeners();
    await syncNotes();
  }

  // Fetch all notes
  Future<List<Note>> getNotes() async {
    return isar.notes.where().findAll();  // Fetch notes from Isar
  }

    // Check for actual internet access
  Future<bool> hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  // Sync notes with Firebase (online)
  Future<void> syncNotes() async {
  try {
    // Check connectivity
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();

    // If there is no internet connectivity, skip sync
    if (connectivityResult.contains(ConnectivityResult.none)) {
      print('No internet connectivity. Sync deferred.');
      return;
    }

    // Verify actual internet access
    final bool hasInternet = await hasInternetAccess();
    if (!hasInternet) {
      print('Internet access detected, but no actual access available. Sync deferred.');
      return;
    }

    // Fetch local notes
    final List<Note> localNotes = await getNotes();
    if (localNotes.isEmpty) {
      print('No local notes to sync.');
      return;
    }

    // Sync local notes to Firebase
    for (final note in localNotes) {
      if (!note.isSynced) {
        try {
          // Sync note to Firebase
          await _firestore.collection('users').doc('USER_ID') // Replace with actual user ID
              .collection('notes')
              .doc(note.id.toString())
              .set({
            'title': note.title,
            'content': note.content,
            'lastUpdated': note.lastModified.toIso8601String(),
          });

          // Mark note as synced locally
          note.isSynced = true;
          await isar.writeTxn(() async {
            await isar.notes.put(note); // Update sync status
          });

          print('Note synced to Firebase: ${note.id}');
        } catch (e) {
          print('Failed to sync note ${note.id} with Firebase: $e');
          // Optionally, log the error to a remote logging service
        }
      }
    }

    print('Sync completed successfully.');
  } catch (e) {
    // Handle unexpected errors
    print('An unexpected error occurred during sync: $e');
    // Optionally, log the error to a remote logging service
  }
}

   // Method to listen for connectivity changes and sync notes
  void listenForConnectivityChanges() {
  // Listen to connectivity changes (single result)
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
    // Assuming you want to handle the first result in the list
    ConnectivityResult result = results.first;

    if (result != ConnectivityResult.none) {
      // Check if the device is connected to the internet
      final hasInternet = await hasInternetAccess();
      if (hasInternet) {
        print('Connected to the internet. Syncing notes...');
        await syncNotes();  // Attempt syncing when back online
      } else {
        print('Internet access detected, but no actual access available. Sync deferred.');
      }
    } else {
      print('Disconnected from the internet. Sync deferred.');
    }
  });
}

  


  // Retry sync if previous sync attempt failed
  Future<void> retrySyncNotes({int retries = 3}) async {
    int retryCount = 0;

    while (retryCount < retries) {
      try {
        await syncNotes();
        print('Sync successful.');
        break;
      } catch (e) {
        retryCount++;
        print('Sync failed. Retrying... ($retryCount/$retries)');
        if (retryCount == retries) {
          print('Failed to sync after $retries attempts.');
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }
}

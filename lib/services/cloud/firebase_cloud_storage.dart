import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notey/services/cloud/cloud_note.dart';
import 'package:notey/services/cloud/cloud_storage_constants.dart';
import 'package:notey/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  /// Streams all notes for a specific user from the cloud storage.
  ///
  /// Takes a required parameter [ownerUserId] which is the ID of the user whose notes are to be streamed.
  /// Returns a [Stream] of [Iterable] of [CloudNote] objects.
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  /// Fetches all notes for a specific user from the cloud storage.
  ///
  /// Takes a required parameter [ownerUserId] which is the ID of the user whose notes are to be fetched.
  /// Returns an [Iterable] of [CloudNote] objects.
  /// Throws [CouldNotGetAllException] if there is an error during the fetch operation.
  Future<Iterable<CloudNote>> getNotes({required ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
        (value) {
          return value.docs.map(
            (doc) {
              return CloudNote(
                documentId: doc.id,
                ownerUserId: doc.data()[ownerUserIdFieldName],
                text: doc.data()[textFieldName],
              );
            },
          );
        },
      );
    } catch (e) {
      throw CouldNotGetAllException();
    }
  }

  void createNewNote({required ownerUserId}) async {
    notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateException();
    }
  }

  Future<void> deleteNote({required documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  //singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}

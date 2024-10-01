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
                date: doc.data()[dateFieldName],
                title: doc.data()[titleFieldName],
              );
            },
          );
        },
      );
    } catch (e) {
      throw CouldNotGetAllException();
    }
  }

  // Future<void> addTitleFieldToAllNotes() async {
  //   QuerySnapshot snapshot = await notes.get();
  //   for (QueryDocumentSnapshot doc in snapshot.docs) {
  //     await doc.reference.update({
  //       titleFieldName: '',
  //     });
  //   }
  //   print('DOCUMENTS UPDATED');
  // }

  Future<CloudNote> createNewNote({required ownerUserId}) async {
    final document = await notes.add(
      {
        ownerUserIdFieldName: ownerUserId,
        textFieldName: '',
        titleFieldName: '',
        dateFieldName: Timestamp.fromDate(DateTime.now()),
      },
    );
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
      title: '',
      date: Timestamp.fromDate(DateTime.now()),
    );
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
    required String title,
  }) async {
    try {
      await notes
          .doc(documentId)
          .update({textFieldName: text, titleFieldName: title});
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

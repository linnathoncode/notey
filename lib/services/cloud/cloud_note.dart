import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloud_storage_constants.dart';

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final Timestamp date;

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.date,
  });

  /// Creates a `CloudNote` instance from a Firestore document snapshot.
  ///
  /// This constructor initializes the `CloudNote` object using the data
  /// from the provided `QueryDocumentSnapshot`.
  ///
  /// - `snapshot`: A `QueryDocumentSnapshot` containing the note data.
  ///
  /// The following fields are extracted from the snapshot:
  /// - `documentId`: The unique identifier of the document.
  /// - `ownerUserId`: The ID of the user who owns the note.
  /// - `text`: The content of the note as a string.

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String,
        date = snapshot.data()[dateFieldName] as Timestamp;
}

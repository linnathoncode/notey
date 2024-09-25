// import 'package:flutter/material.dart';
// import 'package:notey/services/cloud/cloud_note.dart';
// import 'package:notey/services/cloud/firebase_cloud_storage.dart';
// import 'package:notey/utilities/colors.dart';
// import 'package:notey/utilities/show_dialog.dart';
// import 'package:notey/views/notes/create_or_update_note_view.dart';

// class NoteCard extends StatefulWidget {
//   final Iterable<CloudNote> allNotes;
//   final ValueNotifier<bool> isDeleteMode;
//   // final List<CloudNote> trashCan;

//   const NoteCard({
//     super.key,
//     required this.allNotes,
//     required this.isDeleteMode,
//     // required this.trashCan,
//   });

//   @override
//   State<NoteCard> createState() => _NoteCardState();
// }

// class _NoteCardState extends State<NoteCard> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   // void onDelete(CloudNote note) {
//   //   if (widget.trashCan.contains(note)) {
//   //     widget.trashCan.remove(note);
//   //   } else {
//   //     widget.trashCan.add(note);
//   //   }

//   //   widget.isDeleteMode.value = widget.trashCan.isNotEmpty;
//   //   setState(() {});
//   // }

//   Future<void> _confirmAndDeleteNote(CloudNote note) async {
//     final firebase = FirebaseCloudStorage();

//     const String dialogContent = "Note will be deleted forever, are you sure?";
//     final shouldDelete = await showDeleteNoteDialog(context, dialogContent);
//     if (shouldDelete) {
//       firebase.deleteNote(documentId: note.documentId);
//       await firebase.deleteNote(documentId: note.documentId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final notes = widget.allNotes.toList();
//     notes.sort(
//       (a, b) => b.date.compareTo(a.date),
//     );
//     return notes.isEmpty
//         ? const Center(child: Text('No notes available.'))
//         : Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 20000,
//                   child: ListView.builder(
//                     itemCount: notes.length,
//                     itemBuilder: (context, index) {
//                       final note = notes[index];
//                       // final isSelected = widget.trashCan.contains(note);
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 6,
//                         ), // Increased padding for shadow
//                         child: Material(
//                           shadowColor: kPrimaryColor,
//                           // elevation: isSelected
//                           //     ? 8.0
//                           //     : 2.0,
//                           elevation: 2.0,

//                           /// Adjust elevation based on selection
//                           color: kAccentColor, // Background color
//                           borderRadius: BorderRadius.circular(8),
//                           child: ListTile(
//                             onTap: () => Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) => CreateOrUpdateNoteView(
//                                   currentNote: note,
//                                 ),
//                               ),
//                             ),
//                             trailing: IconButton(
//                               color: kSecondaryColor,
//                               icon: const Icon(Icons.delete),
//                               onPressed: () {
//                                 if (context.mounted) {
//                                   _confirmAndDeleteNote(note);
//                                 }
//                               },
//                             ),
//                             selectedColor: kAccentColor,
//                             selectedTileColor: kPrimaryColor,
//                             title: Text(
//                               note.text,
//                               maxLines: 1,
//                               softWrap: true,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               side: const BorderSide(
//                                 color: kSecondaryColor,
//                                 width: 3,
//                                 style: BorderStyle.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           );
//   }
// }

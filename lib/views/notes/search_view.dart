import 'package:flutter/material.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/cloud/cloud_note.dart';
import 'package:notey/services/cloud/firebase_cloud_storage.dart';
import 'package:notey/utilities/colors.dart';
import 'package:notey/views/notes/create_or_update_note_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final FirebaseCloudStorage _notesService;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<CloudNote> _filteredNotes = [];
  List<CloudNote> _allNotes = [];

  final userId = AuthService.firebase().currentUser!.id;

  void filterItems(String query) {
    setState(() {
      _filteredNotes = _allNotes
          .where(
              (item) => item.text.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    // print("FILTERED NOTES! $_filteredNotes");
  }

  Future<void> getAllNotes() async {
    final notes = await _notesService.getNotes(ownerUserId: userId);
    setState(() {
      _allNotes = notes.toList();
      _filteredNotes = _allNotes; // Initialize _filteredNotes with all notes
    });
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    getAllNotes(); // Fetch notes when the widget is initialized
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              decoration: BoxDecoration(
                color: kAccentColor,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                    color: kPrimaryColor,
                    blurRadius: 5.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                onChanged: filterItems,
                obscureText: false,
                enableSuggestions: false,
                autofocus: true,
                autocorrect: false,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  errorStyle: TextStyle(color: kErrorColor),
                  hintText: "Search Notes...",
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                return _buildListItem(
                  _filteredNotes[index],
                  null, // No animation required for ListView
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
      CloudNote note, Animation<double>? animation, int index) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      child: Material(
        shadowColor: kPrimaryColor,
        elevation: 2.0,
        color: kAccentColor,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateOrUpdateNoteView(
                  currentNote: note,
                ),
              ),
            );
          },
          title: note.title.isNotEmpty
              ? Text(
                  note.title,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kFontColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  note.text,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kFontColor,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
          subtitle: note.title.isNotEmpty
              ? Text(
                  note.text,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kFontColor,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: kSecondaryColor,
              width: 3,
              style: BorderStyle.none,
            ),
          ),
        ),
      ),
    );

    // If animation is null, return the child directly.
    if (animation == null) {
      return child;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.5, 0), // Swipes from the right
        end: Offset.zero, // Ends at its final position
      ).animate(animation),
      child: child,
    );
  }
}

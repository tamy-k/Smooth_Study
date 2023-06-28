import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:smooth_study/app_provider.dart';
import 'package:smooth_study/model/notes_model.dart';
import 'package:smooth_study/screens/single_note_view_page.dart';
import 'package:smooth_study/utils/theme_provider.dart';
import 'package:smooth_study/widget/music_notes_widget.dart';
import 'package:uuid/uuid.dart';

class AllNotesViewPage extends StatefulWidget {
  final String courseCode;
  final String materialName;
  const AllNotesViewPage({
    super.key,
    required this.courseCode,
    required this.materialName,
  });

  @override
  State<AllNotesViewPage> createState() => _AllNotesViewPageState();
}

class _AllNotesViewPageState extends State<AllNotesViewPage> {
  late TextEditingController searchController;
  late AppProvider _appProvider;
  final FocusNode _focusNode = FocusNode();

  @override
  initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appProvider = Provider.of<AppProvider>(
      context,
      listen: false,
    );
    _appProvider.getNotes(widget.materialName);
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        _appProvider.clearNotesSearch();
        return;
      }
      _appProvider.searchNotes(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final notes = Provider.of<AppProvider>(context).notes;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // PersonalNotesBox().clearNotes();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SingleNoteViewPage(
                materialName: widget.materialName,
                note: NoteModel.newNote(
                  materialName: widget.materialName,
                  uid: const Uuid().v4(),
                ),
                courseCode: widget.courseCode,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).padding.top,
              horizontal: 24,
            ),
            width: double.maxFinite,
            height: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              image: const DecorationImage(
                  alignment: Alignment.centerRight,
                  image: AssetImage('assets/back.png'),
                  fit: BoxFit.fitHeight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Text(
                          '${widget.materialName} Notes',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                    onTap: Navigator.of(context).pop,
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Consumer<ThemeProvider>(
              builder: (context, themeCtrl, _) => TextFormField(
                focusNode: _focusNode,
                controller: searchController,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color:
                          themeCtrl.isDarkMode ? null : const Color(0xAAFFFFFF),
                    ),
                    suffixIcon: AnimatedCrossFade(
                      firstChild: const SizedBox(),
                      secondChild: IconButton(
                        onPressed: () {
                          _focusNode.unfocus();
                          searchController.clear();
                          _appProvider.clearNotesSearch();
                        },
                        icon: const Icon(Icons.cancel),
                      ),
                      crossFadeState: _focusNode.hasPrimaryFocus
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 500),
                    ),
                    hintText: "Search Notes",
                    hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xAAFFFFFF),
                        ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(54),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(54),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(54),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(54),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(54),
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16)),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: themeCtrl.isDarkMode ? null : Colors.white,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: _appProvider.noteSearchResult.isEmpty
                      ? _appProvider.notesSearched
                          ? [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LottieBuilder.asset('assets/empty1.json'),
                                  const Center(
                                    child: Text('No Results'),
                                  ),
                                ],
                              ),
                            ] // Search is Empty
                          : notes.isEmpty
                              ? [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LottieBuilder.asset(
                                          'assets/no_notes.json'),
                                      const Center(
                                        child: Text('No Notes ...yet'),
                                      ),
                                    ],
                                  ),
                                ]
                              : List.generate(
                                  notes.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => SingleNoteViewPage(
                                            materialName: widget.materialName,
                                            note: notes[index],
                                            courseCode: widget.courseCode,
                                          ),
                                        ),
                                      );
                                    },
                                    child: NoteWidget(
                                      size: size,
                                      note: notes[index],
                                      courseCode: widget.courseCode,
                                    ),
                                  ),
                                )
                      : List.generate(
                          _appProvider.noteSearchResult.length,
                          (index) => GestureDetector(
                            onTap: _appProvider.noteSearchResult[index] != null
                                ? () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => SingleNoteViewPage(
                                          materialName: widget.materialName,
                                          note: _appProvider
                                              .noteSearchResult[index]!,
                                          courseCode: widget.courseCode,
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                : null,
                            child: NoteWidget(
                              size: size,
                              courseCode: widget.courseCode,
                              note: _appProvider.noteSearchResult[index]!,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

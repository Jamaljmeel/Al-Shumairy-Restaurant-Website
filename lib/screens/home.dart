import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/components/faderoute.dart';
import 'package:notes/data/models.dart';
import 'package:notes/screens/edit.dart';
import 'package:notes/screens/view.dart';
import 'package:notes/services/database.dart';
import 'settings.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../components/cards.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final Function(Brightness brightness) changeTheme;
  const MyHomePage({required Key key, required this.title, required this.changeTheme})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFlagOn = false;
  List<NotesModel> notesList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchEmpty = true;
  int _selectedIndex = 0;
  Color _backgroundColor = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();
  }

  setNotesFromDB() async {
    var fetchedNotes = await NotesDatabaseService.db.getNotesFromDB();
    setState(() {
      notesList = fetchedNotes;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        isFlagOn = true;
      } else {
        isFlagOn = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final EdgeInsets devicePadding = MediaQuery.of(context).viewPadding;

    final themeGradient = LinearGradient(
      colors: [const Color(0xffe0eafc), const Color(0xffcfdef3)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : _backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.03,
            screenHeight * 0.02,
            screenWidth * 0.03,
            0,
          ),
          child: Column(
            children: [
              // App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ملاحظاتي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.deepPurpleAccent,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      OMIcons.settings,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => SettingsPage(
                              changeTheme: widget.changeTheme),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              SizedBox(height: screenHeight * 0.02),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: handleSearch,
                  keyboardType: TextInputType.text,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff262c53),
                  ),
                  decoration: InputDecoration(
                    hintText: "ابحث عن ملاحظة...",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: isSearchEmpty
                        ? null
                        : IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: cancelSearch,
                          ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                      horizontal: screenWidth * 0.03,
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.015),

              // Important Notes Indicator
              Visibility(
                visible: isFlagOn,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 180),
                  height: screenHeight * 0.05,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Text(
                        'عرض الملاحظات المهمة فقط'.toUpperCase(),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontFamily: 'Cairo',
                          color: Colors.deepPurpleAccent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.015),

              // Notes Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.01,
                  ),
                  child: buildNoteComponentsList().isNotEmpty
                      ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth > 600 ? 3 : 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: screenWidth * 0.02,
                            mainAxisSpacing: screenHeight * 0.015,
                          ),
                          itemCount: buildNoteComponentsList().length,
                          itemBuilder: (context, index) {
                            return buildNoteComponentsList()[index];
                          },
                        )
                      : Center(
                          child: Text(
                            "لا توجد ملاحظات بعد!",
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: screenWidth * 0.045,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ✅ زر إضافة ملاحظة جديدة
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: gotoEditNote,
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'الكل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'المهمة',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurpleAccent,
        onTap: _onItemTapped,
      ),
    );
  }

  // Color Picker Dialog
  void showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Wrap(
            children: [
              Text(
                'اختر لون الخلفية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenWidth * 0.04),
              Wrap(
                spacing: screenWidth * 0.03,
                runSpacing: screenWidth * 0.03,
                alignment: WrapAlignment.center,
                children: [
                  _buildColorOption(Colors.blue.shade200),
                  _buildColorOption(Colors.green.shade200),
                  _buildColorOption(Colors.pink.shade200),
                  _buildColorOption(Colors.yellow.shade200),
                  _buildColorOption(Colors.teal.shade200),
                  _buildColorOption(Colors.deepPurple.shade200),
                  _buildColorOption(Colors.orange.shade200),
                  _buildColorOption(Colors.brown.shade200),
                  _buildColorOption(Colors.grey.shade300),
                  _buildColorOption(Colors.cyan.shade200),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              Center(
                child: TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text(
                    "إغلاق",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOption(Color color) {
    final double size = MediaQuery.of(context).size.width * 0.12;
    return GestureDetector(
      onTap: () {
        setState(() {
          _backgroundColor = color;
        });
        Navigator.pop(context);
      },
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _backgroundColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  // Note Card Components
  List<Widget> buildNoteComponentsList() {
    List<Widget> noteComponentsList = [];
    notesList.sort((a, b) => b.date.compareTo(a.date));
    
    if (searchController.text.isNotEmpty) {
      notesList.forEach((note) {
        if (note.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
            note.content.toLowerCase().contains(searchController.text.toLowerCase())) {
          noteComponentsList.add(
            NoteCardComponent(
              key: UniqueKey(),
              noteData: note,
              onTapAction: openNoteToRead,
            ),
          );
        }
      });
      return noteComponentsList;
    }
    
    if (isFlagOn) {
      notesList.forEach((note) {
        if (note.isImportant) {
          noteComponentsList.add(
            NoteCardComponent(
              key: UniqueKey(),
              noteData: note,
              onTapAction: openNoteToRead,
            ),
          );
        }
      });
    } else {
      notesList.forEach((note) {
        noteComponentsList.add(
          NoteCardComponent(
            key: UniqueKey(),
            noteData: note,
            onTapAction: openNoteToRead,
          ),
        );
      });
    }
    return noteComponentsList;
  }

  void handleSearch(String value) {
    setState(() {
      isSearchEmpty = value.isEmpty;
    });
  }

  void gotoEditNote() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            EditNotePage(triggerRefetch: refetchNotesFromDB),
      ),
    );
  }

  void refetchNotesFromDB() async {
    await setNotesFromDB();
  }

  openNoteToRead(NotesModel noteData) async {
    await Navigator.push(
      context,
      FadeRoute(page: ViewNotePage(currentNote: noteData, triggerRefetch: refetchNotesFromDB)),
    );
  }

  void cancelSearch() {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      searchController.clear();
      isSearchEmpty = true;
    });
  }
}

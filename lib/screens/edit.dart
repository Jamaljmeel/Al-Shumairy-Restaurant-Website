import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/data/models.dart';
import 'package:notes/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class EditNotePage extends StatefulWidget {
  final Function() triggerRefetch;
  final NotesModel? existingNote;
  
  const EditNotePage({
    Key? key,
    required this.triggerRefetch,
    this.existingNote,
  }) : super(key: key);
  
  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  bool isDirty = false;
  late bool isNoteNew;
  FocusNode titleFocus = FocusNode();
  FocusNode contentFocus = FocusNode();
  late NotesModel currentNote;
  late TextEditingController titleController;
  late TextEditingController contentController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingNote == null) {
      currentNote = NotesModel(
        id: 0,
        title: '',
        content: '',
        date: DateTime.now(),
        isImportant: false,
      );
      isNoteNew = true;
    } else {
      currentNote = widget.existingNote!;
      isNoteNew = false;
    }
    
    titleController = TextEditingController(text: currentNote.title);
    contentController = TextEditingController(text: currentNote.content);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    titleFocus.dispose();
    contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () {
          // إخفاء لوحة المفاتيح عند النقر خارج الحقول
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // خلفية المحتوى
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).cardColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.3],
                ),
              ),
            ),
            
            // محتوى الصفحة
            SingleChildScrollView(
              padding: EdgeInsets.only(top: size.height * 0.12),
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان الملاحظة
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                      vertical: size.height * 0.02,
                    ),
                    child: TextFormField(
                      focusNode: titleFocus,
                      autofocus: true,
                      controller: titleController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textDirection: TextDirection.rtl,
                      onFieldSubmitted: (text) {
                        titleFocus.unfocus();
                        FocusScope.of(context).requestFocus(contentFocus);
                      },
                      onChanged: (value) => setState(() => isDirty = true),
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: textTheme.titleLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'أدخل عنواناً',
                        hintStyle: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  
                  // خط فاصل
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    child: Divider(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      height: 1,
                      thickness: 0.8,
                    ),
                  ),
                  
                  // محتوى الملاحظة
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                      vertical: size.height * 0.02,
                    ),
                    child: TextFormField(
                      focusNode: contentFocus,
                      controller: contentController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textDirection: TextDirection.rtl,
                      onChanged: (value) => setState(() => isDirty = true),
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                        color: textTheme.bodyMedium?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابدأ الكتابة...',
                        hintStyle: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                      ),
                    ),
                  ),
                  
                  // معلومات الملاحظة
                  if (!isNoteNew)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                        vertical: size.height * 0.02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.edit_calendar_outlined,
                            size: size.width * 0.04,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: size.width * 0.015),
                          Text(
                            'تم التعديل: ${currentNote.dateFormatted}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: size.width * 0.035,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // الشريط العلوي الزجاجي
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: size.height * 0.12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withOpacity(0.85),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new),
                          onPressed: handleBack,
                          splashRadius: 20,
                        ),
                        Spacer(),
                        if (isDirty)
                          Padding(
                            padding: EdgeInsets.only(right: size.width * 0.03),
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : handleSave,
                              icon: Icon(
                                _isSaving ? Icons.hourglass_empty : Icons.save_outlined,
                                size: size.width * 0.05,
                              ),
                              label: Text(
                                _isSaving ? "جاري الحفظ..." : "حفظ",
                                style: TextStyle(fontSize: size.width * 0.035),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04,
                                  vertical: size.height * 0.01,
                                ),
                                elevation: 4,
                                textStyle: TextStyle(
                                  fontSize: size.width * 0.035,
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            currentNote.isImportant
                                ? Icons.flag_rounded
                                : OMIcons.flag,
                            size: size.width * 0.055,
                          ),
                          onPressed: markImportantAsDirty,
                          color: currentNote.isImportant
                              ? Colors.orangeAccent
                              : null,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: size.width * 0.055,
                          ),
                          onPressed: handleDelete,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // مؤشر التحميل
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.05),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: size.width * 0.06,
                          width: size.width * 0.06,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(width: size.width * 0.04),
                        Text(
                          "جاري الحفظ...",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void handleSave() async {
    setState(() {
      currentNote.title = titleController.text.trim();
      currentNote.content = contentController.text.trim();
      _isSaving = true;
    });
    
    try {
      if (isNoteNew) {
        var newNote = await NotesDatabaseService.db.addNoteInDB(currentNote);
        setState(() {
          currentNote = newNote;
          isNoteNew = false;
          isDirty = false;
        });
      } else {
        await NotesDatabaseService.db.updateNoteInDB(currentNote);
        setState(() => isDirty = false);
      }
      
      widget.triggerRefetch();
      titleFocus.unfocus();
      contentFocus.unfocus();
      
      // تأخير بسيط لعرض مؤشر التحميل قبل العودة
      await Future.delayed(Duration(milliseconds: 400));
      Navigator.pop(context);
    } catch (e) {
      // عرض رسالة خطأ في حالة فشل الحفظ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("فشل في حفظ الملاحظة، حاول مجددًا"),
          backgroundColor: Colors.red.shade600,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void markImportantAsDirty() {
    setState(() {
      currentNote.isImportant = !currentNote.isImportant;
      isDirty = true;
    });
  }

  void handleDelete() async {
    if (isNoteNew) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'حذف الملاحظة',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(
            'هل أنت متأكد أنك تريد حذف هذه الملاحظة؟ لا يمكن التراجع عن هذا الإجراء.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                'إلغاء',
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                await NotesDatabaseService.db.deleteNoteInDB(currentNote);
                widget.triggerRefetch();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'حذف',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void handleBack() {
    if (isDirty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'هل تريد الخروج دون حفظ؟',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'المحتوى غير المحفوظ سيُفقد.',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
            ),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text(
                'إلغاء',
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'الخروج',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/data/models.dart';
import 'package:notes/screens/edit.dart';
import 'package:notes/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ViewNotePage extends StatefulWidget {
  final Function() triggerRefetch;
  final NotesModel currentNote;

  const ViewNotePage({
    Key? key,
    required this.triggerRefetch,
    required this.currentNote,
  }) : super(key: key);

  @override
  _ViewNotePageState createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  bool headerShouldShow = false;
  late ScrollController _scrollController;
  double _headerHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        headerShouldShow = true;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && _headerHeight != 60) {
      setState(() {
        _headerHeight = 60;
      });
    } else if (_scrollController.offset <= 50 && _headerHeight != 80) {
      setState(() {
        _headerHeight = 80;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final title = widget.currentNote.title;
    final content = widget.currentNote.content;
    final date = DateFormat.yMd().add_jm().format(widget.currentNote.date);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // خلفية الملاحظة مع تدرج
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).cardColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // محتوى الملاحظة
          CustomScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              // عنوان الملاحظة والبيانات
              SliverAppBar(
                expandedHeight: size.height * 0.25,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // صورة خلفية اختيارية
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.1),
                                Theme.of(context).cardColor.withOpacity(0.3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      // محتوى العنوان
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                          vertical: size.height * 0.04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: headerShouldShow ? 1 : 0,
                              child: Text(
                                title.isNotEmpty ? title : "بدون عنوان",
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: size.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: textTheme.titleLarge?.color,
                                ),
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: size.width * 0.04,
                                  color: Colors.grey.shade500,
                                ),
                                SizedBox(width: size.width * 0.015),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: size.width * 0.035,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),
                                if (widget.currentNote.isImportant)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.flag,
                                        size: size.width * 0.04,
                                        color: Colors.orangeAccent,
                                      ),
                                      SizedBox(width: size.width * 0.01),
                                      Text(
                                        "مهم",
                                        style: TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontSize: size.width * 0.03,
                                          color: Colors.orangeAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actionsIconTheme: IconThemeData(
                  color: Theme.of(context).iconTheme.color,
                  size: size.width * 0.06,
                ),
                title: headerShouldShow
                    ? Text(
                        title.isNotEmpty && title.length > 20
                            ? "${title.substring(0, 20)}..."
                            : title.isNotEmpty ? title : "بدون عنوان",
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                titleSpacing: 0,
              ),
              
              // محتوى الملاحظة
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.04),
                      child: Text(
                        content.isNotEmpty ? content : "لا يوجد محتوى في هذه الملاحظة",
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: size.width * 0.045,
                          height: 1.8,
                          color: textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.right,
                        softWrap: true,
                        overflow: content.isEmpty ? TextOverflow.visible : TextOverflow.clip,
                      ),
                    ),
                  ),
                ),
              ),
              
              // نص إرشادي عند عدم وجود محتوى
              if (content.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.01,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orangeAccent,
                          size: size.width * 0.045,
                        ),
                        SizedBox(width: size.width * 0.015),
                        Text(
                          "هذه الملاحظة لا تحتوي على أي محتوى بعد",
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: size.width * 0.035,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // مساحة فارغة في الأسفل
              SliverPadding(
                padding: EdgeInsets.only(bottom: size.height * 0.16),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(height: size.height * 0.02),
                ),
              ),
            ],
          ),
          
          // الشريط العلوي الزجاجي
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: _headerHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor.withOpacity(0.75),
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
                      // textDirection: TextDirection.rtl,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new),
                          onPressed: handleBack,
                          splashRadius: 20,
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(OMIcons.edit),
                          onPressed: handleEdit,
                          splashRadius: 24,
                        ),
                        IconButton(
                          icon: Icon(OMIcons.share),
                          onPressed: handleShare,
                          splashRadius: 24,
                        ),
                        IconButton(
                          icon: Icon(
                            widget.currentNote.isImportant
                                ? Icons.flag
                                : OMIcons.flag,
                          ),
                          onPressed: markImportantAsDirty,
                          color: widget.currentNote.isImportant
                              ? Colors.orangeAccent
                              : null,
                          splashRadius: 24,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: handleDelete,
                          splashRadius: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // زر العمل الرئيسي
          Positioned(
            bottom: size.height * 0.02,
            left: size.width * 0.05,
            right: size.width * 0.05,
            child: ElevatedButton.icon(
              onPressed: handleEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: size.width * 0.06,
              ),
              label: Text(
                "تحرير الملاحظة",
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontFamily: 'Tajawal',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.015,
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void markImportantAsDirty() async {
    setState(() {
      widget.currentNote.isImportant = !widget.currentNote.isImportant;
    });
    await NotesDatabaseService.db.updateNoteInDB(widget.currentNote);
    widget.triggerRefetch();
  }

  void handleEdit() {
    Navigator.pop(context);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditNotePage(
          key: UniqueKey(),
          existingNote: widget.currentNote,
          triggerRefetch: widget.triggerRefetch,
        ),
      ),
    );
  }

  void handleBack() {
    Navigator.pop(context);
  }

  void handleDelete() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "حذف الملاحظة",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "هل أنت متأكد أنك تريد حذف هذه الملاحظة؟ لا يمكن التراجع عن هذا الإجراء.",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await NotesDatabaseService.db
                      .deleteNoteInDB(widget.currentNote);
                  widget.triggerRefetch();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.delete_forever),
                label: Text("حذف الملاحظة"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 4,
                ),
              ),
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text("إلغاء", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  void handleShare() {
    // سيتم تنفيذ ميزة المشاركة هنا في المستقبل
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("ميزة المشاركة قيد التطوير"),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
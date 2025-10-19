import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models.dart';

// قائمة الألوان المُحسّنة
List<Color> colorList = [
  const Color.fromARGB(255, 11, 12, 12),
  const Color.fromARGB(255, 18, 18, 18),
  const Color.fromARGB(255, 34, 34, 36),
  const Color.fromARGB(255, 18, 17, 17),
  Colors.cyan.shade600,
  Colors.teal.shade600,
  Colors.orange.shade700,
  Colors.deepPurple.shade600,
];

class NoteCardComponent extends StatelessWidget {
  const NoteCardComponent({
    required this.noteData,
    required this.onTapAction,
    required Key key,
  }) : super(key: key);

  final NotesModel noteData;
  final Function(NotesModel noteData) onTapAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    String neatDate = DateFormat.yMd().add_jm().format(noteData.date);

    // اختيار لون ديناميكي بناءً على عنوان الملاحظة
    Color cardColor = colorList.elementAt(
      noteData.title.length % colorList.length,
    );
    Color shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.1)
        : cardColor.withOpacity(0.3);

    return Container(
      margin: EdgeInsets.fromLTRB(
        size.width * 0.03,
        size.height * 0.01,
        size.width * 0.03,
        size.height * 0.01,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: noteData.isImportant
                ? cardColor.withOpacity(0.5)
                : shadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onTapAction(noteData),
          splashColor: cardColor.withOpacity(0.2),
          highlightColor: cardColor.withOpacity(0.1),
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // للغة العربية
              children: <Widget>[
                // رأس الملاحظة مع العناوين
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.width * 0.02),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notes,
                        color: cardColor,
                        size: size.width * 0.06,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: size.width * 0.03,
                        ),
                        child: Text(
                          '${noteData.title.trim().isEmpty
                              ? "بدون عنوان"
                              : noteData.title.trim().length <= 25
                              ? noteData.title.trim()
                              : noteData.title.trim().substring(0, 25)}${noteData.title.trim().length > 25 ? "..." : ""}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: size.width * 0.045,
                            fontWeight: noteData.isImportant
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: textTheme.titleMedium?.color,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.015),

                // محتوى الملاحظة
                Flexible(
                  child: Text(
                    '${noteData.content.trim().split('\n').first.isEmpty
                        ? "محتوى فارغ"
                        : noteData.content.trim().split('\n').first.length <= 45
                        ? noteData.content.trim().split('\n').first
                        : noteData.content.trim().split('\n').first.substring(0, 45)}${noteData.content.trim().split('\n').first.length > 45 ? "..." : ""}',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: size.width * 0.038,
                      color: textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: size.height * 0.015),

                // تفاصيل الملاحظة
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '$neatDate',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: size.width * 0.03,
                          color: textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                    // Spacer(),
                    if (noteData.isImportant)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.02,
                          vertical: size.height * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag,
                              size: size.width * 0.035,
                              color: Colors.orange.shade800,
                            ),
                            SizedBox(width: size.width * 0.01),
                            Text(
                              "مهم",
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: size.width * 0.03,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddNoteCardComponent extends StatelessWidget {
  const AddNoteCardComponent({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.fromLTRB(
        size.width * 0.03,
        size.height * 0.01,
        size.width * 0.03,
        size.height * 0.01,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).primaryColor,
                    size: size.width * 0.08,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  'ملاحظة جديدة',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: textTheme.bodyMedium?.color,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'اضغط لإضافة ملاحظة جديدة',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: textTheme.bodySmall?.color,
                    fontSize: size.width * 0.032,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

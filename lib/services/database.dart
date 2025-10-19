import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models.dart';

class NotesDatabaseService {
  // Constructor خاص
  NotesDatabaseService._();

  // Singleton instance
  static final NotesDatabaseService db = NotesDatabaseService._();

  // قاعدة البيانات - أصبحت nullable بدل late
  Database? _database;

  // Getter للحصول على قاعدة البيانات مع التهيئة
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await init();
    return _database!;
  }

  // تهيئة قاعدة البيانات
  Future<Database> init() async {
    String dbPath = await getDatabasesPath();
    String fullPath = join(dbPath, 'notes.db');
    print("Database path: $fullPath");

    return await openDatabase(
      fullPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE Notes (
            _id INTEGER PRIMARY KEY,
            title TEXT,
            content TEXT,
            date TEXT,
            isImportant INTEGER
          );
        ''');
        print('New table created at $fullPath');
      },
    );
  }

  // إضافة ملاحظة
  Future<NotesModel> addNoteInDB(NotesModel newNote) async {
    final db = await database;
    if (newNote.title.trim().isEmpty) newNote.title = 'Untitled Note';

    int id = await db.insert('Notes', {
      'title': newNote.title,
      'content': newNote.content,
      'date': newNote.date.toIso8601String(),
      'isImportant': newNote.isImportant ? 1 : 0,
    });

    newNote.id = id;
    print('Note added: ${newNote.title} ${newNote.content}');
    return newNote;
  }

  // تحديث ملاحظة
  Future<void> updateNoteInDB(NotesModel updatedNote) async {
    final db = await database;
    await db.update(
      'Notes',
      updatedNote.toMap(),
      where: '_id = ?',
      whereArgs: [updatedNote.id],
    );
    print('Note updated: ${updatedNote.title} ${updatedNote.content}');
  }

  // حذف ملاحظة
  Future<void> deleteNoteInDB(NotesModel noteToDelete) async {
    final db = await database;
    await db.delete(
      'Notes',
      where: '_id = ?',
      whereArgs: [noteToDelete.id],
    );
    print('Note deleted');
  }

  // جلب كل الملاحظات
  Future<List<NotesModel>> getNotesFromDB() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Notes',
      columns: ['_id', 'title', 'content', 'date', 'isImportant'],
    );

    return maps.map((map) => NotesModel.fromMap(map)).toList();
  }
}

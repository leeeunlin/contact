import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

int page = 1;
bool hasNext = false;
bool isFirstLoading = false;

class ContactDatabase {
  static final ContactDatabase instance = ContactDatabase._init();
  static Database? _database;

  ContactDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contact.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print(path);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        seq INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        number TEXT,
        email TEXT
      )
    ''');
  }

  Future<void> testDataSet() async {
    final db = await instance.database;
    for (int i = 0; i < 200; i++) {
      await db.insert('contacts', {
        'name': '이름 $i',
        'number': '번호 $i',
        'email': '이메일 $i',
      });
    }
  }

  Future<void> deleteAllContacts() async {
    final db = await instance.database;
    await db.delete('contacts');
    page = 1;
    isFirstLoading = false;
    hasNext = false;
  }

  Future<void> insertContact(Map<String, dynamic> contact) async {
    final db = await instance.database;
    contact.remove('seq'); // seq는 자동 증가이므로 제거
    await db.insert('contacts', contact);
  }

  Future<void> updateContact(Map<String, dynamic> contact) async {
    final db = await instance.database;
    await db.update(
      'contacts',
      contact,
      where: 'seq = ${contact['seq']}',
      whereArgs: [contact['seq']],
    );
  }

  Future<void> deleteContact(int seq) async {
    final db = await instance.database;
    await db.delete('contacts', where: 'seq = $seq', whereArgs: [seq]);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await instance.database;
    final offset = (page - 1) * 20;

    var aaa = await db.query(
      'contacts',
      limit: 21,
      offset: offset,
      orderBy: 'name ASC',
    );

    hasNext = aaa.length > 20;
    return aaa.take(20).toList();
  }

  // 추가적인 CRUD 메서드는 필요에 따라 구현
}

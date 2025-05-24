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
        email TEXT,
        initial TEXT
      )
    ''');
  }

  Future<void> testDataSet() async {
    final db = await instance.database;
    for (int i = 0; i < 200; i++) {
      await db.insert('contacts', {
        'name': '이름 $i',
        'number': '01000$i',
        'email': 'mail$i@mailll.com',
        'initial': getInitial('이름 $i'),
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
    contact['initial'] = getInitial(contact['name'] ?? '');
    await db.insert('contacts', contact);
  }

  Future<void> updateContact(Map<String, dynamic> contact) async {
    final db = await instance.database;
    contact['initial'] = getInitial(contact['name'] ?? '');
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

  // 초성 추출 함수
  String getInitial(String text) {
    const initials = [
      'ㄱ',
      'ㄲ',
      'ㄴ',
      'ㄷ',
      'ㄸ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅃ',
      'ㅅ',
      'ㅆ',
      'ㅇ',
      'ㅈ',
      'ㅉ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ',
    ];
    String result = '';
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i) - 0xAC00;
      if (code >= 0 && code <= 11171) {
        result += initials[(code ~/ 588)];
      } else {
        result += text[i];
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> searchContacts(String keyword) async {
    final db = await instance.database;
    final initialKeyword = getInitial(keyword);
    final result = await db.query(
      'contacts',
      where: 'initial LIKE ? OR name LIKE ? OR number LIKE ?',
      whereArgs: ['%$initialKeyword%', '%$keyword%', '%$keyword%'],
      orderBy: 'name ASC',
    );
    return result;
  }
}

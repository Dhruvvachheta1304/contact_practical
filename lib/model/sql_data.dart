import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _database;

  // Initialize the database
  static Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'contacts_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE contacts(id INTEGER PRIMARY KEY, name TEXT, mobileNumber TEXT, birthDate TEXT)",
        );
      },
      version: 1,
    );
  }

  // Insert a contact into the database
  static Future<void> insertContact(Contact contact) async {
    await _database?.insert(
      'contacts',
      contact.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all contacts from the database
  static Future<List<Contact>> getAllContacts() async {
    final List<Map<String, dynamic>>? maps = await _database?.query('contacts');
    return List.generate(maps!.length, (i) {
      return Contact(
        id: maps[i]['id'],
        name: maps[i]['name'],
        mobileNumber: maps[i]['mobileNumber'],
        birthDate: maps[i]['birthDate'],
      );
    });
  }

  // Update a contact in the database
  static Future<void> updateContact(Contact contact) async {
    await _database?.update(
      'contacts',
      contact.toMap(),
      where: "id = ?",
      whereArgs: [contact.id],
    );
  }

  // Delete a contact from the database
  static Future<void> deleteContact(int id) async {
    await _database?.delete(
      'contacts',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

class Contact {
  final int? id;
  final String? name;
  final String? mobileNumber;
  final String? birthDate;

  Contact({this.id, this.name, this.mobileNumber, this.birthDate});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'birthDate': birthDate,
    };
  }
}

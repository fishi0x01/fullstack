import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'model.dart';

class DBProvider {
  Future<Database> database;
  static const DATABASE_NAME = 'app_database.db';
  static const DATA_TABLE = 'data';
  static const DB_MIGRATIONS_DIR = 'assets/db/migrations';

  Future<void> open(int version) async {
    this.database = openDatabase(
      join(await getDatabasesPath(), DATABASE_NAME),

      onCreate: (Database db, int version) async {
        developer.log('DB init at version: $version', name: 'db.onCreate');
        for (var i = 1; i <= version; i++) {
          await _runMigration(db, i);
        }
      },

      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        developer.log('DB migration $oldVersion -> $newVersion', name: 'db.onUpgrade');
        for (var i = oldVersion+1; i <= newVersion; i++) {
          await _runMigration(db, i);
        }
      },

      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: version,
    );
  }

  Future<void> insertData(Data data) async {
    Database db = await this.database;

    // Insert the Question into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, ignore.
    await db.insert(
      DATA_TABLE,
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> updateQuestion(Data data) async {
    Database db = await this.database;

    await db.update(
      DATA_TABLE,
      data.toMap(),
      // Ensure that the Question has a matching id.
      where: "id = ?",
      // Pass the Question's id as a whereArg to prevent SQL injection.
      whereArgs: [data.id],
    );

    developer.log('Updated data ${data.id} with text: ${data.text}', name: 'db.updateData');
  }

  Future<List<Data>> allData() async {
    final Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(DATA_TABLE);

    developer.log('Total # of data: ${maps.length}', name: 'db.queryData');

    return List.generate(maps.length, (i) {
      return Data(
        id: maps[i]['id'],
        text: maps[i]['text'],
      );
    });
  }

  Future<void> _runMigration(Database db, int version) async {
    String sqlScript = await rootBundle.loadString('$DB_MIGRATIONS_DIR/${version.toString().padLeft(5, '0')}.sql');
    developer.log('Running migration $version:\n$sqlScript', name: 'db.migration');

    var batch = db.batch();
    const LineSplitter().convert(sqlScript).forEach((cmd) {
      batch.execute(cmd);
    });
    await batch.commit();
  }
}
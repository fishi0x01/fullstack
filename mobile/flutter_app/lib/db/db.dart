import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_app/model/counter.dart';

class DBProvider {
  Future<Database> database;
  static const DATABASE_NAME = 'app_database.db';
  static const DATA_TABLE = 'counter';
  static const DB_MIGRATIONS_DIR = 'assets/db/migrations';

  static final DBProvider _dbProvider = new DBProvider._internal();

  static DBProvider instance() {
    return _dbProvider;
  }

  DBProvider._internal();

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

  Future<void> insertCounter(Counter counter) async {
    Database db = await this.database;

    // Insert into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, ignore.
    await db.insert(
      DATA_TABLE,
      counter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> updateData(Counter counter) async {
    Database db = await this.database;

    await db.update(
      DATA_TABLE,
      counter.toMap(),
      // Ensure matching id.
      where: "id = ?",
      // Pass id as a whereArg to prevent SQL injection.
      whereArgs: [counter.id],
    );

    developer.log('Updated object at id ${counter.id} with name: ${counter.name} and value: ${counter.val}', name: 'db.updateData');
  }

  Future<List<Counter>> allCounters() async {
    final Database db = await this.database;
    final List<Map<String, dynamic>> maps = await db.query(DATA_TABLE);

    developer.log('Total # of objects in table: ${maps.length}', name: 'db.queryData');

    return List.generate(maps.length, (i) {
      return Counter(
        id: maps[i]['id'],
        name: maps[i]['name'],
        val: maps[i]['val'],
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
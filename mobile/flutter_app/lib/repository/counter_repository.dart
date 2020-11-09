import 'package:flutter_app/db/db.dart';
import 'package:flutter_app/model/counter.dart';

class CounterRepository {
  static final CounterRepository _repo = new CounterRepository._internal();

  DBProvider database;

  static CounterRepository instance() {
    return _repo;
  }

  CounterRepository._internal() {
    database = DBProvider.instance();
  }

  Future<List<Counter>> allCounters() {
    return database.allCounters();
  }

  updateCounter(Counter counter) {
    database.updateData(counter);
  }
}
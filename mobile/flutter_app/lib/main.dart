import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_app/db/db.dart';
import 'package:flutter_app/simple_bloc_observer.dart';
import 'package:flutter_app/app.dart';

const DB_VERSION = 1;
final DBProvider db = DBProvider.instance();

void main() async {
  developer.log('Start App', name: 'start');
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: do not await -> load dynamically
  await db.open(DB_VERSION);
  for(var counter in await db.allCounters()) {
    developer.log('Loaded counter: ${counter.name}');
  }
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

import 'package:flutter/material.dart';
import 'package:nature_connect/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://jxlbgdvhnnxhblzlhnoj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4bGJnZHZobm54aGJsemxobm9qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjc2ODQ5NjUsImV4cCI6MjA0MzI2MDk2NX0.upQJU500_TQf8q43ectwR7PXmpCPAZn8OkUfoQI6IWA',
  );
  runApp( const MyApp());
}
        

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter(),
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor:const Color.fromARGB(255,76, 175, 80)),
        useMaterial3: true,
      ),
    );
  }
}

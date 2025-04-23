// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/task_provider.dart';
import 'Provider/theme_provider.dart';
import 'Screens/task_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskProvider = TaskProvider();
  await taskProvider.loadTasks();
  runApp(
    ChangeNotifierProvider(
      create: (_) => taskProvider,
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const TaskListScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/pages/home_page.dart';
import 'package:todolist/provider/menu_item_provider.dart';
import 'package:todolist/provider/theme_provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuItemProvider>(
            create: (contex) => MenuItemProvider()),
        ChangeNotifierProvider<ThemeProvider>(
            create: (contex) => ThemeProvider()..setThemeFromLocal()),
      ],
      builder: (context, _) {
        return const MyApp();
      }));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: themeProvider.themeMode,
      darkTheme: MyTheme.darkTheme,
      theme: MyTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

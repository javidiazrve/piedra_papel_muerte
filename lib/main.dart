import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piedra_papel_muerte/pages/Home.page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Piedra Papel o Muerte',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: "/home",
        getPages: [
          GetPage(name: "/home", page: () => const HomePage()),
        ]);
  }
}

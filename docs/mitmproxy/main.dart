import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
// import 'dart:io';

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..findProxy = (uri) {
//         return "PROXY 127.0.0.1:8080";
//       }
//       ..badCertificateCallback = (X509Certificate cert, String host, int port) {
//         return true;
//       };
//   }
// }

void main() {
  // HttpOverrides.global = MyHttpOverrides();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String value1 = "--";
  String value2 = "==";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            TextButton(onPressed: () => fetchPost(), child: Text("run1")),
            Text(value1),
            TextButton(onPressed: () => fetchDummy(), child: Text("run2")),
            Text(value2),
          ],
        ),
      ),
    );
  }

  Future<void> fetchPost() async {
    setState(() => value1 = "--");
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
    try {
      final response = await get(
        url,
        // headers: {'Cache-Control': 'no-cache, no-store, must-revalidate', 'Pragma': 'no-cache', 'Expires': '0'},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        await Future.delayed(Duration(seconds: 1));
        setState(() => value1 = data['title']);
      } else {
        await Future.delayed(Duration(seconds: 1));
        setState(() => value1 = "code error 111");
      }
    } catch (e) {
      await Future.delayed(Duration(seconds: 1));
      setState(() => value1 = "conn error 111");
    }
  }

  Future<void> fetchDummy() async {
    setState(() => value2 = "==");
    final url = Uri.parse('https://dummyjson.com/c/a7ba-2423-4ef5-8334');
    try {
      final response = await get(
        url,
        // headers: {'Cache-Control': 'no-cache, no-store, must-revalidate', 'Pragma': 'no-cache', 'Expires': '0'},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        await Future.delayed(Duration(seconds: 1));
        setState(() => value2 = data['code']);
      } else {
        await Future.delayed(Duration(seconds: 1));
        setState(() => value2 = "code error 222");
      }
    } catch (e) {
      await Future.delayed(Duration(seconds: 1));
      setState(() => value2 = "conn error 222");
    }
  }
}

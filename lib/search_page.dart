import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

// 검색 기능 구현 부분

class searchPage extends StatefulWidget {
  const searchPage({Key? key}) : super(key: key);

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {

  String result = '';
  List? data;

  @override
  void initState() {
    super.initState();
    data = new List.empty(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('$result'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          var url =
              // Default
              'http://seoji.nl.go.kr/landingPage/SearchApi.do?cert_key=01e338f80d4e0506df3e9e73e468e9088ef1067d3c0b32024e2ab3aed571c7dd&result_style=json&'
              // Change
              'page_no=1&page_size=10&start_publish_date=20170207&end_publish_date=20170207';
          var response = await http.get(Uri.parse(url));
          setState(() {
            result = response.body;
          });
        },
        child: Icon(Icons.search),
      ),
    );
  }
}

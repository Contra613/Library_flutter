import 'package:flutter/material.dart';
import 'package:library_flutter/Util/rating.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class searchPage extends StatefulWidget {
  const searchPage({Key? key}) : super(key: key);

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  String result = '';
  // ? : Null safety
  List? data;
  TextEditingController? _editingController;
  ScrollController? _scrollController;
  int page = 1;

  @override
  void initState() {
    super.initState();
    data = new List.empty(growable: true);
    _editingController = new TextEditingController();
    _scrollController = new ScrollController();

    _scrollController!.addListener(() {
      if(_scrollController!.offset >=
          _scrollController!.position.maxScrollExtent &&
          !_scrollController!.position.outOfRange) {
        print('bottom');
        page++;
        getJSONData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.black),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(hintText: '검색어를 입력하세요.'),
        ),
      ),
      body: Container(
        child: Center(
          child: data!.length == 0
              ? Text('데이터가 없습니다',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          )
              : ListView.builder(
            itemBuilder: (context, index) {
              return Card(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Image.network(
                        data![index]['thumbnail'],
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width - 150,
                            child: Text(
                              data![index]['title'].toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text('저자 : ${data![index]['authors'].toString()}'),
                          Text('출판사 : ${data![index]['publisher'].toString()}'),
                          Text('isbn : ${data![index]['isbn'].toString()}'),
                          Rating((p0) => null)
                        ],
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                ),
              );
            },
            itemCount: data!.length,
            controller: _scrollController,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () async {
          page = 1;
          data!.clear();
          getJSONData();
        },
        child: Icon(Icons.search),
      ),
    );
  }

  // async와 awit 키워드를 사용하여 비동기 처리 구현
  Future<String> getJSONData() async {
    var url =
        'https://dapi.kakao.com/v3/search/book?'
        'target=title&page=$page&query=${_editingController!.value.text}';
    var response = await http.get(Uri.parse(url),
        headers: {"Authorization" : "KakaoAK e583cf2ad66db3f8f92ce58a67516014"});
    setState(() {
      var dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON['documents'];
      data!.addAll(result);
    });
    return response.body;
  }
}
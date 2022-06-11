import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class recommendPage extends StatefulWidget {
  const recommendPage({Key? key}) : super(key: key);

  @override
  State<recommendPage> createState() => _recommendPageState();
}

class _recommendPageState extends State<recommendPage> {
  FirebaseAuth user = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // 컬렉션명
  final String colName = "books";

  // 필드명
  final String fnName = "name";
  final String fnTitle = "title";
  final String fnAuthor = "author";
  final String fnReview = "review";

  final String fnDatetime = "datetime";
  final String fnAuthor_uid = "author_uid";

  TextEditingController _newNameCon = TextEditingController();
  TextEditingController _newTitleCon = TextEditingController();
  TextEditingController _newAuthorCon = TextEditingController();
  TextEditingController _newReviewCon = TextEditingController();

  TextEditingController _undNameCon = TextEditingController();
  TextEditingController _undTitleCon = TextEditingController();
  TextEditingController _undAuthorCon = TextEditingController();
  TextEditingController _undReviewCon = TextEditingController();

  /// 이메일 확인용
  final String userEmail = "Email";
  TextEditingController _newemailComform = TextEditingController();
  TextEditingController _unemailComform = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            child: ListTile(
              title: Text("My Email"),
              subtitle: Text(user.currentUser!.email.toString()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(colName)
                  .orderBy(fnDatetime, descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) return Text("Error: ${snapshot.error}");
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text("Loading...");
                  default:
                    return ListView(
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot document) {
                        Timestamp ts = document[fnDatetime];
                        String dt = timestampToStrDateTime(ts);
                        return Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              ReadDeleteDocDialog(document);
                            },
                            onLongPress: () {
                              showUpdateOrDeleteDocDialog(document);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        document[fnTitle],
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "저자: " + document[fnAuthor],
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            "작성 시간: " + dt.toString(),
                                            style:
                                            TextStyle(color: Colors.grey[600]),
                                          ),
                                          Text(
                                            "작성자: " + document[fnName],
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                        ],
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                }
              },
            ),
          )
        ],
      ),
      // Create Document
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: showCreateDocDialog),
    );
  }

  /// Firestore CRUD Logic

  /// 문서 생성 (Create)
  void createDoc(String name, String title, String author, String review) {
    FirebaseFirestore.instance.collection(colName).add({
      fnName: name,
      fnTitle: title,
      fnAuthor: author,
      fnReview: review,
      fnDatetime: Timestamp.now(),
      userEmail: (user.currentUser != null) ? user.currentUser!.email.toString() : null,
      fnAuthor_uid: (user.currentUser != null) ? user.currentUser!.uid.toString() : null
    });
  }

  /// 문서 갱신 (Update)
  void updateDoc(String docID, String name, String title, String author, String review) {
    FirebaseFirestore.instance.collection(colName).doc(docID).update({
      fnName: name,
      fnTitle: title,
      fnAuthor: author,
      fnReview: review,
    });
  }

  /// 문서 삭제 (Delete)
  void deleteDoc(String docID) {
    FirebaseFirestore.instance.collection(colName).doc(docID).delete();
  }

  void showCreateDocDialog() {
    _newemailComform.text = (user.currentUser != null) ? user.currentUser!.email.toString() : "";
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("도서 등록"),
          content: Container(
            width: 500,
            height: 320,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(labelText: "사용자 이름"),
                    controller: _newNameCon,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "도서 제목"),
                    controller: _newTitleCon,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "저자"),
                    controller: _newAuthorCon,
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(labelText: "추천 이유"),
                    controller: _newReviewCon,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("취소"),
              onPressed: () {
                _newNameCon.clear();
                _newTitleCon.clear();
                _newAuthorCon.clear();
                _newReviewCon.clear();
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("생성"),
              onPressed: () {
                if (_newTitleCon.text.isNotEmpty &&
                    _newNameCon.text.isNotEmpty) {
                  createDoc(_newNameCon.text, _newTitleCon.text, _newAuthorCon.text, _newReviewCon.text);
                }
                _newNameCon.clear();
                _newTitleCon.clear();
                _newAuthorCon.clear();
                _newReviewCon.clear();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void showUpdateOrDeleteDocDialog(DocumentSnapshot doc) {
    _undNameCon.text = doc[fnName];
    _undTitleCon.text = doc[fnTitle];
    _undAuthorCon.text = doc[fnAuthor];
    _undReviewCon.text = doc[fnReview];
    _unemailComform.text = doc[userEmail];

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("수정 및 삭제"),
          content: Container(
            width: 500,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(labelText: "사용자 정보"),
                    controller: _unemailComform,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "사용자 이름"),
                    controller: _undNameCon,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "도서 제목"),
                    controller: _undTitleCon,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "저자"),
                    controller: _undAuthorCon,
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(labelText: "추천 이유"),
                    controller: _undReviewCon,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("삭제"),
              onPressed: () {
                deleteDoc(doc.id);
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("수정"),
              onPressed: () {
                if (_undNameCon.text.isNotEmpty &&
                    _undTitleCon.text.isNotEmpty) {
                  updateDoc(doc.id, _undNameCon.text, _undTitleCon.text, _undAuthorCon.text, _undReviewCon.text);
                }
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("취소"),
              onPressed: () {
                _undNameCon.clear();
                _undTitleCon.clear();
                _undReviewCon.clear();
                _undAuthorCon.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void ReadDeleteDocDialog(DocumentSnapshot doc) {
    _undNameCon.text = doc[fnName];
    _undTitleCon.text = doc[fnTitle];
    _undAuthorCon.text = doc[fnAuthor];
    _undReviewCon.text = doc[fnReview];

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("추천 이유 확인"),
          content: Container(
            width: 500,
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(labelText: "사용자 이름"),
                    controller: _undNameCon,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "도서 제목"),
                    controller: _undTitleCon,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "저자"),
                    controller: _undAuthorCon,
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(labelText: "추천 이유"),
                    controller: _undReviewCon,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("취소"),
              onPressed: () {
                _undNameCon.clear();
                _undTitleCon.clear();
                _undReviewCon.clear();
                _undAuthorCon.clear();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  String timestampToStrDateTime(Timestamp ts) {
    return DateTime.fromMicrosecondsSinceEpoch(ts.microsecondsSinceEpoch)
        .toString();
  }
}
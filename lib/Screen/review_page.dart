import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class reviewPage extends StatefulWidget {
  const reviewPage({Key? key}) : super(key: key);

  @override
  State<reviewPage> createState() => _reviewPageState();
}

class _reviewPageState extends State<reviewPage> {
  FirebaseAuth user = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // 컬렉션명
  final String colName = "books";

  // 필드명
  final String fnName = "name";
  final String fnTitle = "title";
  final String fnDatetime = "datetime";
  final String fnAuthor_uid = "author_uid";

  TextEditingController _newNameCon = TextEditingController();
  TextEditingController _newTitleCon = TextEditingController();
  TextEditingController _undNameCon = TextEditingController();
  TextEditingController _undTitleCon = TextEditingController();

  final String userEmail = "Email";
  TextEditingController _newemailComform = TextEditingController(); /// 이메일 확인용
  TextEditingController _unemailComform = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              // Read Document
                              onTap: () {
                                showDocument(document.id);
                              },
                              // Update or Delete Document
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
                                          document[fnName],
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          dt.toString(),
                                          style:
                                          TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            document[fnTitle],
                                            style: TextStyle(color: Colors.black54),
                                          ),
                                          ElevatedButton(
                                              child: Text('리뷰'),
                                              onPressed: () {},
                                          ),
                                        ],
                                      )
                                    )
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
  // 문서 생성 (Create)
  void createDoc(String name, String title) {
    FirebaseFirestore.instance.collection(colName).add({
      fnName: name,
      fnTitle: title,
      fnDatetime: Timestamp.now(),
      userEmail: (user.currentUser != null) ? user.currentUser!.email.toString() : null,
      fnAuthor_uid: (user.currentUser != null) ? user.currentUser!.uid.toString() : null
    });
  }

  // 문서 조회 (Read)
  void showDocument(String documentID) {
    FirebaseFirestore.instance
        .collection(colName)
        .doc(documentID)
        .get()
        .then((doc) {
      showReadDocSnackBar(doc);
    });
  }

  // 문서 갱신 (Update)
  void updateDoc(String docID, String name, String title) {
    FirebaseFirestore.instance.collection(colName).doc(docID).update({
      fnName: name,
      fnTitle: title,
    });
  }

  // 문서 삭제 (Delete)
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
            height: 200,
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
                )
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("취소"),
              onPressed: () {
                _newNameCon.clear();
                _newTitleCon.clear();
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("생성"),
              onPressed: () {
                if (_newTitleCon.text.isNotEmpty &&
                    _newNameCon.text.isNotEmpty) {
                  createDoc(_newNameCon.text, _newTitleCon.text);
                }
                _newNameCon.clear();
                _newTitleCon.clear();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void showReadDocSnackBar(DocumentSnapshot doc) {
    SnackBar(
      backgroundColor: Colors.deepOrangeAccent,
      duration: Duration(seconds: 5),
      content: Text(
          "$fnName: ${doc[fnName]}\n$fnTitle: ${doc[fnTitle]}"
              "\n$fnDatetime: ${timestampToStrDateTime(doc[fnDatetime])}"),
      action: SnackBarAction(
        label: "Done",
        textColor: Colors.white,
        onPressed: () {},
      ),
    );
  }

  void showUpdateOrDeleteDocDialog(DocumentSnapshot doc) {
    _undNameCon.text = doc[fnName];
    _undTitleCon.text = doc[fnTitle];
    _unemailComform.text = doc[userEmail];

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("수정 및 삭제"),
          content: Container(
            height: 200,
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
                )
              ],
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
                  updateDoc(doc.id, _undNameCon.text, _undTitleCon.text);
                }
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("취소"),
              onPressed: () {
                _undNameCon.clear();
                _undTitleCon.clear();
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



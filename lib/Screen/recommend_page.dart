import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class recommendPage extends StatefulWidget {

  @override
  State<recommendPage> createState() => _recommendPageState();
}

class _recommendPageState extends State<recommendPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // 컬렉션명
  final String colName = "books";

  // 필드명
  final String fnName = "name";
  final String fnTitle = "title";
  final String fnDatetime = "datetime";

  TextEditingController _newNameCon = TextEditingController();
  TextEditingController _newTitleCon = TextEditingController();
  TextEditingController _undNameCon = TextEditingController();
  TextEditingController _undTitleCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: <Widget>[
          Container(
            height: 500,
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
                                    child: Text(
                                      document[fnTitle],
                                      style: TextStyle(color: Colors.black54),
                                    ),
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
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create New Document"),
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
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update/Delete Document"),
          content: Container(
            height: 200,
            child: Column(
              children: <Widget>[
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
              child: Text("취소"),
              onPressed: () {
                _undNameCon.clear();
                _undTitleCon.clear();
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("갱신"),
              onPressed: () {
                if (_undNameCon.text.isNotEmpty &&
                    _undTitleCon.text.isNotEmpty) {
                  updateDoc(doc.id, _undNameCon.text, _undTitleCon.text);
                }
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text("삭제"),
              onPressed: () {
                deleteDoc(doc.id);
                Navigator.pop(context);
              },
            )
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
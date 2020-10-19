import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sooq1alzour/Auth/NewLogin.dart';

import 'EditAd.dart';

class Chating2 extends StatefulWidget {
  String documentId;
  String idChat;
  Chating2({this.documentId,this.idChat});
  @override
  _Chating2State createState() => _Chating2State(documentId: documentId,idChat: idChat);
}

List<DocumentSnapshot> docs;
QuerySnapshot qusViews;
DocumentSnapshot documentsUser;
DocumentSnapshot documentsAds ;
DocumentSnapshot documentMessages;
List<Widget> messages;
bool showMessages = false;
String currentUserName;
TextEditingController messageController = TextEditingController();
ScrollController scrollController = ScrollController();
int imageUrl4Show;
String Messgetext;
bool showBodyPrivate = false;
String idChat ;
class _Chating2State extends State<Chating2> {
  String documentId;
  String idChat;
  _Chating2State({this.documentId,this.idChat});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(idChat);
    getDocumentValue();
    Timer(Duration(microseconds: 300), () {
      setState(() {
        showMessages = true;

      });
    });
  }

  getDocumentValue() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    currentUserName = sharedPref.getString('name');
    DocumentReference documentRef =
    Firestore.instance.collection('Ads').document(documentId);
    documentsAds = await documentRef.get();

    DocumentReference documentRefUser =
    Firestore.instance.collection('users').document(currentUserId);
    documentsUser = await documentRefUser.get();
    setState(() {
      showBody = true;
      showBodyPrivate = true;
    });

  }

  final Firestore _firestore = Firestore.instance;
  Future<void> callBack() async {

    if (messageController.text.length > 0) {
      Messgetext = messageController.text;
      await _firestore.collection("private_messages").document('pChat').collection(idChat).add({
        'text': Messgetext,
        'from': currentUserId,
        'date': DateFormat('yyyy-MM-dd-HH:mm').format(DateTime.now()),
        'name': documentsUser['name'],
        'Ad_id': documentsAds.documentID,
        'message_id':currentUserId + documentId + documentsAds.data['uid'] ,
        'Ad_user' : documentsAds.data['uid'],
        'realTime': DateTime.now(),
      });
      setState(() {});
      messageController.clear();
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('دردش',style: TextStyle(
          fontSize: 20,
          fontFamily: 'AmiriQuran',
          height: 1,
          color: Colors.white,
        ),),
      ),
      body:showBodyPrivate ? ListView(
        controller: scrollController,
        children: [Padding(
          padding: EdgeInsets.only(top: 10, right: 10, left: 10),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection("private_messages").document('pChat').collection(idChat)
                .orderBy('realTime')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: Column(
                      children: <Widget>[
                        // CircularProgressIndicator(strokeWidth: 1,),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          '!...لا توجد تعليقات ',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'AmiriQuran',
                            height: 1,
                            color: Colors.grey[500],
                          ),
                        )
                      ],
                    ));
              }
              docs = snapshot.data.documents;
              List<Widget> messages = docs
                  .map((doc) => Message(
                  from: doc.data["from"],
                  text: doc.data["text"],
                  time: doc.data['date'],
                  me: documentsUser['name'] == doc.data["name"]))
                  .toList();

              return Column(
                children: <Widget>[
                  ...messages,
                ],
              );
            },
          ),
        ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 42,
            child: loginStatus
                ? Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10, left: 10),
                      child: TextField(
                        controller: messageController,
                        textAlign: TextAlign.right,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "!... اكتب تعليقك هنا",
                        ),
                        onSubmitted: (value) => callBack(),
                      ),
                    ),
                  ),
                  loginStatus
                      ? SendButton(
                    text: 'ارسل',
                    callback: (){
                      //saveChatId();
                      callBack();

                    },
                    idChat: idChat,
                  )
                      : Container(),
                ],
              ),
            )
                : Container(),
          )
        ],
      ):Center(
        child: SpinKitFadingCircle(
          color: Colors.red,
          size: 70,
          duration: Duration(seconds: 2),
        ),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    showBody=false;
    showBodyPrivate =false;
    //docs.clear();
  }

  saveChatId()async{
    final Firestore _firestore = Firestore.instance;

    await _firestore.collection("chats").document('pChat').collection(documentsAds.data['uid'],).add({
      'from': currentUserId,
      'date': DateFormat('yyyy-MM-dd-HH:mm').format(DateTime.now()),
      'Ad_id': documentsAds.documentID,
      'name' : documentsAds.data['uid'],
      'text': messageController.text,
      'idChat': idChat


    });
  }
}

class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;
  final String idChat;
  const SendButton({Key key, this.text, this.callback,this.idChat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      color: Colors.orange,
      onPressed:(){
        callback();
      },
      child: Text(text),
    );
  }
}

class Message extends StatelessWidget {
  final String from;
  final String text;
  final String time;

  final bool me;

  const Message({Key key, this.from, this.text, this.me, this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: me ? Alignment(1, 0) : Alignment(-1, 0),
      child: Padding(
        padding: EdgeInsets.only(top: 12),
        child: Container(
          child: Column(
            crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                from,
                style: TextStyle(fontSize: 12, color: Colors.blue[800]),
              ),
              SizedBox(
                height: 2,
              ),
              Material(
                color: me ? Colors.teal[100] : Colors.white70,
                borderRadius: BorderRadius.circular(5),
                elevation: 5,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: me
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          text,
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          time,
                          style:
                          TextStyle(fontSize: 11, color: Colors.deepOrange),
                        )
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}


import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

void _sendMessage({String text, File imgFile}) async {
  Map<String, dynamic> data = {};

  if (imgFile != null) {
    StorageUploadTask task = FirebaseStorage.instance
        .ref()
        .child(DateTime.now().millisecondsSinceEpoch.toString())
        .putFile(imgFile);

    StorageTaskSnapshot taskSnapshot = await task.onComplete;

    String url = await taskSnapshot.ref.getDownloadURL();

    data["imgUrl"] = url;
  }

  if (text != null) data["text"] = text;

  Firestore.instance.collection("messages").add(data);
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Olá"),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("messages").snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                        reverse: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              title: Text(documents[index].data["text"]));
                        });
                }
              },
            ),
          ),
          TextComposer(_sendMessage)
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:blog_app/screens/add-post/add_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  Homepage({Key? key}) : super(key: key);

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('posts').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context, CupertinoPageRoute(builder: (_) => AddPost()));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Card(
                child: Column(
                  children: [
                    Image.file(File(data["img"])),
                    Text(data["title"]),
                    Text(data["description"]),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

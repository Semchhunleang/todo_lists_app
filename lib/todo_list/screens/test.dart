import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Mylist extends StatelessWidget {
  const Mylist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Demo'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('todo').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: const Text(''),
                subtitle: Text(doc.id),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  static final FirestoreHelper _instance = new FirestoreHelper.internal();
  factory FirestoreHelper() => _instance;

  FirestoreHelper.internal();

  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addData(carData) async {
    if (isLoggedIn()) {
      Firestore.instance.collection('testcrud').add(carData).catchError((e) {
        print(e);
      });
      //Using Transactions
      // Firestore.instance.runTransaction((Transaction crudTransaction) async {
      //   CollectionReference reference =
      //       await Firestore.instance.collection('testcrud');

      //   reference.add(carData);
      // });
    } else {
      print('You need to be logged in');
    }
  }

  getData(collection) async {
    return Firestore.instance.collection(collection).snapshots();
  }

  updateData(collection, selectedDoc, newValues) {
    Firestore.instance
        .collection(collection)
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e) {
      print(e);
    });
  }

  deleteData(docId) {
    Firestore.instance
        .collection('testcrud')
        .document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }
}

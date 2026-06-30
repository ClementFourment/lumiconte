import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  Future<void> setData(String path, Map<String, dynamic> data) async {
    await firestore.doc(path).set(data);
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await firestore.doc(path).update(data);
  }

  Future<void> deleteData(String path) async {
    await firestore.doc(path).delete();
  }

  Future<Map<String, dynamic>?> getData(String path) async {
    final doc = await firestore.doc(path).get();
    return doc.data();
  }
}

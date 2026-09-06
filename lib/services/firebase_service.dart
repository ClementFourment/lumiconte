import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirebaseService {
  // ✅ Firestore est accédé à la demande et non à l'instanciation de la classe
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

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
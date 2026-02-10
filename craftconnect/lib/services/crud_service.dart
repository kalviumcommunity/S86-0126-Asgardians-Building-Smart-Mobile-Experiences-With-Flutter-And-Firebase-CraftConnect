import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';

class CrudService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _itemsCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('items');
  }

  // CREATE
  Future<void> createItem(String title, String description) async {
    await _itemsCollection.add({
      'title': title,
      'description': description,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // READ (Stream)
  Stream<List<ItemModel>> getItems() {
    return _itemsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList());
  }

  // UPDATE
  Future<void> updateItem(String id, String title, String description) async {
    await _itemsCollection.doc(id).update({
      'title': title,
      'description': description,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // DELETE
  Future<void> deleteItem(String id) async {
    await _itemsCollection.doc(id).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:genesis/models/Message.dart';

class MessageDatabaseService {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference smsCollection =
      FirebaseFirestore.instance.collection("Messages");

  // Future<List<String>> getFriend(String userId) async {
  //   List<String> friends = <String>[];
  //   QuerySnapshot querySnapshot = await smsCollection.get();
  //   for (var i = 0; i < querySnapshot.docs.length; i++) {
  //     String param = querySnapshot.docs[i].reference.toString();
  //     if (param.contains(userId)) {
  //       final spliter = param.split("-");
  //       if (spliter[0] == userId) {
  //         friends.add(spliter[1]);
  //       } else {
  //         friends.add(spliter[0]);
  //       }
  //     }
  //   }
  //   return Future.value(friends);
  // }

  // Stream<Iterable<UserFriend>> get friends {
  //   return smsCollection.snapshots().map(amis);
  // }
  // Iterable<UserFriend> amis(QuerySnapshot snapshot) {
  //   return snapshot.docs.map((doc) => _list_users(doc));
  // }

  // UserFriend _list_users(DocumentSnapshot snapshot) {
  //   if (snapshot.data() == null) throw Exception('Message non trouvé');
  //   return UserFriend(snapshot.get('idFrom'), snapshot.get('idTo'));
  // }

  Stream<Iterable<Message>> getMessage(String grouchatId, int limit) {
    return smsCollection
        .doc(grouchatId)
        .collection(grouchatId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(_messageListFromSnapshot);
  }


  Iterable<Message> _messageListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => _messageFromSnapshot(doc));
  }

  Message _messageFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.data() == null) throw Exception('Message non trouvé');
    return Message(
        idFrom: snapshot.get('idFrom'),
        idTo: snapshot.get('idTo'),
        timestamp: snapshot.get('timestamp'),
        content: snapshot.get('content'),
        type: snapshot.get('type'),
        view: snapshot.get('view'),
        name: snapshot.get('name'));
  }

  void onSendMessage(String grouchatId, Message message) {
    var documentReference = smsCollection
        .doc(grouchatId)
        .collection(grouchatId)
        .doc(DateTime.now().microsecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, message.tohashMap());
    });
  }

  void deleteSMS(String grouchatId, Message message) {
    smsCollection
        .doc(grouchatId)
        .collection(grouchatId)
        .where("content", isEqualTo: message.content)
        .where("timestamp", isEqualTo: message.timestamp)
        .snapshots()
        .map((event) => _messageSupp);
  }

  Iterable<void> _messageSupp(QuerySnapshot snapshot) {
    return snapshot.docs.map(
        (doc) => FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(doc.reference);
    }));
  }

  void statutSMS(String grouchatId) {
    smsCollection
        .doc(grouchatId)
        .collection(grouchatId)
        .where("idFrom", isNotEqualTo: user!.uid)
        .snapshots()
        .map((event) => _messageStatut);
  }

  Iterable<void> _messageStatut(QuerySnapshot snapshot) {
    return snapshot.docs.map(
        (doc) => FirebaseFirestore.instance.runTransaction((transaction) async {
              transaction.update(doc.reference, {'view': true});
            }));
  }

}

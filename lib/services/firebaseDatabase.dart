import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final String uid;
  FirebaseService(this.uid);
  FirebaseDatabase database = FirebaseDatabase.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref('users');
  final DateTime now = DateTime.now();

  //-------------------------------------------------------

// final DatabaseReference databaseUser =
//       FirebaseDatabase.instance.ref('users');

// Future<void> stateUser() async {
//     return await databaseUser.child(uid).set({
//       'presence': true,
//       'last_view': DateTime.now().millisecondsSinceEpoch,
//     });
//   }

  Future<void> updateUserPresence() async {
    Map<String, dynamic> presenceStatusTrue = {
      'presence': true,
      'last_view': DateTime.now().millisecondsSinceEpoch,
    };

    Map<String, dynamic> presenceStatusFalse = {
          'presence': false,
          'last_view': DateTime.now().millisecondsSinceEpoch,
    };

    databaseReference.child(uid).onDisconnect().update(presenceStatusFalse);
    return await databaseReference
        .child(uid)
        .update(presenceStatusTrue)
        .whenComplete(() => print('Mise à jour du statut.'))
        .catchError((e) => print(e));
    }
}
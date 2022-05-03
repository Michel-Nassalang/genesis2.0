import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:genesis/models/User.dart';
import 'package:genesis/screens/acceuil.dart';
import 'package:genesis/screens/auth.dart';
import 'package:genesis/services/database.dart';
import 'package:genesis/services/firebaseDatabase.dart';
import 'package:provider/provider.dart';

class Initial extends StatefulWidget {
  const Initial({Key? key}) : super(key: key);

  @override
  _InitialState createState() => _InitialState();
}

class _InitialState extends State<Initial> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth firebase = FirebaseAuth.instance;
    final user = firebase.currentUser;
    final actu = Provider.of<AppUser?>(context);
    if (user == null || actu == null) {
      return const Auth();
    } else {
      FirebaseService(actu.uid).updateUserPresence();
      return StreamProvider<UserData>.value(initialData: UserData(actu.uid,'','','','',''),
      value: DatabaseService(actu.uid).user,
      child: const Acceuil());
    }
    
  }
}

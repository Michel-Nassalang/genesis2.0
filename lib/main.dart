import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:genesis/models/User.dart';
import 'package:genesis/screens/init.dart';
import 'package:genesis/services/authentification.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackground(RemoteMessage message) async {
  print("Nouveau Message de ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      value: AuthentificationService().user,
      initialData: null,
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
       supportedLocales: const [
         Locale('en'),
         Locale('fr')
       ],
        debugShowCheckedModeBanner: false,
        title: 'Genesis',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Initial(),
      ),
    );
  }
}

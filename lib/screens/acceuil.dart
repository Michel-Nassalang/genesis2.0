import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:genesis/models/AppelModel.dart';
import 'package:genesis/models/SettingsModel.dart';
import 'package:genesis/models/User.dart';
import 'package:genesis/models/chatModel.dart';
import 'package:genesis/models/peopleModel.dart';
import 'package:genesis/screens/auth.dart';
import 'package:genesis/services/database.dart';
import 'package:genesis/services/firebaseDatabase.dart';
import 'package:genesis/services/notification.dart';
import 'package:provider/provider.dart';

class Acceuil extends StatefulWidget {
  const Acceuil({Key? key}) : super(key: key);

  @override
  _AcceuilState createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _selectedIndex = 0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseService  base = FirebaseService(user!.uid);
    base.updateUserPresence();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }


    Icon customIcon = const Icon(Icons.search_rounded, color: Colors.white);
  Widget customtitle = const Text('Genesis', style: TextStyle(color: Colors.white));
  final controlnom = TextEditingController();
  bool research = false;

  void searchange() {
    setState(() {
      if (customIcon.icon == Icons.search_rounded) {
        customIcon = const Icon(Icons.cancel);
        research = true;
        customtitle = ListTile(
          leading: const SizedBox(
              width: 20,
              child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.search_rounded, color: Colors.white))),
          title: TextField(
            controller: controlnom,
            onChanged: null,
            autofocus: true,
            onSubmitted: null,
            decoration: const InputDecoration(
              hintText: 'Chercher par nom ...',
              hintStyle: TextStyle(fontStyle: FontStyle.italic),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
          ),
        );
      } else {
        customIcon = const Icon(Icons.search_rounded, color: Colors.white);
        customtitle = const Text('Genesis', style: TextStyle(color: Colors.white));
        research = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    NotificationService.initialize();
    final user = Provider.of<AppUser?>(context);
    return (user == null) ? const Auth() : StreamProvider<Iterable<UserData>>.value(
      initialData:  [],
      value: DatabaseService(user.uid).userList,
    // return (user == null)
    //     ? const Auth()
    //     : StreamProvider<Iterable<UserFriend>>.value(
    //         initialData: [],
    //         value: MessageDatabaseService().friends,
      child: Scaffold(
        appBar: buildAppBar(),
        body: _selectedIndex==1 ? const PeopleModel() :  _selectedIndex==2 ? const AppelModel() : _selectedIndex==3 ? const SettingsModel() : const ChatModel(),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.blue,
                child: Icon(
                  _selectedIndex==1 ? Icons.person_add : _selectedIndex==2 ? Icons.call : _selectedIndex==3 ? Icons.person : Icons.message_rounded ,
                  color: Colors.white,
                ),
              ),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }
BottomNavigationBar buildBottomNavigationBar() {
    final user = Provider.of<UserData>(context);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      items:  [
        const BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: "Chats", tooltip:"Messages"),
        const BottomNavigationBarItem(icon: Icon(Icons.people), label: "People", tooltip:"People"),
        const BottomNavigationBarItem(icon: Icon(Icons.call), label: "Appels", tooltip:"Appels"),
        BottomNavigationBarItem(icon: (user.profil == 'profil.png') ? const CircleAvatar(radius: 14, backgroundImage: AssetImage("assets/genesis_flex.jpg")) : CircleAvatar(radius: 14 ,backgroundImage: NetworkImage(user.profil)),
          label: "Profil",
          tooltip: "Profil",
        ),
      ],
    );
  }

AppBar buildAppBar() {
  return AppBar(
      automaticallyImplyLeading: false,
      title: customtitle,
      actions: [
        IconButton(
          icon: customIcon,
          onPressed: searchange,
        ),
      ],
    );
}

}


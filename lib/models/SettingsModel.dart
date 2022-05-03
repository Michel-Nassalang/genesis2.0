import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genesis/models/profile_list_item.dart';
import 'package:genesis/screens/init.dart';
import 'package:genesis/screens/profil.dart';
import 'package:genesis/services/authentification.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'constants.dart';

class SettingsModel extends StatefulWidget {
  const SettingsModel({Key? key}) : super(key: key);

  @override
  _SettingsModelState createState() => _SettingsModelState();
}

class _SettingsModelState extends State<SettingsModel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  final AuthentificationService _auth = AuthentificationService();
  void logout() async {
    await _auth.sOut().then((value) => Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => const Initial())));
  }



  @override
  Widget build(BuildContext context) {
    final FirebaseAuth firebase = FirebaseAuth.instance;
    final userapp = firebase.currentUser;
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait
    );
    var header = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        profil(),
      ],
    );
    return Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: kSpacingUnit.w * 2),
              header,
              SizedBox(height: kSpacingUnit.w * 2),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    const ProfileListItem(
                      icon: LineAwesomeIcons.user_shield,
                      text: 'Confidentialité',
                    ),
                    const ProfileListItem(
                      icon: LineAwesomeIcons.history,
                      text: 'Historique',
                    ),
                    const ProfileListItem(
                      icon: LineAwesomeIcons.question_circle,
                      text: 'Aide & Support',
                    ),
                    const ProfileListItem(
                      icon: LineAwesomeIcons.cog,
                      text: 'Paramètres',
                    ),
                    const ProfileListItem(
                      icon: LineAwesomeIcons.user_plus,
                      text: 'Inviter un ami',
                    ),
                    GestureDetector(
                      onTap: logout,
                      child: const ProfileListItem(
                        icon: LineAwesomeIcons.alternate_sign_out,
                        text: 'Deconnexion',
                        hasNavigation: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
 }



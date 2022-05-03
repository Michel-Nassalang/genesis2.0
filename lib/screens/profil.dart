import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:genesis/models/User.dart';
import 'package:genesis/models/constants.dart';
import 'package:genesis/services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../common/loading.dart';

class profil extends StatefulWidget {
  const profil({ Key? key }) : super(key: key);

  @override
  _profilState createState() => _profilState();
}

class _profilState extends State<profil> {

  

  Future<void> getImage(String present) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadFile(present, pickedFile);
    }
  }

  Future uploadFile(String pre, PickedFile picked) async {
    String fileName =
        pre + '.jpeg';
    try {
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': picked.path});
      TaskSnapshot snapshot;
      if (kIsWeb) {
        snapshot =
            await reference.putData(await picked.readAsBytes(), metadata);
      } else {
        snapshot = await reference.putFile(File(picked.path), metadata);
      }
      String imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        onSendProfil(pre,imageUrl);
      });
    } on Exception {
      Fluttertoast.showToast(
          msg: 'Une erreur est parvenue lors de l\'importation',
          textColor: Colors.white,
          backgroundColor: Colors.red);
    }
  }
  Future<void> onSendProfil(String present, String contenu) async {
    if (contenu.trim() != '') {
      final FirebaseAuth firebase = FirebaseAuth.instance;
      final userapp = firebase.currentUser;
      DatabaseService database = DatabaseService(userapp!.uid);
      database.profilUser(contenu);
    } else {
      Fluttertoast.showToast(
        msg: 'Mise à jour de profil échoué.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth firebase = FirebaseAuth.instance;
    final userapp = firebase.currentUser;
    final user = Provider.of<UserData>(context);
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: kSpacingUnit.w * 10,
            margin: EdgeInsets.only(top: kSpacingUnit.w * 3),
            child: Stack(
              children: <Widget>[
                (user.profil == 'profil.png') ?  CircleAvatar(
                        radius: kSpacingUnit.w * 5,
                        backgroundImage: const AssetImage('assets/profil.png')
                      ) : 
                CircleAvatar(
                        radius: kSpacingUnit.w * 5,
                        backgroundImage: CachedNetworkImageProvider(user.profil),
                      ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: kSpacingUnit.w * 3.0,
                    width: kSpacingUnit.w * 3.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      heightFactor: kSpacingUnit.w * 1.5,
                      widthFactor: kSpacingUnit.w * 1.5,
                      child: IconButton(
                          onPressed: () => getImage(userapp!.uid),
                          icon: Icon(
                            LineAwesomeIcons.pen,
                            color: kDarkPrimaryColor,
                            size: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: kSpacingUnit.w * 2),
          Text(
            user.name,
            style: kTitleTextStyle,
          ),
          SizedBox(height: kSpacingUnit.w * 0.5),
          Text(
            userapp!.email.toString(),
            style: kCaptionTextStyle,
          ),
          SizedBox(height: kSpacingUnit.w * 1),
          Container(
            height: kSpacingUnit.w * 3.5,
            width: kSpacingUnit.w * 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
              color: Theme.of(context).accentColor,
            ),
            child: Center(
              child: Text(
                'Genesis',
                style: kButtonTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
    ;
  }
}
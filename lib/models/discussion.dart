import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:genesis/common/loading.dart';
import 'package:genesis/models/Message.dart';
import 'package:genesis/models/RecordButton.dart';
import 'package:genesis/models/TextChat.dart';
import 'package:genesis/models/User.dart';
import 'package:genesis/models/chat-params.dart';
import 'package:genesis/screens/expandable.dart';
import 'package:genesis/services/messageDatabase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'flick_video/flick_video.dart';

class Discussion extends StatefulWidget {
  final UserData actuUser;
  const Discussion({Key? key, required this.actuUser}) : super(key: key);

  @override
  _DiscussionState createState() => _DiscussionState();
}

class _DiscussionState extends State<Discussion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final messageControl = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final focusNode = FocusNode();
  bool emojiShowing = false;
  bool keyboardShowing = false;
  bool isOpened = false;

  final MessageDatabaseService messageService = MessageDatabaseService();
  late FlickMultiManager flickMultiManager;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    flickMultiManager = FlickMultiManager();
    listScrollController.addListener(_scrollListener);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          emojiShowing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    messageControl.dispose();
    listScrollController.dispose();
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _nbElement += pagination;
      });
    }
  }

  _onEmojiSelected(Emoji emoji) {
    messageControl
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageControl.text.length));
  }

  _onBackspacePressed() {
    messageControl
      ..text = messageControl.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageControl.text.length));
  }

  Future<void> onSendMessage(String present, String content, int type, String name) async {
    if (content.trim() != '') {
      messageService.onSendMessage(
          ChatParams(present, widget.actuUser).getChatGroupId(),
          Message(
              idFrom: present,
              idTo: widget.actuUser.uid,
              timestamp: DateTime.now().microsecondsSinceEpoch.toString(),
              content: content,
              type: type,
              view: false,
              name: name));
      await listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      messageControl.clear();
    } else {
      Fluttertoast.showToast(
        msg: 'Pas de message à envoyer',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> getImage(String present) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // setState(() {
      //   isloading = true;
      // });
      uploadImage(present, pickedFile);
    }
  }
  Future<void> pickImage(String present) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      uploadImage(present, pickedFile);
    }
  }

  Future uploadImage(String pre, XFile picked) async {
    String fileName =
        DateTime.now().microsecondsSinceEpoch.toString() + '.jpeg';
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
        onSendMessage(pre, imageUrl, 2, '');
      });
    } on Exception {
      Fluttertoast.showToast(
          msg: 'Une erreur est parvenue lors de l\'importation',
          textColor: Colors.white,
          backgroundColor: Colors.red);
    }
  }

Future<void> getSound(String present) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'wma', 'flac'],
    );
    if (result != null) {
      uploadSound(present, result);
    }
  }

  Future uploadSound(String pre, FilePickerResult picked) async {
    Uint8List? fileBytes = picked.files.first.bytes;
    String fileName = DateTime.now().microsecondsSinceEpoch.toString() + '.mp3';
    try {
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(
          contentType: 'audio/mp3',
          customMetadata: {'picked-file-path': picked.files.first.path!});
      TaskSnapshot snapshot;
      if (kIsWeb) {
        snapshot =
            await reference.putData(fileBytes!, metadata);
      } else {
        snapshot = await reference.putFile(File(picked.files.first.path!), metadata);
      }
      String imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        onSendMessage(pre, imageUrl, 3, '');
      });
    } on Exception {
      Fluttertoast.showToast(
          msg: 'Une erreur est parvenue lors de l\'importation',
          textColor: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  Future<void> getVideo(String present) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile =
        await imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadVideo(present, pickedFile);
    }
  }
  Future uploadVideo(String pre, XFile picked) async {
    String fileName =
        DateTime.now().microsecondsSinceEpoch.toString() + '.mp4';
    try {
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {'picked-file-path': picked.path});
      TaskSnapshot snapshot;
      if (kIsWeb) {
        snapshot =
            await reference.putData(await picked.readAsBytes(), metadata);
      } else {
        snapshot = await reference.putFile(File(picked.path), metadata);
      }
      String videoUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        onSendMessage(pre, videoUrl, 4, '');
      });
    } on Exception {
      Fluttertoast.showToast(
          msg: 'Une erreur est parvenue lors de l\'importation',
          textColor: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  // Future<void> getFile(String present) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if (result != null) {
  //     uploadSound(present, result);
  //   }
  // }

  Future uploadFile(String pre) async {
    FilePickerResult? picked = await FilePicker.platform.pickFiles();
    if(picked != null) {
      Uint8List? fileBytes = picked.files.first.bytes;
      String? ext = picked.files.first.extension;
      String? nom = picked.files.first.name;
      String fileName =
          DateTime.now().microsecondsSinceEpoch.toString() + '.$ext';
      try {
        Reference reference = FirebaseStorage.instance.ref().child(fileName);
        final metadata = SettableMetadata(
            contentType: 'document/all',
            customMetadata: {'picked-file-path': picked.files.first.path!});
        TaskSnapshot snapshot;
        if (kIsWeb) {
          snapshot = await reference.putData(fileBytes!, metadata);
        } else {
          snapshot =
              await reference.putFile(File(picked.files.first.path!), metadata);
        }
        String fileUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          onSendMessage(pre, fileUrl, 5, nom);
        });
      } on Exception {
        Fluttertoast.showToast(
            msg: 'Une erreur est parvenue lors de l\'importation',
            textColor: Colors.white,
            backgroundColor: Colors.red);
      }
    }
  }

  void _recordingFinishedCallback(String path) async {
    final uri = Uri.parse(path);
    File file = File(uri.path);
    file.length().then(
      (fileSize) async {
        String fileName = DateTime.now().microsecondsSinceEpoch.toString() + '.mp3';
    try {
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(
          contentType: 'audio/mp3',
          customMetadata: {'picked-file-path': uri.path});
      TaskSnapshot snapshot;
        snapshot = await reference.putFile(File(uri.path), metadata);
      String soundUrl = await snapshot.ref.getDownloadURL();
          final FirebaseAuth firebase = FirebaseAuth.instance;
      setState(() {
        onSendMessage(firebase.currentUser!.uid, soundUrl, 3, '');
      });
    } on Exception {
      Fluttertoast.showToast(
          msg: 'Une erreur est parvenue lors de l\'importation',
          textColor: Colors.white,
          backgroundColor: Colors.red);
    }
      },
    );
  }

  void deploiement(bool val) {
    setState(() {
      val = !val;
    });
  }


  bool isDeploie = false;
  int _nbElement = 50;
  static const int pagination = 50;

  // -------------------------------------------------------------
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final utilisateur = Provider.of<AppUser?>(context);
    ()=> messageService.statutSMS(ChatParams(utilisateur!.uid, widget.actuUser)
                          .getChatGroupId());
    return VisibilityDetector(
      key: ObjectKey(flickMultiManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && mounted) {
          flickMultiManager.pause();
        }
      },
      child: KeyboardDismissOnTap(
        child: Scaffold(
          appBar: buildAppBar(),
          body: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
            Material(
                color: Colors.white,
                child: StreamBuilder<Iterable<Message>>(
                  stream: messageService.getMessage(
                      ChatParams(utilisateur!.uid, widget.actuUser)
                          .getChatGroupId(),
                      _nbElement),
                  builder: (BuildContext context,
                      AsyncSnapshot<Iterable<Message>> snapshot) {
                    if (snapshot.hasData) {
                      Iterable<Message> listMessage =
                          snapshot.data ?? Iterable.castFrom([]);
                      return ListView.builder(
                        itemCount: listMessage.length,
                        itemBuilder: (context, int index) {
                          return TextMessage(
                              message: listMessage.elementAt(index),
                              precedent: (index != 0)
                                  ? listMessage.elementAt(index - 1)
                                  : listMessage.elementAt(index),
                              flickMultiManager : flickMultiManager);
                        },
                        reverse: true,
                        controller: listScrollController,
                        padding: const EdgeInsets.only(bottom: 65),
                      );
                    } else {
                      return const Center(child: Loading());
                    }
                  },
                )),
    
            // Barre d'insertion de message
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              isOpened
                  ? Row(children: [
                      const Expanded(child: Padding(padding: EdgeInsets.zero)),
                      ExpandableFab(distance: 170, children: [
                        ActionButton(
                            icon: const Icon(Icons.file_present, color: Colors.white),
                            onPressed: () => uploadFile(utilisateur.uid)),
                        const Padding(padding: EdgeInsets.only(bottom: 5)),
                        ActionButton(
                            icon: const Icon(Icons.audiotrack, color: Colors.white),
                            onPressed: () => getSound(utilisateur.uid)),
                        const Padding(padding: EdgeInsets.only(bottom: 5)),
                        ActionButton(
                            icon: const Icon(Icons.video_collection, color: Colors.white),
                            onPressed: () => getVideo(utilisateur.uid)),
                        const Padding(padding: EdgeInsets.only(bottom: 5)),
                        ActionButton(
                            icon: const Icon(Icons.camera, color: Colors.white),
                            onPressed: () => pickImage(utilisateur.uid)),
                        const Padding(padding: EdgeInsets.only(bottom: 5)),
                        ActionButton(
                            icon: const Icon(Icons.image, color: Colors.white),
                            onPressed: () => getImage(utilisateur.uid)),
                      ]),
                    ])
                  : const Padding(padding: EdgeInsets.zero),
              // barre d'insertion de texte
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20 / 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 32,
                      color: Colors.blue.withOpacity(0.08),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20 * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                icon: Icon(
                                  emojiShowing
                                      ? Icons.keyboard_rounded
                                      : Icons.emoji_emotions_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (emojiShowing == false) {
                                      focusNode.unfocus();
                                      focusNode.canRequestFocus = false;
                                      emojiShowing = !emojiShowing;
                                      isOpened = false;
                                    } else {
                                      focusNode.requestFocus();
                                      emojiShowing = !emojiShowing;
                                      isOpened = false;
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: TextFormField(
                                onTap: () => {
                                  setState(() {
                                    isOpened = false;
                                    emojiShowing = false;
                                  })
                                },
                                focusNode: focusNode,
                                minLines: 1,
                                maxLines: 5,
                                controller: messageControl,
                                decoration: const InputDecoration(
                                  hintText: "Message",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                                icon: Icon(
                                  isOpened ? Icons.close : Icons.attach_file,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .color!
                                      .withOpacity(0.64),
                                ),
                                onPressed: () {
                                  setState(() {
                                    focusNode.unfocus();
                                    isOpened = !isOpened;
                                    emojiShowing = false;
                                  });
                                },
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0),
                                constraints: const BoxConstraints(
                                  minWidth: 26,
                                  minHeight: kMinInteractiveDimension,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    RecordButton(recordingFinishedCallback:  _recordingFinishedCallback),
                    const SizedBox(width: 10),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.blue.withOpacity(0.05),
                      ),
                      padding: const EdgeInsets.only(left: 3),
                      child: IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            onSendMessage(
                                utilisateur.uid, messageControl.value.text, 1, '');
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          constraints: const BoxConstraints(
                            minWidth: 26,
                            minHeight: kMinInteractiveDimension,
                          )
                        ),
                    )
                  ]),
                ),
              ),
              Offstage(
                offstage: !emojiShowing,
                child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                      onEmojiSelected: (category, Emoji emoji) {
                        _onEmojiSelected(emoji);
                      },
                      onBackspacePressed: _onBackspacePressed,
                      config: Config(
                          columns: 7,
                          emojiSizeMax: 28 * (Platform.isIOS ? 1.30 : 1.0),
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          bgColor: const Color(0xFFF2F2F2),
                          indicatorColor: Colors.blue,
                          iconColor: Colors.grey,
                          iconColorSelected: Colors.blue,
                          progressIndicatorColor: Colors.blue,
                          backspaceColor: Colors.blue,
                          showRecentsTab: true,
                          recentsLimit: 28,
                          noRecentsText: 'Pas de récents émojis',
                          noRecentsStyle: const TextStyle(
                              fontSize: 20, color: Colors.black26),
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL)),
                ),
              ),
            ])
          ]),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          BackButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isOpened = false;
              });
            },
          ),
          (widget.actuUser.profil == 'profil.png') ?  const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage('assets/profil.png')
                      ) : 
                CircleAvatar(
                        radius: 24,
                        backgroundImage: CachedNetworkImageProvider(widget.actuUser.profil),
                      ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.actuUser.name,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                widget.actuUser.statut == 'active'
                    ? 'En ligne'
                    : 'Depuis  ${widget.actuUser.statut}',
                style: const TextStyle(fontSize: 12),
              )
            ],
          )
        ],
      ),
      actions: [
        SizedBox(
          width: 40,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.local_phone,
              size: 20,
            ),
            onPressed: () {},
          ),
        ),
        SizedBox(
          width: 30,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.videocam,
              size: 24,
            ),
            onPressed: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => VideoCall(userfriend: widget.actuUser, user: Provider.of<AppUser?>(context),)));
            },
          ),
        ),
        SizedBox(
          width: 40,
          child: PopupMenuButton<String>(
            onSelected: null,
            itemBuilder: (BuildContext context) {
              return {'Contact', 'Medias, liens, documents'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }

  Widget showEmojiPicker() {
    return EmojiPicker(onEmojiSelected: (Emoji, category) {
      print(Emoji);
    });
  }
}


// --------------------------------------
// --------------------------------------


@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4.0,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.secondary,
      ),
    );
  }
}

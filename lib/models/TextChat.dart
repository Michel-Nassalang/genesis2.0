import 'dart:io';
import 'dart:io' as io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:genesis/common/loading.dart';
import 'package:genesis/models/AudioPlayer.dart';
import 'package:genesis/models/Message.dart';
import 'package:genesis/models/User.dart';
import 'package:genesis/models/flick_video/animation_player.dart';
import 'package:genesis/models/flick_video/flick_multi_player.dart';
import 'package:genesis/screens/imageAffichage.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'flick_video/flick_video.dart';
import 'package:dio/dio.dart';

class TextMessage extends StatefulWidget {
  const TextMessage(
      {Key? key,
      required this.message,
      required this.precedent,
      required this.flickMultiManager})
      : super(key: key);

  final Message message;
  final Message precedent;
  final FlickMultiManager flickMultiManager;

  @override
  State<StatefulWidget> createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  // Boite de dialogue
  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.end,
          actionsPadding: EdgeInsets.zero,
          title:
              const Text('Suppression', style: TextStyle(color: Colors.blue)),
          content: SingleChildScrollView(
            child: ListBody(
              mainAxis: Axis.vertical,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {});
                    Navigator.pop(context, true);
                    Fluttertoast.showToast(
                      msg: 'Message supprimé de mon coté',
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white,
                    );
                  },
                  child: const ListTile(
                    leading: Icon(
                      Icons.person_remove_rounded,
                      color: Colors.blue,
                    ),
                    title: Text(
                      'Supprimer pour moi',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {});
                    Navigator.pop(context, true);
                    Fluttertoast.showToast(
                      msg: 'Message supprimé de la base',
                      backgroundColor: Colors.grey[600],
                      textColor: Colors.white,
                    );
                  },
                  child: const ListTile(
                    leading: Icon(Icons.group_outlined, color: Colors.blue),
                    title: Text(
                      'Supprimer pour tous',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//-----------------------

  Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }

//-----------------------

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  // Future<File> get _localFile async {
  //   final path = await _localPath;
  //   return File('$path/${widget.message.content}');
  // }
  // File fichier(String val){
  //   final path = _localPath;
  //   return File('$path'+val);
  // }

  bool load = false;
  bool loadEnd = false;
  double taux = 0;
  Future<void> loadimg() async {
    setState(() {
      load = true;
    });
    String dirdoc = await _localPath;
    await Dio().download(widget.message.content,
        '$dirdoc/images/${widget.message.timestamp}.jpeg',
        onReceiveProgress: (count, total) {
          if (total != -1){
            setState(() {
              taux = count/total;
            });
          }
        },);
    setState(() {
      loadEnd = true;
    });
  }

  Future<void> loaddoc() async {
    String dirdoc = await _localPath;
    await Dio().download(
      widget.message.content,
      '$dirdoc/documents/${widget.message.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final userpresent = Provider.of<AppUser?>(context);
    final temps1 = int.parse(DateFormat('dd').format(
        DateTime.fromMicrosecondsSinceEpoch(
            int.parse(widget.message.timestamp))));
    final temps2 = int.parse(DateFormat('dd').format(
        DateTime.fromMicrosecondsSinceEpoch(
            int.parse(widget.precedent.timestamp))));
    final annee1 = int.parse(DateFormat('yyyy').format(
        DateTime.fromMicrosecondsSinceEpoch(
            int.parse(widget.message.timestamp))));
    final annee2 = int.parse(DateFormat('yyyy').format(
        DateTime.fromMicrosecondsSinceEpoch(
            int.parse(widget.precedent.timestamp))));
    return Column(children: [
      Row(
        children: [
          widget.message.idFrom == userpresent!.uid
              ? const Expanded(child: Padding(padding: EdgeInsets.zero))
              : const Padding(padding: EdgeInsets.zero),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(
                horizontal: 20 * 0.75,
                vertical: 20 / 2,
              ),
              margin: widget.message.idFrom == userpresent.uid
                  ? const EdgeInsets.fromLTRB(5, 3, 5, 3)
                  : const EdgeInsets.fromLTRB(5, 3, 5, 3),
              decoration: BoxDecoration(
                color: widget.message.idFrom == userpresent.uid
                    ? Colors.grey[300]
                    : Colors.blue[100],
                borderRadius: widget.message.idFrom == userpresent.uid
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.elliptical(-35, -65))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.elliptical(-35, -65),
                        bottomRight: Radius.circular(10)),
              ),
              child: (widget.message.type == 1)
                  ?
                  // Message texte
                  GestureDetector(
                      onLongPress: () => _showMyDialog(context),
                      child: Text(
                        widget.message.content,
                        overflow: TextOverflow.clip,
                        softWrap: true,
                        style: GoogleFonts.lato(
                          color: (widget.message.idFrom == userpresent.uid)
                              ? Colors.black
                              : Colors.black,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : (widget.message.type == 2)
                      ?
                      // Message image
                      GestureDetector(
                          onLongPress: () => _showMyDialog(context),
                          onTap: () {
                            setState(() {
                              // ...
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ImageAffiche(img: widget.message),
                                ));
                          },
                          child: io.File(
                                      '$_localPath/images/${widget.message.timestamp}.jpeg')
                                  .existsSync()
                              ? Image.file(
                                  File(
                                      '$_localPath/images/${widget.message.timestamp}.jpeg'),
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover)
                              : SizedBox(
                                  width: 200.0,
                                  height: 200.0,
                                  child: Stack(children: [
                                    Positioned.fill(
                                      child: CachedNetworkImage(
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                        imageUrl: widget.message.content,
                                        progressIndicatorBuilder:
                                            (context, url, loadingProgress) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0),
                                                )),
                                            width: 200.0,
                                            height: 200.0,
                                            child: const Center(
                                              child: Loading(),
                                            ),
                                          );
                                        },
                                        errorWidget:
                                            (context, object, stackTrace) {
                                          return Container(
                                            width: 200.0,
                                            height: 200.0,
                                            child: const Center(
                                              child: SpinKitFadingCube(
                                                color: Colors.blue,
                                                size: 40,
                                              ),
                                            ),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                        right: 25,
                                        bottom: 25,
                                        child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: (load == false)
                                              ? IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .arrow_circle_down_outlined,
                                                      color: Colors.blue,
                                                      size: 40),
                                                  onPressed: loadimg)
                                              : (loadEnd==false) ?
                                              CircularProgressIndicator(value: taux)
                                              : const Icon(Icons.check_circle_outline_outlined,
                                                      color: Colors.blue,
                                                      size: 40),
                                        )),
                                  ]),
                                ),
                        )
                      : (widget.message.type == 3)
                          ?
                          // Message vocal
                          GestureDetector(
                              onLongPress: () => _showMyDialog(context),
                              child: AudioPlayerMessage(
                                  source: AudioSource.uri(
                                      Uri.parse(widget.message.content)),
                                  id: widget.message.content),
                            )
                            // Message Video
                          : (widget.message.type == 4)
                              ? GestureDetector(
                                  onLongPress: () => _showMyDialog(context),
                                  onTap: () {
                                    setState(() {
                                      // ...
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const AnimationPlayer()));
                                  },
                                  child: SizedBox(
                                    height: 200,
                                    width: 250,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: FlickMultiPlayer(
                                        url: widget.message.content,
                                        flickMultiManager:
                                            widget.flickMultiManager,
                                        image: 'assets/genesis_flex.jpg',
                                      ),
                                    ),
                                  ),
                                )
                              :
                              // 
                              // message Document
                              GestureDetector(
                                  onLongPress: () => _showMyDialog(context),
                                  onTap: () async {
                                    loaddoc;
                                    String dir = await _localPath;
                                    openFile('$dir/documents/${widget.message.name}');
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 30,
                                        child: Icon(Icons.file_present_rounded,
                                            color: Colors.blue, size: 25),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: Text(widget.message.name),
                                      ),
                                    ],
                                  ),
                                ),
              clipBehavior: Clip.hardEdge,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(
                DateFormat('HH:mm').format(DateTime.fromMicrosecondsSinceEpoch(
                    int.parse(widget.message.timestamp))),
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10.0,
                    fontStyle: FontStyle.italic),
              ),
            )
          ]),
          widget.message.idFrom == userpresent.uid
              ? const Padding(padding: EdgeInsets.zero)
              : const Expanded(child: Padding(padding: EdgeInsets.zero)),
        ],
      ),
      annee1 != annee2
          ? Center(
              child: Container(
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 7.5, bottom: 7.5),
                decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(10)),
                child: Text((annee2).toString(),
                    style: GoogleFonts.lato(
                        color: Colors.white, fontStyle: FontStyle.italic)),
              ),
            )
          : const Padding(padding: EdgeInsets.zero),
      temps1 != temps2
          ? Center(
              child: Container(
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 7.5, bottom: 7.5),
                decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                    (temps2).toString() +
                        " " +
                        DateFormat('MMMM').format(
                            DateTime.fromMicrosecondsSinceEpoch(
                                int.parse(widget.precedent.timestamp))),
                    style: GoogleFonts.lato(
                        color: Colors.white, fontStyle: FontStyle.italic)),
              ),
            )
          : const Padding(padding: EdgeInsets.zero),
    ]);
  }
}

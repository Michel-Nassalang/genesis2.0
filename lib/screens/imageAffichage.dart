// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:genesis/common/loading.dart';
import 'package:genesis/models/Message.dart';
import 'package:genesis/models/User.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ImageAffiche extends StatefulWidget {
  const ImageAffiche({Key? key, required this.img}) : super(key: key);
  final Message img;

  @override
  _ImageAfficheState createState() => _ImageAfficheState();
}

class _ImageAfficheState extends State<ImageAffiche>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TransformationController controlZoom;
  late TapDownDetails tapDownDetails;

  @override
  void initState() {
    super.initState();
    controlZoom = TransformationController();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    controlZoom.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userpresent = Provider.of<AppUser?>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 65, 65, 65),
      appBar: buildAppBar(),
      body: GestureDetector(
        onDoubleTapDown: (details) => tapDownDetails = details,
        onDoubleTap: () {
          final position = tapDownDetails.localPosition;
          const double scale = 3;
          final x = -position.dx * (scale - 1);
          final y = -position.dy * (scale - 1);
          final zoom = Matrix4.identity()
            ..translate(x, y)
            ..scale(scale);
          final value =
              controlZoom.value.isIdentity() ? zoom : Matrix4.identity();
          controlZoom.value = value;
        },
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          panEnabled: true,
          constrained: true,
          transformationController: controlZoom,
          child: Container(
            alignment: Alignment.center,
            child: Image.network(widget.img.content,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain, loadingBuilder: (BuildContext context,
                    Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                    color: (widget.img.idFrom == userpresent!.uid)
                        ? Colors.black
                        : Colors.black,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8.0),
                    )),
                child: const Center(
                  child: Loading(),
                ),
              );
            }, errorBuilder: (context, object, stackTrace) {
              return const Material(
                child: Center(
                  child: SpinKitFadingCube(
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                clipBehavior: Clip.hardEdge,
              );
            }),
          ),
        ),
      ),
    );
  }

  buildAppBar() {
    final userpresent = Provider.of<AppUser?>(context);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const BackButton(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.img.idFrom == userpresent!.uid ? 'Vous' : 'A vous',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                  DateFormat('dd MMM kk:mm').format(
                      DateTime.fromMicrosecondsSinceEpoch(
                          int.parse(widget.img.timestamp))),
                  style: const TextStyle(
                    fontSize: 12,
                  ))
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
        ],
      ),
      actions: [
        IconButton(
            onPressed: () {}, icon: const Icon(Icons.star_border_outlined)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        PopupMenuButton<String>(
          onSelected: null,
          itemBuilder: (BuildContext context) {
            return {'Details', 'Caractéristiques'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}

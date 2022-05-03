import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ConnectionApp extends StatefulWidget {
  const ConnectionApp({ Key? key }) : super(key: key);

  @override
  _ConnectionAppState createState() => _ConnectionAppState();
}

class _ConnectionAppState extends State<ConnectionApp>
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/genesis_flex.jpg'),
            fit: BoxFit.fill,
          )),
        ),
        Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              children:  [
                SizedBox(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: const Text('Veuillez vérifier l\'état de votre connection',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SpinKitFadingCube(
                color: Colors.blue,
                size: 40,
              ),
              ] ,
            ),
          ),
        ),
      ],
    );
  }
}
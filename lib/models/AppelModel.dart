import 'package:flutter/material.dart';

class AppelModel extends StatefulWidget {
  const AppelModel({ Key? key }) : super(key: key);

  @override
  _AppelModelState createState() => _AppelModelState();
}

class _AppelModelState extends State<AppelModel>
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
    return Center(
      child: Container(
        child: Text('Appels'),
      ),
    );
  }
}
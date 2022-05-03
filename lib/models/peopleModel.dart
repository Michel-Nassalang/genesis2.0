import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genesis/models/discussion.dart';
import 'package:genesis/services/messageDatabase.dart';
import 'package:provider/provider.dart';

import 'User.dart';

class PeopleModel extends StatefulWidget {
  const PeopleModel({Key? key}) : super(key: key);

  @override
  _PeopleModelState createState() => _PeopleModelState();
}

class _PeopleModelState extends State<PeopleModel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final MessageDatabaseService messageService = MessageDatabaseService();
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
    final utilisateur = Provider.of<AppUser?>(context);
    final userList = Provider.of<Iterable<UserData>>(context);
    return ListView.builder(
      itemCount: userList.length,
      itemBuilder: (BuildContext context, int index) {
        if (userList.elementAt(index).uid != utilisateur!.uid) {
                return peopleList(user: userList.elementAt(index));
        } else {
          return const Padding(padding: EdgeInsets.zero);
        }
      },
    );
  }
}

class peopleList extends StatelessWidget {
  final UserData user;
  peopleList({required this.user});

  @override
  Widget build(BuildContext context) {
    return peopleCard(
        people: user,
        press: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Discussion(actuUser: user),
            )));
  }
}

class peopleCard extends StatelessWidget {
  const peopleCard({
    Key? key,
    required this.people,
    required this.press,
  }) : super(key: key);

  final UserData people;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12 * 0.75),
        child: Row(
          children: [
            Stack(
              children: [
                (people.profil == 'profil.png')
                    ? const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage('assets/profil.png'))
                    : CircleAvatar(
                        radius: 24,
                        backgroundImage: CachedNetworkImageProvider(people.profil),
                      ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      people.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        people.pseudo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

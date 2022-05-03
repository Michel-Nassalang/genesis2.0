import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:genesis/models/User.dart';
import 'package:genesis/models/discussion.dart';
import 'package:genesis/services/messageDatabase.dart';
import 'package:provider/provider.dart';


class ChatModel extends StatefulWidget {
  const ChatModel({ Key? key }) : super(key: key);

  @override
  _ChatModelState createState() => _ChatModelState();
}

class _ChatModelState extends State<ChatModel> {
  final MessageDatabaseService messageService = MessageDatabaseService();

  @override
  Widget build(BuildContext context) {
    final utilisateur = Provider.of<AppUser?>(context);
    final userList = Provider.of<Iterable<UserData>>(context);
    // final userFriends = Provider.of<Iterable<UserFriend>>(context);
    // List<String> friends = messageService.getFriend(utilisateur!.uid);
    // return ListView.builder(
    //   itemCount: friends.length,
    //   itemBuilder: (BuildContext context, int index) {
    //       return ChatList(user: DatabaseService(utilisateur.uid).friends(friends[index]));
    //   },
    return ListView.builder(
      itemCount: userList.length,
      itemBuilder: (BuildContext context, int index) {
          if(userList.elementAt(index).uid != utilisateur!.uid ){
            return ChatList(user: userList.elementAt(index));
          }else{
            return const Padding(padding: EdgeInsets.zero);
          }
      },
    );
    // return ListView.builder(
    //   itemCount: userFriends.length,
    //   itemBuilder: (BuildContext context, int index) {
    //       if(userFriends.elementAt(index).idFrom == utilisateur!.uid || userFriends.elementAt(index).idTo == utilisateur.uid){
    //         if(userFriends.elementAt(index).idFrom == utilisateur.uid){
    //           return ChatList(user: DatabaseService(utilisateur.uid).friends(userFriends.elementAt(index).idTo));
    //         }else{
    //           return ChatList(
    //             user: DatabaseService(utilisateur.uid)
    //                 .friends(userFriends.elementAt(index).idFrom));
    //         }
    //       }else{
    //         return const Padding(padding: EdgeInsets.zero);
    //       }
    //   },
    // );
  }
}

class ChatList extends StatelessWidget {
  final UserData user;
  const ChatList({required this.user});

  @override
  Widget build(BuildContext context) {
    return ChatCard(chat: user, press: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Discussion(actuUser: user),
                )));
  }
}


class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.chat,
    required this.press,
  }) : super(key: key);

  final UserData chat;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 12 * 0.75),
        child: Row(
          children: [
            Stack(
              children: [
                 (chat.profil == 'profil.png')
                    ? const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage('assets/profil.png'))
                    : CircleAvatar(
                        radius: 24,
                        backgroundImage: 
                        CachedNetworkImageProvider(chat.profil),
                      ),
                if (chat.statut == 'active')
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 3),
                      ),
                    ),
                  )
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        chat.pseudo,
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


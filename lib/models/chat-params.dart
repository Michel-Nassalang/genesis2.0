import 'package:genesis/models/User.dart';

class ChatParams {
  final String userUid;
  final UserData peer;

  ChatParams(this.userUid, this.peer);

  String getChatGroupId(){
    if(userUid.hashCode <= peer.uid.hashCode){
      return '$userUid-${peer.uid}';
    }else{
      return '${peer.uid}-$userUid';
    }
  }
}
class UserFriend{
  final String idFrom;
  final String idTo;
  UserFriend(this.idFrom, this.idTo);
}
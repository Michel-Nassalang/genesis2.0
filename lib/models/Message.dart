class Message {
  final String idFrom;
  final String idTo;
  final String timestamp;
  final String content;
  final int type;
  bool view;
  final String name;

  Message(
      {required this.idFrom,
      required this.idTo,
      required this.timestamp,
      required this.content,
      required this.type,
      required this.view,
      required this.name});

  Map<String, dynamic> tohashMap() {
    return {
      'idFrom': idFrom,
      'idTo': idTo,
      'timestamp': timestamp,
      'content': content,
      'type': type, 
      'view': view,
      'name' : name
    };
  }
  // Map<String, dynamic> tonewMap() {
  //   return {
  //     'view': view,
  //   };
  // }
}

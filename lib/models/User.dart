class AppUser {
  final String uid;

AppUser({required this.uid});
}

class UserData {
  final String uid;
  final String name;
  final String pseudo;
  final String age;
  final String statut;
  final String profil;

  UserData(this.uid, this.name, this.pseudo, this.age, this.statut, this.profil);
  
}
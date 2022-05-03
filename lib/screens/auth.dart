import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:genesis/common/loading.dart';
import 'package:genesis/services/authentification.dart';
import 'package:connectivity/connectivity.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;
  final emailControl = TextEditingController();
  final passwordControl = TextEditingController();
  final nameControl = TextEditingController();
  final pseudoControl = TextEditingController();
  final ageControl = TextEditingController();
  final AuthentificationService _auth = AuthentificationService();
  bool showSignIn = true;
  bool isConnected = true;
  late  AnimationController controlAnimation;
  late Animation<double> animation;
  

  @override
  void dispose() {
    emailControl.dispose();
    passwordControl.dispose();
    nameControl.dispose();
    pseudoControl.dispose();
    ageControl.dispose();
    controlAnimation.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controlAnimation =  AnimationController(
      duration : const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 0.9).animate(controlAnimation)..addListener(() {setState(() {
      
    });});
    controlAnimation.forward();
  }

  void initView() {
    setState(() {
      _formKey.currentState!.reset();
      error = '';
      emailControl.text = '';
      passwordControl.text = '';
      nameControl.text = '';
      pseudoControl.text = '';
      ageControl.text = '';
      showSignIn = !showSignIn;
    });
  }

  void login() async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi)  {
        if (_formKey.currentState!.validate()) {
        setState(() {
          loading = true;
        });
        var email = emailControl.value.text;
        var password = passwordControl.value.text;
        var name = nameControl.value.text;
        var pseudo = pseudoControl.value.text;
        var age = ageControl.value.text;

        dynamic result = showSignIn
            ? await _auth.signInWithEmailAndPassword(email, password)
            : await _auth.registerWithEmailAndPassword(
                name, pseudo, age, email, password);
        if (result == null) {
          setState(() {
            loading = false;
            error = 'Veuillez vérifier votre adresse mail ou mot de passe.';
          });
          Fluttertoast.showToast(msg: error, textColor: Colors.white, backgroundColor: Colors.red);
        }
      }
      }else{
        setState(() {
          loading = false;
          isConnected = false;
          error = 'Veuillez vérifier votre état de connection.';
        });
      Fluttertoast.showToast(msg: error);
      }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading() 
        : Scaffold(
            body: Stack(
            children: [
              Image.asset(
                'assets/genesis_flex.jpg',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.0, -0.9), end: Offset.zero).animate(controlAnimation),
                child: Form(
                  key: _formKey,
                  child: Container(
                    color:  Colors.grey.withOpacity(0.6),
                    child: ListView(
                      children: [
                        showSignIn ? const Padding(padding: EdgeInsets.only(top: 100)): const Padding(padding: EdgeInsets.only(top: 50)),
                        Center(
                          child: showSignIn
                              ? const SizedBox()
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: TextFormField(
                                    controller: nameControl,
                                    autofocus: false,
                                    obscureText: false,
                                    maxLines: 1,
                                    validator: (value) =>
                                        value!.isEmpty ? 'Donner votre nom' : null,
                                    decoration: const InputDecoration(
                                        errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 2.0)),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 2.5)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.lightBlue,
                                                width: 2.5)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.blue, width: 2)),
                                        labelText: 'Nom',
                                        labelStyle: TextStyle(fontSize: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(20)),
                                        )),
                                  ),
                                ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 40)),
                        Center(
                          child: showSignIn
                              ? const SizedBox()
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: TextFormField(
                                    controller: pseudoControl,
                                    autofocus: false,
                                    obscureText: false,
                                    maxLines: 1,
                                    validator: (value) => value!.isEmpty
                                        ? 'Donner votre pseudo'
                                        : null,
                                    decoration: const InputDecoration(
                                        errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 2.0)),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 2.5)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.lightBlue,
                                                width: 2.5)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.blue, width: 2)),
                                        labelText: 'Pseudo',
                                        labelStyle: TextStyle(fontSize: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(20)),
                                        )),
                                  ),
                                ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 40)),
                        Center(
                          child: showSignIn
                              ? const SizedBox()
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: TextFormField(
                                    keyboardType: const TextInputType.numberWithOptions(),
                                    controller: ageControl,
                                    autofocus: false,
                                    obscureText: false,
                                    maxLines: 1,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Veuillez donner votre age';
                                      } else if (int.parse(value) < 12) {
                                        return 'Vous n\'avez pas l\'age moyenne pour vous inscrire';
                                      } else {
                                        return null;
                                      }
                                    },
                                    // value!.isEmpty ? 'Donner votre age' : null,
                                    decoration: const InputDecoration(
                                        errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 2.0)),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.red, width: 2.5)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.lightBlue,
                                                width: 2.5)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                            borderSide: BorderSide(
                                                color: Colors.blue, width: 2)),
                                        labelText: 'Age',
                                        labelStyle: TextStyle(fontSize: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.all(Radius.circular(20)),
                                        )),
                                  ),
                                ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 40)),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: TextFormField(
                              controller: emailControl,
                              autofocus: false,
                              obscureText: false,
                              maxLines: 1,
                              validator: (value) =>
                                  value!.isEmpty ? 'Donner votre email' : null,
                              decoration: const InputDecoration(
                                  errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.0)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.5)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(
                                          color: Colors.lightBlue, width: 2.5)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide:
                                          BorderSide(color: Colors.blue, width: 2)),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(fontSize: 20),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  )),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 40)),
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: TextFormField(
                              controller: passwordControl,
                              obscureText: true,
                              maxLines: 1,
                              autofocus: false,
                              validator: (value) => value!.length < 6
                                  ? "Donner un mot de passe d'au moins 6 caractères"
                                  : null,
                              decoration: const InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(fontSize: 20),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.0)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.5)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide: BorderSide(
                                          color: Colors.lightBlue, width: 2.5)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      borderSide:
                                          BorderSide(color: Colors.blue, width: 2)),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  fillColor: Colors.grey),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 40)),
                        Center(
                          child: SizedBox(
                            child: ElevatedButton(
                              clipBehavior: Clip.hardEdge,
                              onPressed: login,
                              style: ButtonStyle(
                                  elevation: MaterialStateProperty.resolveWith(
                                      (states) => 8),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) => Colors.lightBlue),
                                  overlayColor: MaterialStateProperty.resolveWith(
                                      (states) => Colors.blue[200])),
                              child: showSignIn
                                  ? const Text('Se connecter',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20))
                                  : const Text('Créer un compte',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20)),
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            child: ElevatedButton(
                              autofocus: true,
                                onPressed: initView,
                                style: ButtonStyle(
                                    elevation: MaterialStateProperty.resolveWith(
                                        (states) => 8),
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.grey),
                                    overlayColor: MaterialStateProperty.resolveWith(
                                        (states) => Colors.blueGrey)),
                                child: showSignIn
                                    ? const Text('Créer un compte',
                                        style: TextStyle(color: Colors.white))
                                    : const Text('Se connecter',
                                        style: TextStyle(color: Colors.white))),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 40)),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ));
  }
}

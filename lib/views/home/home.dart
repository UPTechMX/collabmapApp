import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap_monitoring/views/home/sync.dart';

//import 'package:siap_monitoring/views/consultations/consultationsHome.dart'; // targetsHome
import 'package:siap_monitoring/views/questionnaires/targets/targetsHome.dart';
import 'privacidad.dart';

class Home extends StatefulWidget {
  bool firstSync;
  bool aceptaPriv;
  Home({this.firstSync = false, this.aceptaPriv = false});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int _nivel = -1;
  recuperaDatos(int nivel) async {
    SharedPreferences userData = await SharedPreferences.getInstance();
    int niv;
    if (userData.getInt('nivel') != null) {
      niv = userData.getInt('nivel');
    } else {
      niv = 0;
    }
    if (nivel == -1) {
//      print('cambia estado Home');
      _nivel = niv;
      setState(() => _nivel = niv);
    }
  }

  HomeState() {
    recuperaDatos(_nivel);
  }

  @override
  Widget build(BuildContext context) {
    return widget.aceptaPriv
        ? (widget.firstSync
            ? TargetsHome()
            : Sync(
                firstSync: false,
                barraSinBoton: true,
              ))
        : Privacidad(
            conAcept: true,
            barraSinBoton: true,
          );
    /* return widget.aceptaPriv
        ? (widget.firstSync
            ? ConsultationsHome()
            : Sync(
                firstSync: false,
                barraSinBoton: true,
              ))
        : Privacidad(
            conAcept: true,
            barraSinBoton: true,
          ); */
  }

  Future<Null> refrescar() async {}
}

import 'package:siap_monitoring/models/componentes/iconos.dart';
import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/layout/paginaList.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/models/layout/sliderPagina.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:strings/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'userTarget.dart';

class TargetsHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Pagina(
      future: getTargets(),
      barraSinBoton: false,
      botonBack: false,
      elemento: elemento,
      esLista: true,
      sync: false,
      textoVacio: Translations.of(context).text('empty'),
    );
  }

  Future<List> getTargets() async {
    DB db = DB.instance;

    SharedPreferences userData = await SharedPreferences.getInstance();
    int userId = userData.getInt('userId');
//    print(userId);

    List targets = [];
    List trgts = await db.query('''
      SELECT ut.id as utId, t.*
      FROM UsersTargets ut
      LEFT JOIN Targets t ON ut.targetsId = t.id
      WHERE ut.usersId = $userId
    ''');

    trgts ??= [];
    for(int i = 0; i<trgts.length;i++){
      var dims = await db.query("SELECT * FROM Dimensiones WHERE type = 'structure' AND elemId = ${trgts[i]['id']} ");
      dims ??= [];
      if(dims.length>0){
        targets.add(trgts[i]);
      }
    }

    return targets;
  }

  elemento({var datos}){
    return UserTarget(datos: datos,);
  }
}


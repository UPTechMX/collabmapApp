import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/layout/paginaList.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'proyecto.dart';
import 'package:siap_monitoring/models/translations.dart';

import 'package:siap_monitoring/models/layout/tarjeta.dart';
import 'package:siap_monitoring/models/componentes/boton.dart';

class Proyectos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Pagina(
      textoVacio: Translations.of(context).text('empty'),
      future: getData(),
      elemento: elemento,
      nombrePagina: 'Proyectos',
      drawer: true,
      esLista: false,
      slider: true,
      sliderHeight: MediaQuery.of(context).size.height*.27,
    );
  }

  Future<List> getData() async {
    DB db = DB.instance;

    List datos = await db.query("SELECT * FROM projects");
    datos ??= [];

    return datos;
  }

  elemento({var datos}){
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        padding: EdgeInsets.all(0),
        color: Colors.white,
        onPressed: (){
          print('datos');
        },
        child: Tarjeta(datos: datos,),
      ),
    );
  }

}



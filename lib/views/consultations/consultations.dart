import 'package:flutter/material.dart';
import 'package:siap/models/layout/paginaList.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/models/conexiones/api.dart';
import 'package:siap/models/translations.dart';
import 'package:siap/models/componentes/boton.dart';
import 'package:siap/views/surveys/surveys.dart';

class Consultations extends StatefulWidget {
  var phaseId;
  String phaseName;
  Consultations({this.phaseId, this.phaseName});

  @override
  ConsultationsState createState() => ConsultationsState();
}

class ConsultationsState extends State<Consultations> {
  @override
  Widget build(BuildContext context) {
    return Pagina(
      textoVacio: Translations.of(context).text('empty'),
      esLista: true,
      future: getData(),
      elemento: elemento,
      nombrePagina:
          '${Translations.of(context).text('consultations')} ${widget.phaseName}',
    );
  }

  Future<List> getData() async {
    DB db = DB.instance;

    List datos = await db.query(
        "SELECT * FROM consultations WHERE phase_id = ${widget.phaseId}");
    datos ??= [];

    return datos;
  }

  elemento({var datos}) {
    return Boton(
      texto: datos['name'],
      onClick: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => Surveys(
                      consultationId: datos['id'],
                      consultationName: datos['name'],
                    )));
      },
      icono: Icon(
        Icons.add,
        color: Colors.white,
      ),
      color: Color(0xFFF8B621),
    );
  }
}

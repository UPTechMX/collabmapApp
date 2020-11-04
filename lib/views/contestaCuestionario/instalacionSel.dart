import 'package:flutter/material.dart';
import 'package:siap_monitoring/views/questionnaires/targets/targetsElemsList.dart';
import 'package:siap_monitoring/models/cuestionario/checklist.dart';
import 'package:siap_monitoring/views/contestaCuestionario/bloques.dart';
import 'package:siap_monitoring/views/contestaCuestionario/areas.dart';
import 'package:siap_monitoring/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';

class InstalacionSel extends StatefulWidget {
  Checklist chk;
  GlobalKey<PreguntasContState> keyPreguntas;
  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<TargetsElemsListState> keyTargElemList;

  InstalacionSel(
      {this.chk,
      this.keyBloques,
      this.keyAreas,
      this.keyPreguntas,
      this.keyTargElemList});

  @override
  InstalacionSelState createState() => InstalacionSelState(
      chk: chk,
      keyPreguntas: keyPreguntas,
      keyBloques: keyBloques,
      keyAreas: keyAreas,
      keyTargElemList: keyTargElemList);
}

class InstalacionSelState extends State<InstalacionSel> {
  Checklist chk;
  GlobalKey<PreguntasContState> keyPreguntas;
  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<TargetsElemsListState> keyTargElemList;

  var chkId;
  var datosVis;
  var datosChk;
  var selected;
  var selected2;

  var db = DB.instance;

  InstalacionSelState(
      {this.chk,
      this.keyBloques,
      this.keyAreas,
      this.keyPreguntas,
      this.keyTargElemList});

  @override
  Widget build(BuildContext context) {
//    print(chk.vId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Selecciona una instalación:",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        FutureBuilder<List>(
          future: getInstalaciones(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: Text('No se encontraron instalaciones.'));
            return Column(
              children: snapshot.data.map((lista) {
                return DropdownButton(
                  items: lista,
                  value: selected2 == null ? selected : selected2,
                  hint: Text('Selecciona una instalacion'),
                  onChanged: (value) {
                    setState(() {
                      selected2 = value;
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        botonesContinuar()
      ],
    );
  }

  Future<List> getInstalaciones() async {
    datosVis = await chk.datosVisita(true);
    datosChk = await chk.datosChk(false);
    chkId = await chk.chkId();

    switch (datosChk['etapa']) {
      case 'visita':
        selected = datosVis['instalacionSug'];
        break;
      case 'instalacion':
        selected = datosVis['instalacionRealizada'];
        break;
    }

    var insts = await db.query(
        'SELECT * FROM Instalaciones WHERE proyectosId = ${datosVis['proyectosId']}');

    List items = new List<DropdownMenuItem>();
    for (int i = 0; i < insts.length; i++) {
      var inst = insts[i];
      if (inst['elim'] == 1) {
        continue;
      }
      var item = DropdownMenuItem(
        child: Text(
          parseHtmlString(inst['nombre']),
          style: TextStyle(fontSize: 14),
        ),
        value: inst['id'],
      );
      items.add(item);
    }
    List list = [];
    list.add(items);
    return list;
  }

  botonesContinuar() {
    return Container(
      padding: EdgeInsets.only(top: 50),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: RaisedButton(
              color: Colors.blue,
              child: Text(
                'Regresar',
              ),
              onPressed: regresa,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(''),
          ),
          Expanded(
              flex: 5,
              child: RaisedButton(
                color: Colors.blue,
                child: Text(
                  'Siguiente',
                ),
                onPressed: avanza,
              )),
        ],
      ),
    );
  }

  avanza() async {
    var instSel = selected2 == null ? selected : selected2;

    var datosVis = await chk.datosVisita(false);
    var datosChk = await chk.datosChk(false);
    switch (datosChk['etapa']) {
      case 'visita':
        await db.query(
            'UPDATE Clientes SET instalacionSug = $instSel WHERE id = ${datosVis['cId']}');
        break;
      case 'instalacion':
//        print('acá $instSel');
        await db.query(
            'UPDATE Clientes SET instalacionRealizada = $instSel WHERE id = ${datosVis['cId']}');
        break;
    }

    var areas = new Map();
    areas['_fotos_'] = new Map();
    areas['_fotos_']['nombre'] = 'Fotografías';

    keyBloques.currentState.updBloqueActivo('__fotografias__');
    keyPreguntas.currentState.cambiaPagina('fotografias');
    keyAreas.currentState.actualizaAreas(areas);
    keyAreas.currentState.updAreaActivo('_fotos_');
  }

  regresa() async {
    var instSel = selected2 == null ? selected : selected2;

    var datosVis = await chk.datosVisita(false);
    var datosChk = await chk.datosChk(false);
    switch (datosChk['etapa']) {
      case 'visita':
        await db.query(
            'UPDATE Clientes SET instalacionSug = $instSel WHERE id = ${datosVis['cId']}');
        break;
      case 'instalacion':
        await db.query(
            'UPDATE Clientes SET instalacionRealizada = $instSel WHERE id = ${datosVis['cId']}');
        break;
    }

    widget.keyPreguntas.currentState.cambiaPagina('preguntas');
  }
}

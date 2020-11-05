import 'package:flutter/material.dart';
import 'package:siap_monitoring/views/questionnaires/targets/userTarget.dart';
import 'package:siap_monitoring/views/questionnaires/targets/targetsElemsList.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:siap_monitoring/views/contestaCuestionario/bloques.dart';
import 'package:siap_monitoring/views/contestaCuestionario/areas.dart';
import 'package:siap_monitoring/views/contestaCuestionario/preguntasCont.dart';
import 'package:siap_monitoring/models/cuestionario/checklist.dart';
import 'package:siap_monitoring/views/contestaCuestionario/multimedia.dart';
import 'package:siap_monitoring/views/verCuestionario/verCuestionario.dart';
import 'package:siap_monitoring/views/verCuestionario/cuestionario.dart';

import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Fotografias extends StatefulWidget {
  Checklist chk;
  GlobalKey<BloquesBtnState> keyBloques;
  GlobalKey<AreasState> keyAreas;
  GlobalKey<PreguntasContState> keyPreguntas;
  GlobalKey<VerCuestionarioState> keyCuestionario;
  GlobalKey<UserTargetState> keyUser;

  Fotografias({
    this.chk,
    this.keyBloques,
    this.keyAreas,
    this.keyPreguntas,
    this.keyCuestionario,
    this.keyUser,
  });

  @override
  FotografiasState createState() => FotografiasState(
        chk: chk,
      );
}

class FotografiasState extends State<Fotografias> {
  Checklist chk;
  String etapa;
  String justif;
  Viable viable;
  GlobalKey<ViableState> keyViable = GlobalKey();

  File image;
  Future tomarFoto() async {
    File picture = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 1000.0, maxHeight: 1000.0);

    if (picture != null) {
      var directory =
          await getApplicationDocumentsDirectory(); // AppData folder path
      var vId = chk.vId;

      var path = '${directory.path}/$vId';

      var existeDirVisita = await Directory(path).exists();
      if (!existeDirVisita) {
        await creaDirectorio(path);
      }

      String fileName = picture.path.split('/').last;
      String nomArch = 'fotografia_${vId}_$fileName';
      picture.copy('${path}/${nomArch}');

      await chk.guardaMultimedia(nomArch);
      setState(() {
        image = picture;
      });
    }
  }

  Future usarFoto() async {
    File picture = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1000.0, maxHeight: 1000.0);
    if (picture != null) {
      var directory =
          await getApplicationDocumentsDirectory(); // AppData folder path
      var vId = chk.vId;

      var path = '${directory.path}/$vId';

      var existeDirVisita = await Directory(path).exists();
      if (!existeDirVisita) {
        await creaDirectorio(path);
      }

      String fileName = picture.path.split('/').last;
      String nomArch = 'fotografia_${vId}_$fileName';
      picture.copy('${path}/${nomArch}');

      await chk.guardaMultimedia(nomArch);
      setState(() {
        image = picture;
      });
    }
  }

  creaDirectorio(path) async {
    await Directory(path).create(recursive: true).then((Directory directory) {
      print(directory.path);
    });
  }

  FotografiasState({
    this.chk,
  }) {
    viable = Viable();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chk.datosVis['etapa'] != 'instalacion'
              ? botonesFotografia()
              : Container(),
//          fotografia(),
          Multimedia(
            chk: chk,
          ),
          botonesContinuar()
        ],
      ),
    );
  }

  botonesFotografia() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
              mini: true,
              child: Icon(Icons.photo_library),
              onPressed: usarFoto,
            ),
            FloatingActionButton(
              mini: true,
              child: Icon(Icons.camera_enhance),
              onPressed: tomarFoto,
            ),
          ],
        ),
      ),
    );
  }

  fotografia() {
    return Center(
      child: image == null
          ? Text('No hay imagen seleccionada')
          : Image.file(image),
    );
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
              onPressed: aPregs,
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
                  'Finalizar cuestionario',
                ),
                onPressed: finalizar,
              )),
        ],
      ),
    );
  }

  aPregs() async {
    var chkDatos = await chk.datosChk(false);
    if (chkDatos['etapa'] == 'visita' || chkDatos['etapa'] == 'instalacion') {
      var bloque = '__instalaciones__';

      var areas = new Map();
      areas['_insts_'] = new Map();
      areas['_insts_']['nombre'] = 'Instalación';
      var areaAct = '_insts_';
      widget.keyBloques.currentState.updBloqueActivo(bloque);
      widget.keyAreas.currentState.actualizaAreas(areas);
      widget.keyAreas.currentState.updAreaActivo(areaAct);

      widget.keyPreguntas.currentState.cambiaPagina('instalacion');
    } else {
      widget.keyPreguntas.currentState.cambiaPagina('preguntas');
    }
  }

  test() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bla'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Una vez finalizado ya no podrá modificarse',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  finalizar() async {
    var faltaPreg = await chk.faltaPreg();
    if (faltaPreg != null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Faltan preguntas por contestar'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Existen preguntas sin respuesta.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ir'),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.keyPreguntas.currentState.cambiaPagina('preguntas');
                },
              ),
            ],
          );
        },
      );
    }

    bool faltaFoto = false;
    String fotoFaltante;
    for (var i in chk.fotosInst.keys) {
      DB db = DB.instance;
      String sql = '''
        SELECT * 
        FROM Multimedia 
        WHERE archivo LIKE 'fotografia_${chk.vId}_${i}_%'
      ''';

      var foto = await db.query(sql);

      if (foto == null) {
        faltaFoto = true;
        fotoFaltante = chk.fotosInst[i];
        break;
      }
    }

    if (faltaFoto && chk.datosVis['etapa'] == 'instalacion') {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          //return verCuestionario();
          return AlertDialog(
            title: Text('Faltan fotografías por subir'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Falta al menos la fotografía $fotoFaltante.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
//                  widget.keyPreguntas.currentState.cambiaPagina('preguntas');
                },
              ),
            ],
          );
        },
      );
    }
    var chkDatos = await chk.datosChk(false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Finalizar cuestionario'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Resumen del cuestionario:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Cuestionario(chk.vId),
                Text(
                  'Una vez finalizado ya no podrá modificarse',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                chkDatos['etapa'] == 'visita'
                    ? viable
                    : Container(
                        width: 0,
                        height: 0,
                      ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Continuar'),
              onPressed: () {
                var viableInst = viable.viable;
                var justifViable = viable.justif;

                if (chkDatos['etapa'] == 'visita') {
                  if (viableInst == 1) {
                    print('finaliza');
                    finVis(viable: true);
                  } else {
                    if (justifViable != null && justifViable != '') {
                      print('cancela por no viable');
                      finVis(viable: false, justifViable: justifViable);
                    }
                  }
                } else {
                  print('finaliza');
                  finVis(viable: true);
                }
              },
            ),
          ],
        );
      },
    );
  }

  finVis({bool viable = true, String justifViable = ''}) async {
    await chk.finalizaVisita(viable: viable, justifViable: justifViable);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).setState(() {});
    widget.keyUser.currentState.finishSurvey();
  }
}

class Viable extends StatefulWidget {
  String justif;
  var viable;

  Viable() {
    justif = null;
    viable = null;
  }

  @override
  ViableState createState() => ViableState();
}

class ViableState extends State<Viable> {
  var selected;
  TextEditingController justifController = TextEditingController();

  List items = new List<DropdownMenuItem>();
  ViableState() {
    items.add(DropdownMenuItem(
      child: Text(
        'Sí',
        style: TextStyle(fontSize: 14),
      ),
      value: 1,
    ));
    items.add(DropdownMenuItem(
      child: Text(
        'No',
        style: TextStyle(fontSize: 14),
      ),
      value: 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    justifController = TextEditingController(text: widget.justif);
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: 48.0),
          Text('¿Es viable para instalación?'),
          DropdownButton(
            items: items,
            value: selected,
            hint: Text('¿Es viable?'),
            onChanged: (value) {
              setState(() {
                selected = value;
                widget.viable = value;
              });
            },
          ),
          selected == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 48.0),
                    Text('¿Por qué no es viable?'),
                    TextField(
                        controller: justifController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (text) {
//                  print(text);
                          widget.justif = text;
//                  print(justif);
                        })
                  ],
                )
              : Container(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
    );
  }
}

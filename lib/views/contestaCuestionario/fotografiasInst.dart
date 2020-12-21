import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/cuestionario/checklist.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';

import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';



class FotografiasInst extends StatelessWidget {

  Checklist chk;
  FotografiasInst({this.chk});

  @override
  Widget build(BuildContext context) {


    List<Widget> rows = <Widget>[];

    for(var i in chk.fotosInst.keys){
      rows.add(FotoInst(chk: chk,fotoId: i,nombre: chk.fotosInst[i],));
    }

    return Container(
      child: Column(
        children: rows,
      ),
    );
  }
}



class FotoInst extends StatefulWidget {

  Checklist chk;
  String fotoId;
  String nombre;


  FotoInst({this.chk,this.fotoId,this.nombre});

  @override
  FotoInstState createState() => FotoInstState();
}

class FotoInstState extends State<FotoInst> {

  String path;
  Directory directory;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFotografia(),
      builder: (context,snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Esperando resultados');
          case ConnectionState.done:
            if (snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }
//            print('= = = = = SNAPSHOT = = = =');
//            print(snapshot.data);

            File imagen;
            var widgetImg;
            if(snapshot.data != null){
              imagen = File('${path}/${snapshot.data['archivo']}');
              var tamano = (MediaQuery.of(context).size.width*.3)-10;
              widgetImg = Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Image.file(imagen,width: tamano,),
                    Container(
                      child: FlatButton(
                          onPressed: (){
                            delImg(snapshot.data);
                          },
                          child: Icon(Icons.delete,size: 20,color: Colors.red,)
                      ),
                    )
                  ],
                ),
              );

            }


            return Container(
              margin: EdgeInsets.only(top: 5,bottom: 5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(widget.nombre),
                  ),
                  Expanded(
                    flex: 2,
                    child: snapshot.data == null?
                      botonesFotografia():
                      widgetImg,
                  ),
                ],
              ),
            );
          default:
            return Column();
        }

      },
    );
  }

  File image;
  Future tomarFoto() async {
    File picture = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 1000.0, maxHeight: 1000.0);

    if(picture != null){
      var directory = await getApplicationDocumentsDirectory(); // AppData folder path
      var vId = widget.chk.vId;
//      print('====VID====');
//      print(vId);

      var path = '${directory.path}/$vId';

      var existeDirVisita = await Directory(path).exists();
      if(!existeDirVisita){
        await creaDirectorio(path);
      }

      String fileName = picture.path.split('/').last;
      String nomArch = 'fotografia_${vId}_${widget.fotoId}_$fileName';
      picture.copy('${path}/${nomArch}');

      await widget.chk.guardaMultimedia(nomArch);
      setState(() {
        image = picture;
      });
    }
  }

  Future usarFoto() async {

    File picture = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1000.0, maxHeight: 1000.0);
    if(picture != null){
      var directory = await getApplicationDocumentsDirectory(); // AppData folder path
      var vId = widget.chk.vId;

      var path = '${directory.path}/$vId';

      var existeDirVisita = await Directory(path).exists();
      if(!existeDirVisita){
        await creaDirectorio(path);
      }

      String fileName = picture.path.split('/').last;
      String nomArch = 'fotografia_${vId}_${widget.fotoId}_$fileName';
      picture.copy('${path}/${nomArch}');

      await widget.chk.guardaMultimedia(nomArch);
      setState(() {
        image = picture;
      });

    }
  }

  creaDirectorio(path) async {
    await Directory(path).create(recursive: true)
        .then((Directory directory){
      print(directory.path);
    });
  }



  botonesFotografia(){
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

  delImg(img) async {
    var db = DB.instance;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar imagen'),
          content: SingleChildScrollView(
            child: Container(
              child: Text('¿Deseas eliminar la fotografía?'),
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
              child: Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await db.delete('Multimedia', ' id = ${img['id']}', []);
                File imagen = File('${path}/${img['archivo']}');
                imagen.delete(recursive:true);
                Navigator.of(context).pop();
                setState(() {
//                  del = true;
                });
              },
            ),
          ],
        );
      },
    );

  }



  getFotografia() async {
    directory = await getApplicationDocumentsDirectory(); // AppData folder path
    path = '${directory.path}/${widget.chk.vId}';


    DB db = DB.instance;
    String sql = '''
      SELECT * 
      FROM Multimedia 
      WHERE archivo LIKE 'fotografia_${widget.chk.vId}_${widget.fotoId}_%'
    ''';

    var foto = await db.query(sql);
//    print('------- foto -------');
//    print(foto);
    if(foto == null){
      return null;
    }else{
      return foto[0];
    }
  }


}

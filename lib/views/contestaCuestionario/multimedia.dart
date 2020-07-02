import 'package:flutter/material.dart';
import 'package:siap/models/cuestionario/checklist.dart';
import 'package:siap/views/contestaCuestionario/fotografiasInst.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:siap/models/conexiones/DB.dart';


class Multimedia extends StatefulWidget{
  Checklist chk;
  Directory directory;
  String path;

  Multimedia({this.chk});

  @override
  MultimediaState createState() => MultimediaState(chk: chk);

}

class MultimediaState extends State<Multimedia>{

  Checklist chk;
  Directory directory;
  String path;
  MultimediaState({this.chk});
  bool del;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: multList(),
      builder: (context,snapshot){
        if(!snapshot.hasData && chk.datosVis['etapa'] != 'instalacion') return Center(child: Text('No se encontraron imágenes para esta visita.'));
        int i = 0;
        List rowEles = [];
//        print('aaa');
        return chk.datosVis['etapa'] != 'instalacion'?
        Column(
          children:snapshot.data.map((img){
//            print('IMG $img');
            if(i%3 == 0){
              rowEles = <Widget>[];
            }

            File imagen = File('${path}/${img['archivo']}');
//            print(imagen);
            var tamano = (MediaQuery.of(context).size.width*.3)-10;

            var widgetImg = Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  Image.file(imagen,width: tamano,),
                  Container(
                    child: FlatButton(
                        onPressed: (){
                          delImg(img);
                        },
                        child: Icon(Icons.delete,size: 20,color: Colors.red,)
                    ),
                  )
                ],
              ),
            );


            rowEles.add(widgetImg);
            if(i%3 == 2 || i == (snapshot.data.length -1)){
              i++;
              return Row(
                children:rowEles,
              );
            }else{
              i++;
              return Container(width: 0,height: 0,);
            }
            
          }).toList(),
        ):
        FotografiasInst(chk: chk,);
      },
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
                  del = true;
                });
              },
            ),
          ],
        );
      },
    );

  }



  Future<List> multList() async {
    directory = await getApplicationDocumentsDirectory(); // AppData folder path
    path = '${directory.path}/${chk.vId}';

    List mult = await chk.getMultimedia();

    return mult;

  }

}


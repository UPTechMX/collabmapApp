import 'package:flutter/material.dart';
import 'mapManager.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TarjetaInfo extends StatefulWidget {

  var updateFnc;
  Map datos;
  TarjetaInfo({this.updateFnc,this.datos});

  @override
  TarjetaInfoState createState() => TarjetaInfoState();

}

class TarjetaInfoState extends State<TarjetaInfo> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Text(
                    widget.datos['name'],
                    style:TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    '${widget.datos['fileSize']} MB',
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: (){
                      delMap(context: context,datos: widget.datos);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> delMap({BuildContext context,Map datos}) async {

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translations.of(context).text('confirm')),
          content: SingleChildScrollView(
            child: Center(
              child: Text(Translations.of(context).text('delete_map')),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(Translations.of(context).text('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(Translations.of(context).text('delete')),
              onPressed: () {
                delMapa(datos: widget.datos,context: context);
              },
            ),
          ],
        );
      },
    );
  }

  void delMapa({Map datos, BuildContext context}) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    print('${datos['id']}.mbtiles');
    File map = await File('$dir/maps/${datos['fileName']}');
    await map.delete(recursive: true);
    Navigator.of(context).pop();
    this.widget.updateFnc();
  }
}


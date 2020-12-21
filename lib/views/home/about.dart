import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/layout/paginaList.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/models/conexiones/DB.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_html/flutter_html.dart';


class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Pagina(
        drawer: false,
        esLista: false,
        nombrePagina: null,
        elemento: FutureBuilder(
          future: getData(),
          builder: (context,snapshot){
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('');
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Text(Translations.of(context).text('waiting'));
              case ConnectionState.done:
                if (snapshot.hasError){
                  return Text('Error: ${snapshot.error}');
                }
                Map datos = snapshot.data;
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    color: Colors.white.withAlpha(200),
                    padding: EdgeInsets.only(left: 5,bottom: 15,right: 5,top: 15),
                    child: Column(
                      children: <Widget>[
                        Text(
                          Translations.of(context).text('about').toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height * .03,
                            color: Color(0xFF2568D8),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Html(
                          data:'${datos['texto']}',
                          customTextAlign: (a) {
                            return TextAlign.justify;
                          },

                        ),
//                        SizedBox(height: 10,),
//                        Container(
//                          child: datos['image'],
//                        ),
//                        SizedBox(height: 10,),
//                        Html(
//                          data:'${datos['content2']}',
//                          customTextAlign: (a) {
//                            return TextAlign.justify;
//                          },
//
//                        ),
                      ],
                    ),
                  ),
                );
              default:
                return Column();
            }
          },
        ),
      ),
    );
  }

  getData() async {
    DB db = DB.instance;
    List datos = await db.query("SELECT * FROM General WHERE name = 'about'");
    datos ??= [];

    Map dat = Map.from(datos[0]);
//    String dir = (await getApplicationDocumentsDirectory()).path;

//    File file = File('${dir}/projects/${dat['image']}');
//    Image img = Image.file(file);
//    dat['image'] = img;


    return dat;

  }

}

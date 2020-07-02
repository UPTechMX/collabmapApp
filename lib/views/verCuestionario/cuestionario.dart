import 'package:flutter/material.dart';
import 'package:siap/models/cuestionario/checklist.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:html/parser.dart';

class Cuestionario extends StatefulWidget{

  int vId;
  Cuestionario(this.vId);

  @override
  CuestionarioState createState() => CuestionarioState(vId);

}

class CuestionarioState extends State<Cuestionario>{

  int vId;
  Checklist chk;
  CuestionarioState(int _vId){
    this.vId = _vId;
    chk = Checklist(_vId);
  }

  @override
  Widget build(BuildContext context) {
    
//    print('chk.id = ${chk.id}');
    List lista = new List();


    return FutureBuilder<List<Widget>>(
      future: vistas(),
      builder: (context,snapshot){
//        print('snapshot : ${snapshot.data}');
        if(!snapshot.hasData) return Center(child: Text('No se encontraron vistas.'));
        return Column(
            children:snapshot.data.map(
              (vista) => vista
            ).toList()
        );
      },
    );
  }

  Future<List<Widget>> vistas() async{

    DB db = DB.instance;
    var datosChk = await chk.datosChk(false);

    List<Widget> lista = [];
//    lista.add(Encabezado(vId,chk));
//    print("ETAPA!! ${datosGral['etapa']}");
    if(datosChk['etapa'] != 'instalacion'){
//      print("SI BLOQUES");
      lista.add(Bloques(vId));

    }
//    print('AAAAA $vId');
    if(datosChk['etapa'] == 'instalacion' || datosChk['etapa'] == 'visita'){
      if(datosChk['etapa'] == 'instalacion') {
        lista.add(Instalacion(vId,chk,'instalacion'));
      }
      if(datosChk['etapa'] == 'visita') {
        lista.add(Instalacion(vId,chk,'visita'));
      }
    }


    return lista;

  }

}

class Instalacion extends StatelessWidget{

  int vId;
  Checklist chk;
  String tipo;

  Instalacion(this.vId,this.chk,this.tipo);

  @override
  Widget build(BuildContext context) {
    

//    chk.getInstalacion();
    return FutureBuilder<List>(
      future: gInstalacion(false,tipo),
      builder: (context,snapshot){
        if(!snapshot.hasData) return Center(child: Text('No se encontraron instalaciones.'));
        return Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(color: Colors.blue,),
              child: Center(
                  child: Text(
                    'Instalación',
                    style: TextStyle(fontWeight:FontWeight.w600,fontSize: 15),
                  )
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: snapshot.data.map(
                      (datos)=>Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            datos['area'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                          ),
                        ),
                        Container(
                          child: Text(
                            datos['texto'],
                          ),
                        )
                      ],
                    ),
                  )
              ).toList(),
            )
          ],
        );
      },
    );
  }

  Future<List> gInstalacion(bool cantidades,String tipo) async {
    var instalacion = await chk.getInstalacion(cantidades,tipo);

//    print(instalacion);
    return instalacion;
  }


}

class Encabezado extends StatelessWidget{
  var db = DB.instance;
  int vId;
  Checklist chk;

  Encabezado(this.vId,this.chk);

  @override
  Widget build(BuildContext context) {
    
//    print(vId);

    return FutureBuilder<List>(
      future: getDatosGral(),
      builder: (context,snapshot){
//        print('snapshot : ${snapshot.data}');
        if(!snapshot.hasData) return Center(child: Text('No se encontraron datos.'));
        return Column(
            children:snapshot.data.map(
                    (datos)=>Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    child:Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(color: Colors.blue,),
                          child: Center(
                              child: Text(
                                'Datos generales',
                                style: TextStyle(fontWeight:FontWeight.w600,fontSize: 15),
                              )
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top:15,bottom: 15,left:5,right: 5),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        'Integrante IU',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        'Usuario',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        'Fecha',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        '${datos['uaNom']}',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        '${datos['cNom']}',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Text(
                                        '${datos['fechaRealizacion']}',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(color: Colors.blue,),
                          child: Center(
                              child: Text(
                                'Resumen',
                                style: TextStyle(fontWeight:FontWeight.w600,fontSize: 15),
                              )
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top:15,bottom: 15,left:5,right: 5),
                          child: Text(
                              '${datos['resumen']}'
                          ),
                        ),

                      ],
                    )
                )
            ).toList()
        );
      },
    );
  }

  Future<List> getDatosGral() async {
    var datosGral = await chk.datosVisita(false);
    List datos =  [];
    datos.add(datosGral);

    return datos;
  }


}

class Bloques extends StatelessWidget{

  int vId;
  Checklist chk;
  Bloques(int _vId){
    this.vId = _vId;
    chk = Checklist(vId);
  }

  @override
  Widget build(BuildContext context) {
    ;
//    bloquesList();
    return FutureBuilder<List>(
      future: bloquesList(),
      builder: (context,snapshot){
//        print('snapshot : ${snapshot.data}');
        if(!snapshot.hasData) return Center(child: Text('No se encontraron bloques.'));
        return Column(
          children:snapshot.data.map(
            (bloque)=>Container(
              padding: const EdgeInsets.only(bottom: 10),
              child:Bloque(bloque,chk)
            )
          ).toList()
        );
      },
    );
  }

  Future<List> bloquesList() async {
    var bloques = await chk.getBloquesCalc();
    return bloques;
  }
}

class Bloque extends StatelessWidget{
  Map bloque;
  Checklist chk;
  Bloque(this.bloque,this.chk);

  @override
  Widget build(BuildContext context) {
    
//    print(bloque['identificador']);
//    print(chk.calcs);

    if(chk.calcs == null){
      return CircularProgressIndicator();
    }
    if(chk.calcs['bloques'][bloque['identificador']]['muestra'] == 0){
      return Container(
        width: 0,
        height: 0,
        padding: EdgeInsets.all(0),
//        child: Text(''),
      );
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(color: Colors.blue,),
            child: Center(
                child: Text(
                  bloque['nombre'],
                  style: TextStyle(fontWeight:FontWeight.w600,fontSize: 15),
                )
            ),
          ),
          Areas(bloque['areas'],bloque['identificador'],chk),
        ],
      ),
    );
  }



}

class Areas extends StatelessWidget{

  Map areas;
  Checklist chk;
  int cuenta;
  String bloqueId;
  Areas(Map areas, String bloque, Checklist chk){
    this.areas = areas;
    this.chk = chk;
    this.cuenta = 1;
    this.bloqueId = bloque;
  }


  @override
  Widget build(BuildContext context) {
    

    return FutureBuilder<List>(
      future: areasList(areas),
      builder: (context,snapshot){
//        print('snapshot : ${snapshot.data}');
        if(!snapshot.hasData) return Center(child: Text('No se encontraron áreas.'));
        return Column(
            children:snapshot.data.map(
                    (area){
                      return Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child:Area(area,bloqueId,chk,this.cuenta++)
                      );
                    }
            ).toList()
        );
      },
    );
  }


  Future<List> areasList(areas) async {
    List lista = [];
    areas.forEach((k,v){
      v['identificador'] = k;
      lista.add(v);
    });
    return lista;
  }

}

class Area extends StatelessWidget{

  Map area;
  Checklist chk;
  int cuenta;
  String bloqueId;

  Area(this.area,this.bloqueId,this.chk,this.cuenta);

  @override
  Widget build(BuildContext context) {
    
    if(chk.calcs['bloques'][bloqueId]['areas'][area['identificador']]['muestra'] == 1){
      return Container(
        child: Column(
          children: <Widget>[
            Container(
                child:Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 30,
                        child: Center(
                          child:Text('${this.cuenta}'),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 10,
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(color: Colors.grey[350],),
                          child:Text(area['nombre']),
                        )
                    )
                  ],
                )
            ),
            Preguntas(area['preguntas'],chk),
          ],
        ),
      );
    }else{
      return Container(
        width: 0,
        height: 0,
        padding: EdgeInsets.all(0),
        child: Text(''),
      );

    }
  }

}

class Preguntas extends StatelessWidget{

  Map preguntas;
  Checklist chk;
  int cuenta = 1;

  Preguntas(this.preguntas,this.chk);


  @override
  Widget build(BuildContext context) {
    

    return FutureBuilder<List>(
      future: preguntasList(preguntas),
      builder: (context,snapshot){
//        print('snapshot : ${snapshot.data}');
        if(!snapshot.hasData) return Center(child: Text('No se encontraron preguntas.'));
        return Column(
            children:snapshot.data.map(
                    (pregunta){
                  return Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child:Pregunta(pregunta,chk,this.cuenta++)
                  );
                }
            ).toList()
        );
      },
    );
  }

  Future<List> preguntasList(preguntas) async {
    List lista = [];
    preguntas.forEach((k,v){
      v['identificador'] = k;
      lista.add(v);
    });
    return lista;
  }

}

class Pregunta extends StatelessWidget{

  Map pregunta;
  int cuenta;
  Checklist chk;

  Pregunta(this.pregunta,this.chk,this.cuenta);

  @override
  Widget build(BuildContext context) {
    
    var pregChk= chk.preguntas[pregunta['identificador']];
//    print(pregChk);
    var tipo = pregChk['tipo'];
    var pregText = parseHtmlString('${pregunta['pregunta']}');
//    print('$pregText - ${pregChk['muestra']}');
    if(pregChk['muestra'] == 0){
      return Container(
        width: 0,
        height: 0,
        padding: EdgeInsets.all(0),
//        child: Text(''),
      );
    }

    if(tipo != 'sub'){
      var nomResp = pregChk['nomResp'] == null?'':parseHtmlString('${pregChk['nomResp']}');
      var justificacion = pregChk['justificacion'] == null?'':parseHtmlString('${pregChk['justificacion']}');
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color:Colors.grey,)
          )
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child:Container(
                    padding: EdgeInsets.only(top:20,bottom:20),
                    decoration: BoxDecoration(color: Colors.transparent,),
                    child: Center(
                    child: Text(
                      '$cuenta',
                    ),
                  )
                ),
            ),
            Expanded(
              flex: 2,
              child:Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  pregText,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(''),
            ),
            Expanded(
              flex: 2,
              child: Text('${nomResp}'),
            ),
            Expanded(
              flex: 2,
              child: Text('${justificacion}'),
            )
          ],
        )

      );
    }else{
//      print('$pregText');
      return Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child:Container(
                padding: EdgeInsets.only(top:20,bottom:20),
                decoration: BoxDecoration(color: Colors.transparent,),
                child: Center(
                  child: Text(
                    '$cuenta',
                  ),
                )
            ),
          ),
          Expanded(
            flex: 2,
            child:Container(
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(color: Colors.grey[350],),
              child: Text('$pregText'),
            )
          ),
          Expanded(
            flex: 1,
            child: Text(''),
          ),
          Expanded(
            flex: 5,
//            child:Text("SUBPREGUNTAS")
            child: Subpreguntas(pregunta['subpregs'],chk),
          ),
        ],
      );

    }
  }
}

class Subpreguntas extends StatelessWidget{

  Map subpreguntas;
  Checklist chk;
  int cuenta = 1;

  Subpreguntas(this.subpreguntas,this.chk);


  @override
  Widget build(BuildContext context) {
    

    return FutureBuilder<List>(
      future: subpreguntasList(subpreguntas),
      builder: (context,snapshot){
//        print('snapshot : ${snapshot.data}');
        if(!snapshot.hasData) return Center(child: Text('No se encontraron preguntas.'));
        return Column(
            children:snapshot.data.map(
                    (pregunta){
                  return Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child:Subpregunta(pregunta,chk)
                  );
                }
            ).toList()
        );
      },
    );
  }

  Future<List> subpreguntasList(subpreguntas) async {
    List lista = [];
    subpreguntas.forEach((k,v){
      v['identificador'] = k;
      lista.add(v);
    });
    return lista;
  }

}

class Subpregunta extends StatelessWidget{

  Map pregunta;
  int cuenta;
  Checklist chk;

  Subpregunta(this.pregunta,this.chk);

  @override
  Widget build(BuildContext context) {
    
    var pregChk= chk.preguntas[pregunta['identificador']];
//    print(pregChk);
//    for(var i in pregChk.keys){
//      print('$i : ${pregChk[i]}');
//    }

    if(pregChk['muestra'] == 0){
      return Container(
        width: 0,
        height: 0,
        padding: EdgeInsets.all(0),
//        child: Text(''),
      );
    }

    var pregText = parseHtmlString('${pregunta['pregunta']}');
    var nomResp = pregChk['nomResp'] == null?'':parseHtmlString('${pregChk['nomResp']}');
    var justificacion = pregChk['justificacion'] == null?'':parseHtmlString('${pregChk['justificacion']}');
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color:Colors.grey,)
          )
      ),
      padding: EdgeInsets.all(10),

      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child:Text(
              pregText,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(''),
          ),
          Expanded(
            flex: 2,
            child: Text('${nomResp}'),
          ),
          Expanded(
            flex: 1,
            child: Text('${justificacion}'),
          )
        ],
      ),
    );
  }
}

String parseHtmlString(String htmlString) {
  htmlString = htmlString == null?'':htmlString;

  var document = parse(htmlString);

  String parsedString = parse(document.body.text).documentElement.text;

  return parsedString;
}
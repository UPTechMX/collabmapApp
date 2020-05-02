import 'package:flutter/material.dart';
import 'package:siap/models/conexiones/api.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HealthPoll extends StatefulWidget {

  var pollId;

  HealthPoll({this.pollId});

  @override
  HealthPollState createState() => HealthPollState();

}

class HealthPollState extends State<HealthPoll> {


  Map respuestas = {};

  @override
  Widget build(BuildContext context) {
    getPregs();
    return FutureBuilder(
      future: getPregs(),
      builder: (context,snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Esperando preguntas');
          case ConnectionState.done:
            if (snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }

            if(snapshot.data.length == 0){
              return Container();
            }

            List elementos = snapshot.data;
            List<Widget> preguntas = [];

            for(int i = 0; i < elementos.length; i++){
              preguntas.add(
                PreguntaHealth(
                  pregunta: elementos[i],
                  setResp: setResp,
                )
              );
            }

            preguntas.add(
              Container(
                padding: EdgeInsets.only(right: 10,bottom: 5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        child: Text('Enviar'),
                        onPressed: () async {

                          SharedPreferences userData = await SharedPreferences.getInstance();
                          String fechaUltimoEnv =  userData.getString('lastDatePoll_${widget.pollId}');
                          DateTime now = DateTime.now();
                          String fechaAct = '${now.year}-${now.month}-${now.day}';

                          print("fechaUltimoEnv: ${fechaUltimoEnv}, fechaAct: $fechaAct");

//                          fechaUltimoEnv = fechaAct;
                          if(fechaAct == fechaUltimoEnv){
                            emergente(context: context,actions: [],content: Text('Esta encuesta sólo puede ser contestada una vez al día'));
                            return;
                          }

                          var pollResponse = await postDatos(
                            opt: 'polls/responses/',
                            verif: true,
                            token: null,
                            datos: {'poll':{'type':'String','name':'poll','value':widget.pollId}},
                            metodo: 'post',
                            imprime: false,
                          );

                          Map<String,dynamic> datosAns = Map();

                          bool envOk = false;
                          for(var i in respuestas.keys){
                            datosAns['question'] = Map();
                            datosAns['question']['name'] = 'question';
                            datosAns['question']['type'] = 'String';
                            datosAns['question']['value'] = '$i';

                            datosAns['response'] = Map();
                            datosAns['response']['name'] = 'response';
                            datosAns['response']['type'] = 'String';
                            datosAns['response']['value'] = '${pollResponse['id']}';

                            datosAns['content'] = Map();
                            datosAns['content']['name'] = 'content';
                            datosAns['content']['type'] = 'String';
                            datosAns['content']['value'] = '${respuestas[i]?1:0}';

                            var pollAnsPost = await postDatos(
                              opt: 'polls/answers/',
                              verif: true,
                              token: null,
                              datos: datosAns,
                              metodo: 'post',
                              imprime: false,
                            );

                            print('pollAnsPost: $pollAnsPost');

                            if(pollAnsPost['id'] != null){
                              envOk = true;
                            }
                          }

                          if(envOk){
                            userData.setString('lastDatePoll_${widget.pollId}', fechaAct);
                          }else{
                            emergente(context: context,actions: [],content: Text('Esta encuesta sólo puede ser contestada una vez al día'));
                          }





                        },
                      ),
                    )

                  ],
                ),
              )
            );
            return Column(
              children: preguntas,
            );

          default:
            return Column();
        }

      },
    );
  }


  getPregs() async {

    List preguntasAPI = await getDatos(opt: 'polls/questions/?poll=${widget.pollId}',varNom: 'polls',imprime: false);

    List preguntas = [];
    for(int i = 0; i<preguntasAPI.length;i++){
      Map preg = Map.from(preguntasAPI[i]);
      if(preg['type'] == 'health'){
        preguntas.add(preg);
      }
    }
//    print(preguntas);
  return preguntas;

  }

  setResp({String llave,bool valor}){
    respuestas[llave] = valor;
  }

}

class PreguntaHealth extends StatefulWidget {

  var pregunta;
  var setResp;
  PreguntaHealth({this.pregunta,this.setResp});

  @override
  PreguntaHealthState createState() => PreguntaHealthState();


}

class PreguntaHealthState extends State<PreguntaHealth> {

  bool activo = false;


  @override
  Widget build(BuildContext context) {
    widget.setResp(
        llave:'${widget.pregunta['id']}',
        valor:activo
    );

    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text('${widget.pregunta['content']}'.toUpperCase()),
          ),
          Expanded(
            flex: 1,
            child: Checkbox(value: activo, onChanged: (a){
              setState(() {
                activo = !activo;
              });
              widget.setResp(
                llave:'${widget.pregunta['id']}',
                valor:activo
              );
            }),
          )
        ],
      ),
    );
  }
}

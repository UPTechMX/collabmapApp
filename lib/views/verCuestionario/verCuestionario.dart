import 'package:flutter/material.dart';
import 'package:siap_monitoring/models/layout/paginaList.dart';
import 'package:siap_monitoring/views/barra.dart';
import 'package:siap_monitoring/views/verCuestionario/cuestionario.dart';



class VerCuestionario extends StatefulWidget{

  int _vId;
  VerCuestionario(this._vId);

  @override
  VerCuestionarioState createState() => VerCuestionarioState(_vId);


}

class VerCuestionarioState extends State<VerCuestionario>{


  int _vId;
  VerCuestionarioState(int vId){
    this._vId = vId;
  }


  @override
  Widget build(BuildContext context) {

    return Pagina(
      drawer: false,
      esLista: false,
      elemento: Cuestionario(_vId),
      botonBack: true,
      sync: true,
      slider: false,
      barraSinBoton: false,
      textoVacio: '',
    );
  }

}
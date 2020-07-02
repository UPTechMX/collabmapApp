import 'package:flutter/material.dart';
import 'package:siap/models/translations.dart';
import 'package:siap/views/barra.dart';
import 'package:siap/views/drawer.dart';
import 'sliderPagina.dart';

class Pagina extends StatefulWidget {

  var elemento;
  String textoVacio;
  var future;
  bool esLista;
  String nombrePagina;
  bool drawer;
  bool slider;
  double sliderHeight;
  bool sync;
  bool botonBack;
  bool barraSinBoton;

  Pagina({
    this.elemento,
    this.textoVacio,
    this.future,
    this.esLista = false,
    this.nombrePagina,
    this.drawer = false,
    this.slider = false,
    this.sliderHeight = 100,
    this.sync = false,
    this.botonBack = true,
    this.barraSinBoton = false,
  });

  @override
  PaginaState createState() => PaginaState();

}

class PaginaState extends State<Pagina> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Barra(
        sync: widget.sync,
        botonBack: widget.botonBack,
        sinBoton: widget.barraSinBoton,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE9E9E9),
                  Color(0xFFFBFBFB),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Image.asset('images/fondo.png')
            ],
          ),
          Container(
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 15),
                  child: widget.nombrePagina != null?
                  Text(
                    widget.nombrePagina,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                  ):
                  Container(),
                ),
                widget.esLista?Lista(
                  future: widget.future,
                  elemento: widget.elemento,
                  textoVacio: widget.textoVacio,
                ):(widget.slider?
                SliderPagina(
                  future: widget.future,
                  elemento: widget.elemento,
                  textoVacio: widget.textoVacio,
                  height: widget.sliderHeight,
                ):
                widget.elemento),
              ],
            ),
          )
        ],
      ),
      drawer: widget.drawer?Opciones():null,
    );
  }
}

class Lista extends StatefulWidget {

  var elemento;
  String textoVacio;
  var future;

  Lista({
    this.elemento,
    this.textoVacio,
    this.future,
  });

  @override
  ListaState createState() => ListaState();

}

class ListaState extends State<Lista> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDatos(),
      builder: (context,snapshot){
        List<Widget> rows = [];
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
            List elementos = snapshot.data;
//            print('DATA : ${snapshot.data}');
            if(snapshot.data.length == 0){
              return Container(
                height: 100,
                child: Center(
                  child: Text(widget.textoVacio),
                ),
              );
            }
            for(int i = 0; i < elementos.length; i++){

//              print(elementos[i]);
              rows.add(widget.elemento(datos: elementos[i],));
            }

            return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: rows,
              ),
            );
          default:
            return Column();
        }

      },
    );
  }

  Future<List> getDatos() async {
    return widget.future;
  }

}


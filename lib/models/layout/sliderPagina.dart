import 'package:flutter/material.dart';
import 'package:siap/models/translations.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SliderPagina extends StatefulWidget {
  var elemento;
  String textoVacio;
  var future;
  double height;
  bool actual;
  Color color;

  SliderPagina({
    this.elemento,
    this.textoVacio,
    this.future,
    this.height,
    this.color,
    this.actual,
  });

  @override
  SliderPaginaState createState() => SliderPaginaState();
}

class SliderPaginaState extends State<SliderPagina> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDatos(),
      builder: (context,snapshot){
        List<Widget> elems = [];
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
            if(snapshot.data.length == 0){
              return Container(
                height: 100,
                child: Center(
                  child: Text(widget.textoVacio),
                ),
              );
            }
            for(int i = 0; i < elementos.length; i++){
              elems.add(widget.elemento(datos: elementos[i],color:widget.color,actual:widget.actual));
            }
            return Column(
              children: <Widget>[
                CarouselSlider(
                  height: widget.height,
                  items: elems,
                  enableInfiniteScroll: false,
                )

              ],
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

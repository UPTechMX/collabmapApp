import 'package:siap/views/drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/views/home/sync.dart';
import 'package:siap/models/componentes/iconos.dart';

class Barra extends StatefulWidget with PreferredSizeWidget{

  bool sync;
  bool botonBack;
  bool sinBoton;

  Barra({this.sync = false, this.botonBack = true, this.sinBoton = false});

  @override
  BarraState createState() => BarraState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

}

class BarraState extends State<Barra>{

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {

    final conectando = Container(
      padding: EdgeInsets.only(top:20,bottom:15,right: 15, left: 15),
      width:50,
      height: 30,
      child: CircularProgressIndicator(
        strokeWidth: 3,
      ),
    );

    return AppBar(
      title:Center(
        child: Image.asset(
          'images/logo.png',
          height: MediaQuery.of(context).size.height*.07,
        ),
      ),
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.grey,
      ),
      leading: widget.sinBoton?Container():
      (widget.botonBack?
      IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
        onPressed: () => Navigator.of(context).pop(),
      ):
      Opciones()),

//      IconButton(
//        icon: Icon(Icons.menu,color: Colors.grey,),
//        onPressed: (){
//          Scaffold.of(context).openDrawer();
////          print('aaa');
////          _selectPopup();
//        },
//      ),

      actions: <Widget>[
        !widget.sync?IconButton(
          icon: Icono(
            svgName: 'sync',
            color: Colors.grey,
            width: 30,
          ),
          onPressed: (){
            Navigator.push(context,
                new MaterialPageRoute(builder: (context)=>
                    Sync(ventana: true,firstSync: false,)
                )
            );
          },
        ):Container(),
      ],
    );
  }



}


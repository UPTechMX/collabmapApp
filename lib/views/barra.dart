import 'package:siap_monitoring/views/consultations/consultationsHome.dart';
import 'package:siap_monitoring/views/drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap_monitoring/views/home/sync.dart';
import 'package:siap_monitoring/models/componentes/iconos.dart';
import 'package:siap_monitoring/models/translations.dart';

import '../main.dart';
import 'locales.dart';

class Barra extends StatefulWidget with PreferredSizeWidget {
  bool sync;
  bool botonBack;
  bool sinBoton;

  Barra({this.sync = false, this.botonBack = true, this.sinBoton = false});

  @override
  BarraState createState() => BarraState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class BarraState extends State<Barra> {
  bool _isLoading = false;

  void _changeLanguage(Language language) {
    Locale _temp;
    _temp = Locale(language.languageCode);
    MyApp.setLocale(context, _temp);
  }

  @override
  Widget build(BuildContext context) {
    final conectando = Container(
      padding: EdgeInsets.only(top: 20, bottom: 15, right: 15, left: 15),
      width: 50,
      height: 30,
      child: CircularProgressIndicator(
        strokeWidth: 3,
      ),
    );

    return AppBar(
      title: Center(
        child: Image.asset(
          'images/icons/chacarita/chacarita.png',
          height: MediaQuery.of(context).size.height * 3,
        ),
      ),
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.grey,
      ),
      leading: widget.sinBoton
          ? Container()
          : (widget.botonBack
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                  //onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  //    builder: (context) => ConsultationsHome())),
                  // onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  //    builder: (context) => targetsHome())),
                )
              : Opciones()),

//      IconButton(
//        icon: Icon(Icons.menu,color: Colors.grey,),
//        onPressed: (){
//          Scaffold.of(context).openDrawer();
////          print('aaa');
////          _selectPopup();
//        },
//      ),

      actions: <Widget>[
        Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<Language>(
            onChanged: (Language language) {
              _changeLanguage(language);
            },
            icon: Icon(Icons.language),
            items: Language.languageList()
                .map<DropdownMenuItem<Language>>(
                    (Language lang) => DropdownMenuItem(
                          value: lang,
                          child: Row(
                            children: <Widget>[Text(lang.name)],
                          ),
                        ))
                .toList(),
            underline: SizedBox(),
          ),
        ),
        !widget.sync
            ? IconButton(
                icon: Icono(
                  svgName: 'sync',
                  color: Colors.grey,
                  width: 30,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => Sync(
                                ventana: true,
                                firstSync: false,
                              )));
                },
              )
            : Container(),
      ],
    );
  }

  /* botonBackCond() async {
    bool logueado;
    SharedPreferences userData = await SharedPreferences.getInstance();
    logueado = userData.getBool('login');
    if (logueado) {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ConsultationsHome())),
        // onPressed: () => Navigator.of(context).push(MaterialPageRoute(
        //    builder: (context) => targetsHome())),
      );
    } else {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
        onPressed: () => Navigator.of(context).pop(),
      );
    }
  } */
}

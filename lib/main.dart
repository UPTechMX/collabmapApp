import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'views/home/home.dart';
import 'views/login/login.dart';
import 'views/home/privacidad.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/translations.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget{
  static void setLocale(BuildContext context, Locale locale) {
    _MyApp state = context.findAncestorStateOfType<_MyApp>();
    state.setLocale(locale);
  }

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp>{
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
  @override
  void initState() {
    super.initState();
  }


  final routes = <String,WidgetBuilder>{
    'login': (context) => Login(),
    'home' : (context) => Home(),
    'priv' : (context) => Privacidad(),
  };

  bool _logueado = false;
  bool _firstSync = false;
  bool _aceptaPriv = false;
  int _nivel = 0;

  void recuperaDatos() async {
    SharedPreferences userData = await SharedPreferences.getInstance();
    bool firstSync;
    bool logueado;
    bool aceptaPriv;
    int nivel;
    if(userData.getBool('login') != null){

      logueado = userData.getBool('login');
      nivel = userData.getInt('nivel');
      firstSync = userData.getBool('firstSync') == null?false:userData.getBool('firstSync');
      aceptaPriv = userData.getBool('aceptaPriv') == null?false:userData.getBool('aceptaPriv');
    }else{
      logueado = false;
    }

    if(logueado){
      _aceptaPriv = aceptaPriv;
      if(!_logueado){
//        print('bbb');
        setState(() {
          _logueado = true;
          _nivel = nivel;
          _firstSync = firstSync;

        });
      }
    }else{
//      print('NO LOGUEADO');
    }
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    recuperaDatos();

    const List locales = ['en','es'];
    List<Locale> supportedLocales = [];
    for(int i = 0; i<locales.length;i++){
      supportedLocales.add(Locale(locales[i],''));
    }

    return MaterialApp(
      title: 'CollabMap',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        const TranslationsDelegate(locales: locales),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      home: _logueado?Home(firstSync: _firstSync,aceptaPriv: _aceptaPriv,):Login(),
      routes:routes,
      locale: _locale,
    );
  }

}

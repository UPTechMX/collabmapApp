import 'package:flutter/material.dart';
import 'package:siap/views/login/conexion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/models/translations.dart';
import 'registro.dart';

class Login extends StatefulWidget{
  static String tag = 'login-page';

  @override
  _Login createState() => _Login();

}

class _Login extends State<Login>{

  bool _isLoading = false;
  var _datosLogin = <String,TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _Login(){
    _datosLogin['username'] = TextEditingController();
    _datosLogin['password'] = TextEditingController();
  }

  _loadUserData() async {
    SharedPreferences userData = await SharedPreferences.getInstance();
  }

  void recuperaDatos() async {
    SharedPreferences userData = await SharedPreferences.getInstance();
    bool logueado;
    if(userData.getBool('login') != null){
      logueado = userData.getBool('login')?true:false;
    }else{
      logueado = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    recuperaDatos();

    void _submit() async{

      if(_datosLogin['username'].text != '' && _datosLogin['password'].text != ''){
//        debugPrint(_datos['username'].text);
//        debugPrint(_datos['password'].text);

        setState(() => _isLoading = true);

        Post resp = await loginPost(_datosLogin['username'].text,_datosLogin['password'].text);
//        print('aca');
//        print(resp);
//        print(resp.nombre);

        SharedPreferences userData = await SharedPreferences.getInstance();

        if(resp.token != null){
          print('Token: ${resp.token}');
          userData.setBool('login', true);
          userData.setString('token', resp.token);
          userData.setString('username', _datosLogin['username'].text);
          userData.setString('password', _datosLogin['password'].text);
          userData.setInt('userId', resp.userId);
          userData.setString('name', resp.name);

          Navigator.pushReplacementNamed(context, 'home');
//          Navigator.of(context).pushNamed('home');
        }else{
          userData.setString('username',null);
          userData.setString('password',null);
          userData.setBool('login', false);
          userData.setBool('token', null);
          userData.remove('userId');

          setState(() => _isLoading = false);
        }

      }else{
        debugPrint('Debes poner usuario y contraseña');
      }

    }
    
    final usuario = TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      controller: _datosLogin['username'],

      decoration: InputDecoration(
        hintText: Translations.of(context).text("username"),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
        border: OutlineInputBorder(
          borderSide: new BorderSide(color: Color(0xFF2568D8),width: 10),
          borderRadius: new BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: new BorderSide(color: Color(0xFF2568D8),width: 2),
          borderRadius: new BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: new BorderSide(color: Color(0xFF2568D8),width: 2),
          borderRadius: new BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white
      ),
    );

    final password = TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      obscureText: true,
      controller: _datosLogin['password'],
      decoration: InputDecoration(
        hintText: Translations.of(context).text("password"),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
        border: OutlineInputBorder(
          borderSide: new BorderSide(color: Color(0xFF2568D8),width: 10),
          borderRadius: new BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: new BorderSide(color: Color(0xFF2568D8),width: 2),
          borderRadius: new BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: new BorderSide(color: Color(0xFF2568D8),width: 2),
          borderRadius: new BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white
      ),
    );

    final loginButton = Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: ButtonTheme(
            minWidth: 150.0,
            height: 40.0,
            buttonColor: Color(0xFF2568D8),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              onPressed: _submit,
              child: Text(Translations.of(context).text("log_in"), style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: FlatButton(
            onPressed: (){
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context)=>Registro()
                  ));

            },
//            color: Colors.lightBlueAccent,
            child: Text(Translations.of(context).text("sign_up"), style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );

    final conectando = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
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
              Image.asset('images/login2.png')
            ],
          ),
          Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).padding.top ),
                Image.asset('images/login1.png')
              ],
            ),
          ),
          Center(
              child:ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0,right:24.0),
                children: <Widget>[
//                  SizedBox(height: MediaQuery.of(context).padding.top ),
//                  Image.asset('images/login1.png'),
//                  SizedBox(height: 15),
//                  SizedBox(height: MediaQuery.of(context).size.width+10),
                  SizedBox(height: MediaQuery.of(context).size.height * .58),
                  usuario,
                  SizedBox(height: 20.0),
                  password,
                  SizedBox(height: 20.0),
                  _isLoading?conectando:loginButton,
//            loginButton,
                ],
              )
          ),
        ],
      )
    );
  }


}
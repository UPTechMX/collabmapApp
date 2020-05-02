import 'package:flutter/material.dart';
import 'package:siap/views/barra.dart';
import 'package:siap/models/translations.dart';
import 'package:siap/models/conexiones/api.dart';
import 'package:siap/models/layout/paginaList.dart';
import 'package:siap/views/home/privacidad.dart';

class Registro extends StatefulWidget {
  @override
  RegistroState createState() => RegistroState();
}

class RegistroState extends State<Registro> {

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  String usernameChange;
  String emailChange;
  String firstnameChange;
  String lastnameChange;
  String passwordChange;
  String ageChange;
  var genderSel;
  bool privacidad = false;

  @override
  Widget build(BuildContext context) {

    List genders = [
      {'value':'female','name':Translations.of(context).text('female')},
      {'value':'male','name':Translations.of(context).text('male')},
      {'value':'x','name':Translations.of(context).text('prefer_not_answer')}
    ];
    List items = new List<DropdownMenuItem>();

    for(int i = 0;i<genders.length;i++){
      var gender = genders[i];
      var item = DropdownMenuItem(
        child: Text(
          gender['name'],
          style: TextStyle(fontSize: 14),
        ),
        value: gender['value'],
      );
//      print(cat['id']);
      items.add(item);
    }

    Widget genderSelector = DropdownButtonFormField(
      items: items,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
        isDense: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0)
        )
      ),
      value: genderSel,
      hint: Text(Translations.of(context).text('gender')),
      onChanged: (value){
        setState(() {
          genderSel = value;
        });
      },
    );

    Future<void> Alert({BuildContext context,String texto}) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
//          title: Text('Point alert'),
            content: SingleChildScrollView(
              child: Center(
                child: Text(texto),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(Translations.of(context).text('ok')),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


    return Pagina(
      esLista: false,
      sync: true,
      elemento: Container(
        padding: EdgeInsets.all(15),
        child: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white.withAlpha(200),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                color: Color(0xFF2568D8),
                child: Center(
                  child: Text(
                    Translations.of(context).text('new_user').toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                padding: EdgeInsets.all(15),
                child: Center(
                  child: Text(
                    Translations.of(context).text('generaldata').toUpperCase(),
                    style: TextStyle(
//                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              TextField(
                controller: emailController,
                onChanged: (text){
                  emailChange = text;
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    hintText: Translations.of(context).text("email"),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: firstnameController,
                onChanged: (text){
                  firstnameChange = text;
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    hintText: Translations.of(context).text("first_name"),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: lastnameController,
                onChanged: (text){
                  lastnameChange = text;
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    hintText: Translations.of(context).text("last_name"),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
              SizedBox(height: 20.0),
              genderSelector,
              SizedBox(height: 20.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: ageController,
                onChanged: (text){
                  ageChange = text;
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    hintText: Translations.of(context).text("age"),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                padding: EdgeInsets.all(15),
                child: Center(
                  child: Text(
                    Translations.of(context).text('userdata').toUpperCase(),
                    style: TextStyle(
//                      fontSize: 25,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              TextField(
                controller: usernameController,
                onChanged: (text){
                  usernameChange = text;
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: Translations.of(context).text("username"),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: passwordController,
                onChanged: (text){
                  passwordChange = text;
                },
                obscureText: true,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    hintText: Translations.of(context).text("password"),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),

              SizedBox(height: 20.0),
              PrivCheckReg(setPriv: setPriv,),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  onPressed: ()async{
                    bool allOk = true;
                    if(usernameChange == null || usernameChange == ''){
                      allOk = false;
                    }
                    if(emailChange == null || emailChange == ''){
                      allOk = false;
                    }
                    if(firstnameChange == null || firstnameChange == ''){
                      allOk = false;
                    }
                    if(lastnameChange == null || lastnameChange == ''){
                      allOk = false;
                    }
                    if(passwordChange == null || passwordChange == ''){
                      allOk = false;
                    }
                    if(ageChange == null || ageChange == ''){
//                    allOk = false;
                      ageChange = '0';
                    }
                    if(genderSel == null || genderSel == ''){
//                    allOk = false;
                      genderSel = 'X';
                    }
                    if(privacidad == false){
                      allOk = false;
                    }

//                  print('allOk : $allOk');
                    if(allOk){
                      Map datos = Map();
                      datos['username'] = generaDatoString(name: 'username',value: usernameChange);
                      datos['email'] = generaDatoString(name: 'email',value: emailChange);
                      datos['firstname'] = generaDatoString(name: 'first_name',value: firstnameChange);
                      datos['lastname'] = generaDatoString(name: 'last_name',value: lastnameChange);
                      datos['password'] = generaDatoString(name: 'password',value: passwordChange);
                      datos['age'] = generaDatoString(name: 'age',value: ageChange);
                      datos['gender'] = generaDatoString(name: 'gender',value: genderSel);

                      var resp = await postDatos(
                        datos: datos,
                        opt: 'profile/',
                        metodo: 'POST',
                        imprime: true,
                      );
//                    print(resp);
                      if(resp != null && resp['id'] != null){
                        Navigator.of(context).pop();
//                      Alert(texto: Translations.of(context).text('user_created'));
                      }else{
                        String errors = '';
                        for(var i in resp.keys){
                          for(int j = 0;j<resp[i].length;j++){
                            errors = '$errors ${resp[i][j]} \n';
                          }
                        }
                        Alert(context: context,texto: errors);
                      }
                    }
                  },
                  padding: EdgeInsets.all(12),
                  color: Colors.lightBlueAccent,
                  child: Text(Translations.of(context).text("send"), style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  setPriv(bool a){
    print('a: $a');
    privacidad = a;
  }

}

class PrivCheckReg extends StatefulWidget {

  var setPriv;

  PrivCheckReg({this.setPriv});

  @override
  _PrivCheckRegState createState() => _PrivCheckRegState();
}

class _PrivCheckRegState extends State<PrivCheckReg> {

  bool activo = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    value: activo,
                    onChanged: (a){
                      widget.setPriv(a);
                      setState(() {
                        activo = a;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: FlatButton(
                    child: Text(
                      Translations.of(context).text('noticeofprivacyAgree').toUpperCase(),
                      style: TextStyle(
                        color: Color(0xFF2568D8),
                      ),
                    ),
                    onPressed: (){
                      Navigator.push(context,
                          new MaterialPageRoute(builder: (context)=>
                              Privacidad()
                          )
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        )
    );
  }



}
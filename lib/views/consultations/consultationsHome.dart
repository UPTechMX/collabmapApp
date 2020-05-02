import 'package:siap/models/componentes/iconos.dart';
import 'package:flutter/material.dart';
import 'package:siap/models/layout/paginaList.dart';
import 'tarjetaConsultation.dart';
import 'package:siap/models/translations.dart';
import 'package:siap/models/conexiones/DB.dart';
import 'package:siap/models/layout/sliderPagina.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:strings/strings.dart';
import 'consultationInfo.dart';


class ConsultationsHome extends StatefulWidget {

  @override
  ConsultationsHomeState createState() => ConsultationsHomeState();
}

class ConsultationsHomeState extends State<ConsultationsHome> {

  var filterPhase;
  var filterCode;
  var filterKeyword;

  TextEditingController controllerCode = TextEditingController();
  TextEditingController controllerKeyword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Pagina(
      textoVacio: Translations.of(context).text('empty'),
      future: (){},
      nombrePagina: null,
      drawer: false,
      esLista: false,
      slider: false,
      sliderHeight: MediaQuery.of(context).size.height*.27,
      elemento: elemento(),
      botonBack: false,
    );
  }

  Future<List> getData({String periodo = '1',bool actual = true}) async {

    DB db = DB.instance;

    String wherePhase = filterPhase == null ? '' : ' AND phase_id = $filterPhase ';
    String whereCode = (filterCode == null || filterCode == '') ? '' : ' AND c.slug LIKE "$filterCode" ';
    String whereKeyword = (filterKeyword == null || filterKeyword == '') ? '' : ' AND c.name LIKE "%${filterKeyword}%" ';

    String sql = '''
      SELECT c.*, '$actual' as actual, p.name as pName 
      FROM consultations c
      LEFT JOIN phases p ON p.id = c.phase_id 
      WHERE $periodo $wherePhase $whereCode $whereKeyword
     ''';

//    print('SQL: $sql');

    List datosDB = await db.query(sql);
    datosDB ??= [];

    List datos = [];



//    print('LENGTH: ${datos.length}');

    for(int i = 0; i<datosDB.length;i++){
//      print('I: $i : ${datos[i]['id']}');
      var polls = await db.query("SELECT * FROM polls WHERE consultation_id = ${datosDB[i]['id']}");
      polls ??= [];

      Map consulta = Map.from(datosDB[i]);

      List pollsEdt = [];
      for(int j = 0; j<polls.length;j++){
        Map pollEdt = Map.from(polls[j]);
//        print('pollId = ${polls[j]['id']}');
        List pollQuestions = await db.query("SELECT * FROM pollsQuestions WHERE poll_id = ${polls[j]['id']}");
        pollQuestions ??= [];
        pollEdt['questions'] = pollQuestions;
        pollsEdt.add(pollEdt);
      }

      consulta['poll'] = pollsEdt.length == 0?{}:pollsEdt[0];
//      print('= = = = = = POLL = = = == =');
//      print(consulta['poll']);


      datos.add(consulta);
    }

    return datos;
  }


  slider({
    String nombre,
    String periodo,
    bool actual = true,
    Color color,
  }){
    return Container(
      padding: EdgeInsets.only(top:15),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .018,),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height*.32,
              decoration: BoxDecoration(
                color: color.withAlpha(41),
                border: Border(
                  top: BorderSide(
                    color: color,
                    width: 3.0,
                  ),
                  bottom: BorderSide(
                    color: color,
                    width: 3.0,
                  ),
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(top:20),
                child: SliderPagina(
                  actual: actual,
                  future: getData(
                    periodo: periodo,
                    actual: actual,
                  ),
                  elemento: consultation,
                  color: color,
                  height: MediaQuery.of(context).size.height*.26,
                  textoVacio: Translations.of(context).text('empty'),
                ),
              ),
            ),
          ),
          Stack(
            children: <Widget>[
              Image.asset(
                'images/flecha.png',
                color: color,
                height: MediaQuery.of(context).size.height * .04,
              ),
              Container(
                padding: EdgeInsets.only(top:MediaQuery.of(context).size.height * .006),
                child: Row(
                  children: <Widget>[
                    Container(
//                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * .02),
                      child: Html(
                        data: nombre,
                        defaultTextStyle: TextStyle(color: Colors.white),
                        useRichText: true,
                        linkStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  elemento(){
    DateTime now = DateTime.now();
    String fechaHoy = '${DateFormat("yyyy-MM-dd").format(now)}';

    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            botonFiltros(),
            slider(
              nombre: '${Translations.of(context).text('ongoingConsultations').toUpperCase()}',
              periodo: "(start_date <= '$fechaHoy' AND finish_date >= '$fechaHoy' )",
              actual: true,
              color: Color(0xFF2568D8),
            ),
            slider(
              nombre: '  ${Translations.of(context).text('futureConsultations').toUpperCase()}',
              periodo: "(start_date >= '$fechaHoy')",
              actual: false,
              color: Color(0xFFA27AE4),
            ),
            slider(
              nombre: '  ${Translations.of(context).text('pastConsultations').toUpperCase()}',
              periodo: "(finish_date < '$fechaHoy')",
              actual: false,
              color: Color(0xFF848484),
            ),
          ],
        )
      ],
    );
  }

  consultation({var datos,Color color, bool actual = true}){
//    print('Color $color');

    // ToDo: Esperar a que nos manden el ícono y ponerlo en la lina de abajo
    String iconNom = datos['icon'];
    iconNom = iconNom.replaceAll('-', ' ');
    iconNom = camelize(iconNom);
    iconNom = iconNom.replaceAll(' ', '');
    iconNom = '${iconNom[0].toLowerCase()}${iconNom.substring(1)}';
//    print(iconNom);

    var icon = Container(
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*.044,top: MediaQuery.of(context).size.width*.035),
      child: Icon(
        FA.icono[iconNom],
        size: MediaQuery.of(context).size.width*.10,
        color: color,
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: FlatButton(
        padding: EdgeInsets.all(0),
//        color: Color(0xFFd9e4f7),
        onPressed: (){
          Navigator.push(context,
              new MaterialPageRoute(builder: (context)=>
                  ConsultationInfo(
                    datos: datos,
                    color: color,
                    actual: actual,
                  )
              )
          );
        },
        child: TarjetaConsultation(datos: datos,color: color,icon: icon,),
      ),
    );
  }

  botonFiltros(){
    return Container(
      child: SizedBox(
        width: MediaQuery.of(context).size.width *.40,
        child: ButtonTheme(
          minWidth: 150.0,
          height: 40.0,
          buttonColor: Colors.white,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color:Color(0xFF818181)),
            ),
            onPressed: (){
              filtros(context: context);
            },
            child: Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Icono(
                        svgName: 'filtro',
                        color: Color(0xFF818181),
                        width: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        ' ${Translations.of(context).text('filter').toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff818181),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> filtros({BuildContext context,String texto}) async {

    DB db = DB.instance;

    List phases = await db.query("SELECT * FROM phases");
    var phaseSel = filterPhase;
    var code = filterCode;
    var keyword = filterKeyword;

    varSel(var valor){
      phaseSel = valor;
    }

    varCode(var valor){
      code = valor;
    }

    varKeyword(var valor){
      keyword = valor;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
//          title: Text('Point alert'),
          content: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Text(
                    Translations.of(context).text('filters').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF818181)
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    Translations.of(context).text('phase').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA27AE4)
                    ),
                  ),
                  DropPhases(
                    phases: phases,
                    selected: filterPhase,
                    cambiaSel: varSel,
                  ),
                  SizedBox(height: 10,),
                  Text(
                    Translations.of(context).text('code').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA27AE4)
                    ),
                  ),
                  CampoTexto(
                    value: code,
                    fncCambio: varCode,
                    controller: controllerCode,
                  ),
                  SizedBox(height: 10,),
                  Text(
                    Translations.of(context).text('keyword').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA27AE4)
                    ),
                  ),
                  CampoTexto(
                    value: code,
                    fncCambio: varKeyword,
                    controller: controllerKeyword,
                  ),

                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(Translations.of(context).text('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
//                print('PhaseSel: $phaseSel, code: $code, keyword: $keyword');
              },
            ),
            FlatButton(
              child: Text(Translations.of(context).text('filter')),
              onPressed: () {
                setState(() {
                  filterPhase = phaseSel;
                  filterCode = code;
                  filterKeyword = keyword;
                });
                Navigator.of(context).pop();
                print('PhaseSel: $phaseSel, code: $code, keyword: $keyword');
              },
            ),
          ],
        );
      },
    );
  }



}

class DropPhases extends StatefulWidget {
  List phases;
  var selected;
  var cambiaSel;

  DropPhases({this.phases,this.selected = null, this.cambiaSel});

  @override
  DropPhasesState createState() => DropPhasesState(selected: selected);
}

class DropPhasesState extends State<DropPhases> {

  var selected;
  DropPhasesState({this.selected = null});
  @override

  Widget build(BuildContext context) {
    List phases = widget.phases;
    List items = new List<DropdownMenuItem>();

    items.add(
      DropdownMenuItem(
        child: Text(
          Translations.of(context).text('none'),
          style: TextStyle(fontSize: 14),
        ),
        value: null,
      )
    );

    for(int i = 0;i<phases.length;i++){
      var phase = phases[i];
      var item = DropdownMenuItem(
        child: Text(
          phase['name'],
          style: TextStyle(fontSize: 14),
        ),
        value: phase['id'],
      );
      //      print(cat['id']);
      items.add(item);
    }

    return DropdownButtonFormField(
      items: items,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(5.0, 00, 5.0, 0),
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
      value: selected,
      hint: Text(Translations.of(context).text('select')),
      onChanged: (value){
        setState(() {
          selected = value;
        });
        widget.cambiaSel(value);
      },
    );
  }

}

class CampoTexto extends StatelessWidget {

  String value;
  var fncCambio;
  TextEditingController controller;

  CampoTexto({this.value,this.fncCambio,this.controller});


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      autofocus: false,
      obscureText: false,
      controller: controller,
      onChanged: (value){
        fncCambio(value);
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
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
  }
}



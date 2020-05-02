import 'package:flutter/material.dart';
import 'package:siap/models/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siap/models/translations.dart';

class SendProblems extends StatefulWidget {

  @override
  SendProblemsState createState() => SendProblemsState();
}

class SendProblemsState extends State<SendProblems> {

  var selected = "";


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[350]),
            padding: EdgeInsets.all(15),
            child: Text(
              Translations.of(context).text('sync_data'),
              style:TextStyle(),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(),
            padding: EdgeInsets.all(15),
            child: SendTypeSel(context: context,),
          ),
        ],
      ),
    );

  }
}

class SendTypeSel extends StatefulWidget {

  List<DropdownMenuItem> items;
  BuildContext context;


  SendTypeSel({this.context}){
    items = [];
    items.add(
        DropdownMenuItem(
          child: Text(
            Translations.of(context).text('always'),
            style: TextStyle(fontSize: 14),
          ),
          value: "always",
        )
    );
    items.add(
        DropdownMenuItem(
          child: Text(
            Translations.of(context).text('wifi_only'),
            style: TextStyle(fontSize: 14),
          ),
          value: "wifi",
        )
    );
    items.add(
        DropdownMenuItem(
          child: Text(
            Translations.of(context).text('manual'),
            style: TextStyle(fontSize: 14),
          ),
          value: "manual",
        )
    );

  }

  @override
  SendTypeSelState createState() => SendTypeSelState(items: items);
}

class SendTypeSelState extends State<SendTypeSel> {

  var selected;
  List<DropdownMenuItem> items;

  SendTypeSelState({this.items});

  @override
  initState() {
    super.initState();
    SharedPreferences.getInstance().then((res) {
      selected = res.getString("sendProblems");
//      print(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (context,snapshot){

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
            return DropdownButton(
              items: items,
              value: selected,
              hint: Text(Translations.of(context).text('select')),
              onChanged: (value){
                setState(() {
                  SharedPreferences.getInstance().then((sp){
                    sp.setString('sendProblems', value);
                  });
                  selected = value;
                });
              },
            );
        }
        return Column();
      },
    );
  }

  getData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    selected = sp.getString('sendProblems');
    return sp.getString('sendProblems');
  }
}


import 'package:flutter/material.dart';
import 'package:siap_monitoring/views/barra.dart';
import 'package:siap_monitoring/models/translations.dart';
import 'package:siap_monitoring/views/configuration/settings/sendProblems.dart';

class Settings extends StatefulWidget {

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Barra(),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            child: Text(
              Translations.of(context).text('settings'),
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          SendProblems(),
        ],
      ),
    );
  }
}

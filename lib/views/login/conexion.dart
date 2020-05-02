import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siap/models/conexiones/api.dart';

Future<Post> loginPost(String username,String password) async {
  String url;
  var response;
  bool error = false;
  try{
    url = '${SERVER}users/login/';
    print('asasas: $url');
    response = await http.post(url,body:{'username':username,'pwd':password});
  }catch(e){
    error = true;
  }
//  print('aaa');
//  print(response);
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
//    print('Inicia respuesta del server');
//    print(response.body);
//    print('Finaliza respuesta del server');
//
//    print(response.body);
    return Post.fromJson(json.decode(response.body));
  } else {

//    print('Inicia respuesta del server Err');
//    print(response.body);
//    print('Finaliza respuesta del server Err');
    return Post.fromJson(json.decode(response.body));
//    print('bbb');
    // If that call was not successful, throw an error.
//    throw Exception('Failed to load post');
  }
}

class Post {
  final String token;
  final String name;
  final int userId;

  Post({this.token,this.userId,this.name});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      token: json['token'],
      userId: json['usrId'],
      name: json['name']
    );
  }
}


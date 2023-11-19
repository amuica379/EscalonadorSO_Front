// ignore_for_file: file_names

import 'package:http/http.dart' as http;

Future<http.Response>httpTest(){
  return http.get(Uri(path: 'localhost:7778/teste/${15}'));
}

Future<String> tratarResposta () async {
  final teste= await httpTest();
  return teste.body;
}
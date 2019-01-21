import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Watson {
  String eu;
  String watson;
  int statusCode;
  String data;

  Watson({this.eu, this.watson, this.statusCode, this.data});

  factory Watson.fromJson(Map<String, dynamic> parsedJson) {
    return Watson(
        eu: parsedJson['eu'],
        watson: parsedJson['watson'] as String,
        statusCode: parsedJson['statusCode'],
        data: parsedJson['data']);
  }

  static Future<String> call(String userMsg) async {
    final url = 'http://192.168.1.10:3001/watson';
    Map<String, String> headers = {'Accept': 'application/json'};
    Map<String, String> body = {'message': userMsg};

    final response = await http.post(url, headers: headers, body: body);
    final _finalRes = Watson.fromJson(json.decode(response.body));
    return _finalRes.watson;
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiService {
  static late WebSocketChannel channel;
  static String ip = "";
  //connect
  static void connect() async {
    channel = WebSocketChannel.connect(
      Uri.parse("ws://$ip/WebSocketHandler.ashx"),
    );

    channel.sink
        .add(jsonEncode({"type": "SetSocketType", "content": "Player"}));
  }

//get
  static Future getTeams() async {
    final teams = Uri.parse("http://$ip/Home/GetActiveTeams");
    final response = await http.get(teams);
    return json.decode(response.body);
  }

//get
  static Future CheckUser(String name, String pass) async {
    final letter = Uri.parse("http://$ip/Home/CheckUser");
    final response =
        await http.post(letter, body: {"teamName": name, "password": pass});
    return json.decode(response.body);
  }
}

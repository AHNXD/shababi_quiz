// ignore_for_file: use_build_context_synchronously, no_logic_in_create_state, non_constant_identifier_names
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shababi_quiz/Pages/gameScreen.dart';
import 'package:shababi_quiz/services/apiService.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});
  static String id = "/Teams";
  static var teams = [];

  @override
  State<TeamsScreen> createState() => _TeamsScreenState(teams);
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TextEditingController _controller = TextEditingController();
  static var Teams = [];
  _TeamsScreenState(var teamsInfo) {
    Teams = teamsInfo;
  }

  void massege(String error, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: c,
      content: Center(child: Text(error)),
      duration: const Duration(seconds: 2),
    ));
  }

  toColor(String c) {
    var hexString = c;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Widget refreshButton() {
    return IconButton(
        onPressed: () async {
          try {
            massege("loading...", Colors.amber);
            Teams = await ApiService.getTeams();
            massege("done", Colors.green);
          } catch (e) {
            massege("Check your IP", Colors.red);
            return;
          }
          await Future.delayed(
              const Duration(milliseconds: 200), () => setState(() {}));
          setState(() {});
        },
        icon: const Icon(Icons.refresh));
  }

  void checkPass(int index) async {
    if (await ApiService.CheckUser(Teams[index]['name'], _controller.text)) {
      ApiService.connect();
      await Future.delayed(const Duration(milliseconds: 200));
      massege("done", Colors.green);
      _controller.text = "";
      GameScreen.Team = Teams[index];
      ApiService.channel.sink.add(
          jsonEncode({"type": "Team", "content": "${Teams[index]['id']}"}));
      Navigator.pop(context);
      Navigator.pushNamed(context, GameScreen.id);
    } else {
      massege("Check the password", Colors.red);
    }
  }

  dynamic passCheckDialog(int index) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                "Password:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 35),
              ),
              content: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: TextFormField(
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (value) {
                    checkPass(index);
                  },
                  maxLength: 50,
                  controller: _controller,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.amber),
                    labelText: "Password",
                    hintText: "Enter the password",
                    prefixIcon: const Icon(
                      Icons.numbers,
                      color: Colors.amber,
                    ),
                    fillColor: Colors.amber,
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(25)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    checkPass(index);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.all(20),
                      elevation: 20,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)))),
                  child: const Icon(Icons.check),
                )
              ],
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ));
  }

  Widget teamButton(int index) {
    return Container(
      padding: const EdgeInsets.all(5),
      height: 180,
      width: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            side: BorderSide(width: 5, color: toColor(Teams[index]['color'])),
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            padding: const EdgeInsets.all(10),
            elevation: 20,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(60)))),
        onPressed: () async {
          passCheckDialog(index);
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SvgPicture.network(
                "http://${ApiService.ip}/${Teams[index]['logo']}",
                height: 100,
                width: 100,
              ),
              Text(
                Teams[index]['name'],
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: toColor(Teams[index]['color'])),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [refreshButton()],
        backgroundColor: Colors.amber,
        title: const Text(
          "Teams",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListView.builder(
              itemCount: Teams.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return teamButton(index);
              }),
        ],
      ),
    );
  }
}

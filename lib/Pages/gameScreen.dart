// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, no_logic_in_create_state

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/apiService.dart';

class GameScreen extends StatefulWidget {
  static String id = "/game";
  static var Team;

  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState(Team);
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  var team;
  var content;
  _GameScreenState(var info) {
    team = info;
  }

  void massege(String error, Color c) async {
    await Future.delayed(const Duration(microseconds: 500));
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: c,
      content: Center(child: Text(error)),
      duration: const Duration(seconds: 2),
    ));
  }

  Widget grid() {
    if (content['type'] == "Identify") {
      massege("${content['content']}", toColor(team['color']));
      return Container();
    }
    return content['content'].length == 0
        ? Container()
        : SizedBox(
            height: content['type'] == "QuestionsNumbers" ? 250 : 300,
            width: double.infinity,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: GridView.builder(
                  itemCount: content['content'].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio:
                        content['type'] == "QuestionsNumbers" ? 2.5 : 3,
                    crossAxisCount:
                        content['type'] == "QuestionsNumbers" ? 4 : 2,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            side: BorderSide(
                                width: content['type'] == "QuestionsNumbers"
                                    ? 2.5
                                    : 5,
                                color: Colors.black),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            backgroundColor:
                                content['type'] == "QuestionsNumbers"
                                    ? Colors.amber
                                    : toColor(team['color'])),
                        child: content['type'] == "QuestionsNumbers"
                            ? Text(
                                "${content['content'][index]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25),
                              )
                            : Text(
                                content['content'][index] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                        onPressed: () {
                          content['type'] == "QuestionsNumbers"
                              ? ApiService.channel.sink.add(jsonEncode({
                                  "type": "QuickAnswer",
                                  "content": content['content'][index]
                                }))
                              : ApiService.channel.sink.add(jsonEncode({
                                  "type": "QuickAnswer",
                                  "content": "${content['content'][index]}"
                                }));
                        },
                      ),
                    );
                  }),
            ),
          );
  }

  toColor(String c) {
    var hexString = c;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  void dispose() {
    super.dispose();
    ApiService.channel.sink.add(jsonEncode({"type": "Team"}));
    ApiService.channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: toColor(team['color']),
        title: Text(
          team['name'],
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(children: [
            const SizedBox(
              height: 10,
            ),
            SvgPicture.network(
              "http://${ApiService.ip}/${team['logo']}",
              height: 200,
              width: 200,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextFormField(
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (value) {
                  if (_controller.text != "") {
                    ApiService.channel.sink.add(jsonEncode(
                        {"type": "QuickAnswer", "content": _controller.text}));
                  } else {
                    massege("Enter any thing to send", Colors.red);
                  }
                  setState(() {});
                },
                maxLength: 50,
                controller: _controller,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: toColor(team['color'])),
                  labelText: "Answer",
                  hintText: "Enter the answer",
                  prefixIcon: Icon(
                    Icons.abc_outlined,
                    color: toColor(team['color']),
                  ),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _controller.text = "";
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        color: toColor(team['color']),
                      )),
                  fillColor: toColor(team['color']),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(25)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: toColor(team['color']), width: 2),
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text != "") {
                  ApiService.channel.sink.add(jsonEncode(
                      {"type": "QuickAnswer", "content": _controller.text}));
                } else {
                  massege("Enter any thing to send", Colors.red);
                }
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: toColor(team['color'])),
              child: const Icon(Icons.send),
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(color: toColor(team['color'])),
            StreamBuilder(
              stream: ApiService.channel.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data as String == "ping") {
                    ApiService.channel.sink.add(jsonEncode("pong"));
                    massege("ping<-", toColor(team['color']));
                    massege("pong->", toColor(team['color']));
                  } else {
                    try {
                      content = json.decode(snapshot.data);
                      content['content'] = json.decode(content['content']);
                    } catch (e) {
                      massege(e.toString(), Colors.red);
                    }
                  }
                  return Container(child: grid());
                } else {
                  return Container();
                }
              },
            ),
            Divider(color: toColor(team['color'])),
          ]),
        ),
      ),
    );
  }
}

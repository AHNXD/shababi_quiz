import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shababi_quiz/Pages/CamScanner.dart';
import 'package:shababi_quiz/Pages/Teams.dart';
import 'package:shababi_quiz/Pages/gameScreen.dart';
import 'package:shababi_quiz/services/apiService.dart';
import 'package:shababi_quiz/Pages/settings.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static String id = "/home";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void massege(String error, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: c,
      content: Center(child: Text(error)),
      duration: const Duration(seconds: 1),
    ));
  }

  Future<void> _retrieveIp() async {
    final prefs = await SharedPreferences.getInstance();
    // Check where the Ip is saved before or not
    if (!prefs.containsKey('ip')) {
      return;
    }
    setState(() {
      ApiService.ip = prefs.getString('ip')!;
    });
  }

  @override
  void initState() {
    super.initState();
    _retrieveIp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, Settings.id);
                },
                icon: const Icon(Icons.settings))
          ],
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "Shababi Quiz",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 94, 79, 12),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  child: Image.asset(
                    "assets/images/logo.png",
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: const BorderSide(color: Colors.black, width: 2),
                          backgroundColor: Colors.amber,
                          elevation: 20,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)))),
                      onPressed: () async {
                        try {
                          if (ApiService.ip != "") {
                            massege("loading...", Colors.amber);
                            TeamsScreen.teams = await ApiService.getTeams();
                            massege("done", Colors.green);
                            Navigator.pushNamed(context, TeamsScreen.id);
                          }
                        } catch (e) {
                          massege("Check your IP", Colors.red);
                        }
                      },
                      child: Text(
                        "Teams",
                        style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: const BorderSide(color: Colors.black, width: 2),
                          backgroundColor: Colors.amber,
                          elevation: 20,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)))),
                      onPressed: () async {
                        var id =
                            await Navigator.pushNamed(context, CamScanner.id)
                                as String;
                        if (id != "") {
                          String realId = "";
                          bool flag = false;
                          for (int i = 0; i < id.length; i++) {
                            if (flag) {
                              realId += id[i];
                            }
                            if (id[i] == "=") {
                              flag = true;
                            }
                          }
                          var teams;
                          try {
                            if (ApiService.ip != "") {
                              massege("loading...", Colors.amber);
                              teams = await ApiService.getTeams();
                              massege("done", Colors.green);
                            }
                          } catch (e) {
                            massege("Check your IP", Colors.red);
                            return;
                          }
                          int i = 0;
                          for (; i < teams.length; i++) {
                            if (teams[i]['id'] == realId) {
                              break;
                            }
                          }
                          if (i == teams.length) {
                            massege("Check the team id", Colors.red);
                            return;
                          }
                          GameScreen.Team = teams[i];
                          ApiService.connect();
                          await Future.delayed(const Duration(milliseconds: 200));
                          ApiService.channel.sink.add(jsonEncode(
                              {"type": "Team", "content": realId}));
                          Navigator.pushNamed(context, GameScreen.id);
                        }
                      },
                      child: const Icon(
                        Icons.qr_code_2,
                        color: Colors.black,
                      )),
                ),
              ],
            ),
          ),
        ));
  }
}

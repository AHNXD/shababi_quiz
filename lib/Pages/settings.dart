import 'package:flutter/material.dart';
import 'package:shababi_quiz/Pages/CamScanner.dart';
import '../services/apiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});
  static String id = "/settings";
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _retrieveIp();
  }

  void massege(String error, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: c,
      content: Center(child: Text(error)),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _retrieveIp() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the Ip is saved before or not
    if (!prefs.containsKey('ip')) {
      return;
    }

    setState(() {
      _controller.text = prefs.getString('ip')!;
      ApiService.ip = _controller.text;
    });
  }

  Future<void> _saveIp() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('ip', _controller.text);
  }

  void _clearIp() {
    _controller.text = "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "IP :",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              maxLength: 50,
              controller: _controller,
              decoration: InputDecoration(
                labelStyle: const TextStyle(color: Colors.amber),
                labelText: "IP",
                hintText: "Enter the IP",
                prefixIcon: const Icon(
                  Icons.numbers,
                  color: Colors.amber,
                ),
                suffixIcon: IconButton(
                    onPressed: () async {
                      var aux =
                          await Navigator.pushNamed(context, CamScanner.id);
                      if (aux != null) _controller.text = aux as String;
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.qr_code_2,
                      color: Colors.amber,
                    )),
                fillColor: Colors.amber,
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(25)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.amber, width: 2),
                    borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text != "") {
                _saveIp();
                ApiService.ip = _controller.text;
                massege("IP Saved :)", Colors.amber);
              } else {
                massege("Please enter the IP first", Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text("Save IP"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text != "") {
                _clearIp();
                massege("Cleared :)", Colors.amber);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Clear"),
          ),
          const Divider(thickness: 5, color: Colors.amber),
          Image.asset(
            "assets/icons/logo.png",
            height: 100,
            width: 100,
          )
        ],
      ),
    );
  }
}

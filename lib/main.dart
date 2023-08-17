import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

var request = "https://api.hgbrasil.com/finance?key=8e50e900";
void main() async {
  var response = await http.get(Uri.parse(request));
  json.decode(response.body)["results"]["currencies"]["USD"]["buy"];

  print(response.body);

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _realController = TextEditingController();
  final TextEditingController _dollarController = TextEditingController();
  final TextEditingController _euroController = TextEditingController();

  double? dollar;
  double? euro;

  void _realChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }

    double real = double.parse(text);
    _dollarController.text = (real / dollar!).toStringAsFixed(2);
    _euroController.text = (real / euro!).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }

    double dollar = double.parse(text);
    _realController.text = (dollar * this.dollar!).toStringAsFixed(2);
    _euroController.text = (dollar * this.dollar! / euro!).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      clearAll();
      return;
    }

    double euro = double.parse(text);
    _realController.text = (euro * this.euro!).toStringAsFixed(2);
    _dollarController.text = (euro * this.euro! / dollar!).toStringAsFixed(2);
  }

  void clearAll() {
    _realController.text = "";
    _dollarController.text = "";
    _euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("\$ Conversor de Moedas \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: fetchData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar dados...",
                  ),
                );
              } else {
                dollar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "\$ ", _realController, _realChanged),
                      const Divider(),
                      buildTextField(
                          "Dolares", "\$ ", _dollarController, _dollarChanged),
                      const Divider(),
                      buildTextField(
                          "Euro", "€ ", _euroController, _euroChanged),
                      const Divider(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          textStyle: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          clearAll();
                        },
                        child: const Text("Limpar"),
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Future<Map> fetchData() async {
  var response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function(String) onChange) {
  return TextFormField(
    controller: controller,
    onChanged: onChange,
    keyboardType: TextInputType.number,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      filled: true,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.amber,
        ),
      ),
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.amber,
        fontSize: 18,
      ),
      border: const OutlineInputBorder(),
      prefixText: prefix,
      prefixStyle: const TextStyle(
        color: Colors.amber,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.amber,
          width: 2,
        ),
      ),
    ),
  );
}

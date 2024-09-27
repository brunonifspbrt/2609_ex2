import 'dart:convert';

import 'package:ex7/coordenadas.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var conteudo = '';
  var msg = '';
  //TextEditingController tfCep = TextEditingController();
  TextEditingController contLat = TextEditingController();
  TextEditingController contLong = TextEditingController();
  TextEditingController contTemp = TextEditingController();
  TextEditingController contHum = TextEditingController();
  Position? _position;
  double geoLat = 0;
  double geoLong = 0;

  void limpaCampos() {
    contLat.clear();
    contLong.clear();
    contTemp.clear();
    contHum.clear();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    geoLat = 0;
    geoLong = 0;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // no Windows não é habilitada a opção de solicitar autorização. Nesse caso é necessário ir em:
      // 1- Configurações -> ‘Configurações de Privacidade Local’
      // 2- Localização: ativar opção 'Permitir acesso a localização neste dispositivo'
      // 3- Localização: ativar 'permitir que os apps acessem sua localização'
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void buscaLoc() async {
    Position position = await _determinePosition();
    setState(() {
      _position = position;
      // armazena lat e long
      geoLat = position.latitude;
      geoLong = position.longitude;
      contLat.text = geoLat.toStringAsFixed(2);
      contLong.text = geoLong.toStringAsFixed(2);
      // obtem conteúdo da geolocalização de lat. e long.
      //msg = _position.toString();
      //msg = 'Lat: $geoLat , Long: $geoLong';
    });
  }

  void buscaCoord() async {
    String lat = contLat.text;
    String long = contLong.text;
    lat = lat.replaceAll(",", ".");
    long = long.replaceAll(",", ".");

    // define url com cep ja embutido
    // String url =
    //     'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m&forecast_days=1';
    String url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m,relative_humidity_2m&forecast_days=1';

    // verifica tamanho do campo
    if ((lat.length < 2) || (long.length < 2)) {
      // limpa todos os campos
      limpaCampos();
      setState(() {
        msg = 'Informe Lat. e Long. Válidos!';
      });
    } else {
      // objeto Json retornado da APi
      final resposta = await http.get(Uri.parse(url));

      if (resposta.statusCode == 200) {
        // resposta 200 OK
        // o body contém JSON
        // obtem todo conteudo de json
        var jsonValor = jsonDecode(resposta.body);
        // como a chave que desejo está em um objeto DENTRO do Objeto Json, informo somente ele, no caso o current
        var coord = Coordenada.fromJson(jsonValor['current']);
        setState(() {
          msg = 'Lat. e Long informados encontrado';
        });
        contTemp.text = coord.temperature2m.toString();
        contHum.text = coord.humidity2m.toString();
      } else {
        // diferente de 200 exibe mensagem de erro
        // throw Exception('Falha no carregamento.');
        setState(() {
          msg = 'Lat. e Long informados NÃO encontrado';
        });
        limpaCampos();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: () {
                  buscaLoc();
                },
                child: const Text('Obter Localização Atual'),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contLat,
                  decoration: const InputDecoration(labelText: 'Latitude:'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contLong,
                  decoration: const InputDecoration(labelText: 'Longitude:'),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: TextField(
              //     controller: contCep,
              //     maxLines: 5,
              //   ),
              // ),
              // TextField(
              //   controller: tfCep,
              //   decoration: const InputDecoration(labelText: 'Digite o CEP'),
              // ),
              const SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: () {
                  buscaCoord();
                },
                child: const Text('Buscar'),
              ),
              Text('Resultado: $msg'),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: contTemp,
                  decoration:
                      const InputDecoration(labelText: 'Temperatura Atual:'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: contHum,
                  decoration:
                      const InputDecoration(labelText: 'Umidade Relativa:'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

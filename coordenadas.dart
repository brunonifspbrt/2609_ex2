class Coordenada {
  String time;
  int interval;
  double temperature2m;
  int humidity2m;

  Coordenada({
    required this.time,
    required this.interval,
    required this.temperature2m,
    required this.humidity2m,
  });

  // Método para converter um Map em um objeto Endereco
  factory Coordenada.fromJson(Map<String, dynamic> json) {
    return Coordenada(
      time: json['time'],
      interval: json['interval'],
      temperature2m: json['temperature_2m'],
      humidity2m: json['relative_humidity_2m'],
    );
  }
}

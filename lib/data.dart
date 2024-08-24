class Data {
  late final String description;
  late final String temperature;
  late final String icon;
  late final DateTime date;
  late final double temp_min;
  late final double temp_max;

  Data({
    required this.description,
    required this.temperature,
    required this.icon,
    required this.date,
    required this.temp_min,
    required this.temp_max,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final date = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);

    print(json);
    
    double temperaturaCelsius = main['temp'] - 273.15;
    double tempMaxCelsius = main['temp_max'] ;
    double tempMinCelsius = main['temp_min'] ;

    return Data(
      date: date,
      description: weather['description'].toString(),
      temperature: temperaturaCelsius.toInt().toString(),
      icon: weather['icon'],
      temp_max: tempMaxCelsius,
      temp_min: tempMinCelsius,
    );
  }
}

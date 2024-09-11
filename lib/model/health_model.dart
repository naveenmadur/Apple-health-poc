class HealthModel {
  const HealthModel({this.values, this.type});

  final String? type;
  final List<Value>? values;

  factory HealthModel.fromJson(MapEntry<String, dynamic> json) => HealthModel(
        type: json.key.toString().toUpperCase(),
        values: (json.value as List<Object>?)
            ?.map(
              (Object e) => Value.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}

class Value {
  Value(this.value, this.date);

  final num? value;
  final DateTime? date;

  factory Value.fromJson(Map<String, dynamic> json) => Value(
        json['value'],
        json['date'] != null ? DateTime.parse(json['date']) : null,
      );
}

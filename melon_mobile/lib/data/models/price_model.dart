class PricePoint {
  final DateTime time;
  final double close;

  PricePoint({required this.time, required this.close});

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      time: DateTime.parse(json['datetime']),
      close: double.parse(json['close'].toString()),
    );
  }
}

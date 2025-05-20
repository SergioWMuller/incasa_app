class WeeklyAvailabilityModel {
  final String id;
  final String productServiceId;
  final int weekday;
  final String startTime;
  final String endTime;

  WeeklyAvailabilityModel({
    required this.id,
    required this.productServiceId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  factory WeeklyAvailabilityModel.fromMap(Map<String, dynamic> map) {
    return WeeklyAvailabilityModel(
      id: map['id'],
      productServiceId: map['product_service_id'],
      weekday: map['weekday'],
      startTime: map['start_time'],
      endTime: map['end_time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_service_id': productServiceId,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

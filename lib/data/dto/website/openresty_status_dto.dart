class OpenRestyStatusDto {
  const OpenRestyStatusDto({
    required this.active,
    required this.accepts,
    required this.handled,
    required this.requests,
    required this.reading,
    required this.writing,
    required this.waiting,
  });

  final int active;
  final int accepts;
  final int handled;
  final int requests;
  final int reading;
  final int writing;
  final int waiting;

  factory OpenRestyStatusDto.fromJson(Map<String, dynamic> json) {
    return OpenRestyStatusDto(
      active: json['active'] as int? ?? 0,
      accepts: json['accepts'] as int? ?? 0,
      handled: json['handled'] as int? ?? 0,
      requests: json['requests'] as int? ?? 0,
      reading: json['reading'] as int? ?? 0,
      writing: json['writing'] as int? ?? 0,
      waiting: json['waiting'] as int? ?? 0,
    );
  }
}

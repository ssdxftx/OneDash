class PageResult<T> {
  const PageResult({required this.total, required this.items});

  final int total;
  final List<T> items;

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final itemsJson = json['items'] as List?;
    return PageResult<T>(
      total: json['total'] as int? ?? 0,
      items:
          itemsJson
              ?.map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList() ??
          <T>[],
    );
  }
}

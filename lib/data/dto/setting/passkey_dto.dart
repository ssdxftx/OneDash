class PasskeyChallenge {
  const PasskeyChallenge({required this.sessionId, required this.publicKey});

  final String sessionId;
  final Map<String, dynamic> publicKey;

  factory PasskeyChallenge.fromJson(Map<String, dynamic> json) {
    final raw = json['publicKey'];
    return PasskeyChallenge(
      sessionId: json['sessionId']?.toString() ?? '',
      publicKey: raw is Map
          ? Map<String, dynamic>.from(raw)
          : const <String, dynamic>{},
    );
  }
}

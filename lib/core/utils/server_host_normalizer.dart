String normalizeServerHostInput(String input) {
  var value = input.trim().replaceAll('：', ':');
  if (value.isEmpty) return '';

  final parsed = Uri.tryParse(value);
  if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
    return parsed.host;
  }

  if (value.startsWith('//')) {
    final parsedProtocolRelative = Uri.tryParse('http:$value');
    if (parsedProtocolRelative != null &&
        parsedProtocolRelative.host.isNotEmpty) {
      return parsedProtocolRelative.host;
    }
  }

  final schemeSeparator = value.indexOf('://');
  if (schemeSeparator >= 0) {
    value = value.substring(schemeSeparator + 3);
  }

  var host = value.split(RegExp(r'[/?#]')).first.trim();
  if (host.startsWith('[')) {
    final bracketEnd = host.indexOf(']');
    if (bracketEnd > 0) return host.substring(1, bracketEnd);
  }

  final portSeparator = host.lastIndexOf(':');
  if (portSeparator > 0 &&
      host.indexOf(':') == portSeparator &&
      int.tryParse(host.substring(portSeparator + 1)) != null) {
    host = host.substring(0, portSeparator);
  }

  return host;
}

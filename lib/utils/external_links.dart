/// Returns a launchable URL, or an empty string for an unsupported value.
String normalizeExternalUrl(String value) {
  final input = value.trim();
  if (input.isEmpty || RegExp(r'[\s\\\x00-\x1f]').hasMatch(input)) return '';
  var uri = Uri.tryParse(input);
  if (uri == null) return '';
  if (!uri.hasScheme) {
    if (input.startsWith('/') ||
        input.startsWith('.') ||
        !input.contains('.')) {
      return '';
    }
    uri = Uri.tryParse('https://$input');
  }
  if (uri == null) return '';
  switch (uri.scheme.toLowerCase()) {
    case 'http':
    case 'https':
      if (uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          uri.host == 'http' ||
          uri.host == 'https') {
        return '';
      }
      return uri.toString();
    case 'mailto':
      return uri.path.contains('@') ? uri.toString() : '';
    case 'tel':
      return RegExp(r'^\+?[0-9().-]+$').hasMatch(uri.path)
          ? uri.toString()
          : '';
    default:
      return '';
  }
}

/// Resolves a site-local asset, or accepts an ordinary HTTP(S) URL.
String resolveAssetUrl(String value, {Uri? base}) {
  final input = value.trim();
  if (input.startsWith('/') &&
      !input.startsWith('//') &&
      !RegExp(r'[\\\x00-\x1f]').hasMatch(input)) {
    final uri = Uri.tryParse(input);
    if (uri != null && !uri.hasScheme && !uri.hasAuthority) {
      return (base ?? Uri.base).resolveUri(uri).toString();
    }
  }
  final normalized = normalizeExternalUrl(input);
  final uri = Uri.tryParse(normalized);
  return uri != null && (uri.scheme == 'https' || uri.scheme == 'http')
      ? normalized
      : '';
}

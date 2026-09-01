import 'dart:io';

String getDefaultApiBaseUrl() {
  // Android emulator needs 10.0.2.2
  try {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    if (Platform.isIOS) return 'http://localhost:3000';
  } catch (_) {}
  return 'http://localhost:3000';
}

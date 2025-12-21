import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  Stream<dynamic>? _broadcastStream;

  // Singleton pattern
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  Stream<dynamic>? get stream => _broadcastStream;

  String get _url {
    if (kIsWeb) return 'ws://127.0.0.1:8000/ws/dashboard/';
    if (Platform.isAndroid) {
      // Use local IP for physical device
      return 'ws://192.168.43.209:8000/ws/dashboard/';
    }
    return 'ws://127.0.0.1:8000/ws/dashboard/';
  }

  void connect() {
    if (_channel != null) return; // Prevent multiple connections

    try {
      final uri = Uri.parse(_url);
      _channel = WebSocketChannel.connect(uri);

      // Convert single-subscription stream to broadcast stream
      _broadcastStream = _channel!.stream.asBroadcastStream();

      debugPrint("✅ WebSocket Connected to $_url");

      _broadcastStream?.listen(
        (data) {
          debugPrint("📩 Received: $data");
        },
        onError: (error) {
          debugPrint("❌ WebSocket Error: $error");
        },
        onDone: () {
          debugPrint("⚠️ WebSocket Closed");
          _channel = null;
        },
      );
    } catch (e) {
      debugPrint("❌ WebSocket Connection Exception: $e");
    }
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _broadcastStream = null;
  }
}

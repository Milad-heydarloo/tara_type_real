


import 'dart:convert';

import 'package:get/get.dart';
import 'package:tara_type_real/http_client.dart';

class MessageQueue {
  final HttpClient _httpClient;
  final List<Map<String, String>> _messageQueue = [];
  bool _isProcessing = false;

  MessageQueue(String baseUrl) : _httpClient = HttpClient(baseUrl);

  void addMessage(String message, String chatId) {
    _messageQueue.add({"message": message, "chat_id": chatId});
    if (!_isProcessing) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_messageQueue.isNotEmpty) {
      final messageData = _messageQueue.first;
      try {
        await _httpClient.post("api/sendMessage", messageData);
        _messageQueue.removeAt(0);
      } catch (e) {
        await Future.delayed(Duration(seconds: 5));
      }
    }

    _isProcessing = false;
  }
}

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:flutter_chatgpt/data/if.dart';
import 'package:flutter_chatgpt/data/llm.dart';
import 'package:flutter_chatgpt/data/you.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:get_storage/get_storage.dart';

class MessageRepository {
  static final MessageRepository _instance = MessageRepository._internal();

  factory MessageRepository() {
    return _instance;
  }

  MessageRepository._internal() {
    init();
  }

  void postMessage(
    Message message,
    ValueChanged<Message> onResponse,
    ValueChanged<Message> onError,
    ValueChanged<Message> onSuccess,
  ) async {
    try {
      List<Message> messages =
          await ConversationRepository().getMessagesByConversationUUid(
        message.conversationId,
      );

      debugPrint('');

      _getResponseFromGpt(messages, onResponse, onError, onSuccess);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void init() {
    try {
      OpenAI.apiKey = GetStorage().read('openAiKey') ?? "";
    } catch (e) {
      OpenAI.apiKey = "";
      debugPrint('$e');
    }

    try {
      OpenAI.baseUrl =
          GetStorage().read('openAiBaseUrl') ?? "https://api.openai.com";
    } catch (e) {
      OpenAI.baseUrl = "https://api.openai.com";
    }
  }

  void _getResponseFromGpt(
      List<Message> messages,
      ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback,
      ValueChanged<Message> onSuccess) async {
    String llm = SettingsController.to.llm.value;

    switch (llm.toUpperCase()) {
      case "OPENAI":
        ChatGpt().getResponse(messages, onResponse, errorCallback, onSuccess);
        break;
      case "YOU":
        YouAi().getResponse(messages, onResponse, errorCallback, onSuccess);
        break;
      case "IF":
        ChatIF().getResponse(messages, onResponse, errorCallback, onSuccess);
        break;
      default:
        ChatGpt().getResponse(messages, onResponse, errorCallback, onSuccess);
    }
  }

  deleteMessage(int messageId) {
    ConversationRepository().deleteMessage(messageId);
  }
}

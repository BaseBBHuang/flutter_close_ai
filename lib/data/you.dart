import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chatgpt/controller/settings.dart';
import 'package:flutter_chatgpt/repository/conversation.dart';
import 'package:flutter_chatgpt/utils/bingSearch.dart';
import 'package:vibration/vibration.dart';

abstract class LLM {
  getResponse(List<Message> messages, ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback, ValueChanged<Message> onSuccess);
}

class YouAi extends LLM {
  @override
  getResponse(
      List<Message> messages,
      ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback,
      ValueChanged<Message> onSuccess) async {
    List<OpenAIChatCompletionChoiceMessageModel> openAIMessages = [];
    //将messages反转
    messages = messages.reversed.toList();
    // 将messages里面的每条消息的内容取出来拼接在一起
    String content = "";
    String currentModel = SettingsController.to.gptModel.value;
    int maxTokenLength = 1800;
    switch (currentModel) {
      case "gpt-3.5-turbo":
        maxTokenLength = 1800;
        break;
      case "gpt-3.5-turbo-1106":
        maxTokenLength = 10000;
        break;
      default:
        maxTokenLength = 1800;
        break;
    }
    bool useWebSearch = SettingsController.to.useWebSearch.value;
    if (useWebSearch) {
      messages.first.text = await fetchAndParse(messages.first.text);
    }
    for (Message message in messages) {
      content = content + message.text;
      if (content.length < maxTokenLength || openAIMessages.isEmpty) {
        // 插入到 openAIMessages 第一个位置
        final model = OpenAIChatCompletionChoiceMessageContentItemModel.text(
          message.text,
        );
        openAIMessages.insert(
          0,
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              model,
            ],
            role: message.role.asOpenAIChatMessageRole,
          ),
        );
      }
    }
    var message = Message(
        conversationId: messages.first.conversationId,
        text: "",
        role: Role.assistant); //仅仅第一个返回了角色
    if (SettingsController.to.useStream.value) {
      Stream<OpenAIStreamChatCompletionModel> chatStream = OpenAI.instance.chat
          .createStream(
              model: currentModel,
              messages: openAIMessages,
              user: SettingsController.to.youCode.value);
      chatStream.listen(
        (chatStreamEvent) async {
          if (chatStreamEvent.choices.first.delta.content != null) {
            message.text = message.text +
                (chatStreamEvent.choices.first.delta.content!.first?.text ??
                    '');
            try {
              var hasVibration = await Vibration.hasVibrator();
              if (hasVibration != null && hasVibration) {
                Vibration.vibrate(duration: 50);
              }
            } catch (e) {
              // ignore
            }

            onResponse(message);
          }
        },
        onError: (error) {
          message.text = error.message;
          errorCallback(message);
        },
        onDone: () {
          onSuccess(message);
        },
      );
    } else {
      try {
        var response = await OpenAI.instance.chat.create(
          model: currentModel,
          messages: openAIMessages,
        );
        message.text = response.choices.first.message.content?.first.text ?? '';
        onSuccess(message);
      } catch (e) {
        message.text = e.toString();
        errorCallback(message);
      }
    }
  }
}

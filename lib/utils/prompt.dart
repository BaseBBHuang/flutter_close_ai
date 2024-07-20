import 'package:flutter_chatgpt/controller/prompt.dart';

Future<List<Prompt>> getPrompts() async {
  final List<Prompt> prompts = [];

  final response = [
    {"act": "Prompt:客户端开发", "prompt": "需要你扮演技术精湛的客户端开发工程师,解决客户端问题"},
  ];

  for (var item in response) {
    prompts.add(Prompt(item['act']!, item['prompt']!));
  }

  return prompts;
}

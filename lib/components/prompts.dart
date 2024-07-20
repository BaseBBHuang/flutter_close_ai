import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/controller/prompt.dart';
import 'package:get/get.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

class PromptsView extends GetResponsiveView {
  final List<Prompt> prompts;
  final ValueChanged<String> onPromptClick;

  PromptsView(
    this.prompts,
    this.onPromptClick, {
    super.key,
  });

  final _scrollController = ScrollController();

  @override
  Widget? desktop() {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: prompts.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () => {onPromptClick(prompts[index].prompt)},
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  prompts[index].act,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Text(
                    prompts[index].prompt,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                    maxLines: 5,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget? phone() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: prompts.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () => {onPromptClick(prompts[index].prompt)},
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: MeshAnitWidget(
              prompts: prompts,
              index: index,
            ),
          ),
        );
      },
    );
  }
}

List<Color?> sMaterialColor = [
  Colors.blue[300],
  Colors.green[300],
  Colors.purple[300],
  Colors.red[300],
  Colors.pink[300],
  Colors.orange[300],
  Colors.teal[300],
  Colors.brown[300],
];
Color? getRandomColor() {
  return sMaterialColor[Random().nextInt(sMaterialColor.length)];
}

class MeshAnitWidget extends StatefulWidget {
  final List<Prompt> prompts;
  final int index;

  const MeshAnitWidget({
    super.key,
    required this.prompts,
    required this.index,
  });

  @override
  State<MeshAnitWidget> createState() => _MeshAnitWidgetState();
}

class _MeshAnitWidgetState extends State<MeshAnitWidget> {
  late final AnimatedMeshGradientController _controller;
  @override
  void initState() {
    _controller = AnimatedMeshGradientController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.start();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AnimatedMeshGradient(
        colors: const [
          Colors.red,
          Colors.blue,
          Colors.purple,
          Colors.yellow,
        ],
        options: AnimatedMeshGradientOptions(
          speed: 10,
          // frequency: 10,
        ),
        controller: _controller,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.prompts[widget.index].act,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.prompts[widget.index].prompt,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  // color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

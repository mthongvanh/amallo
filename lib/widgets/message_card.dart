import 'package:amallo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../data/models/view_model_property.dart';
import 'elapsed_time.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.messageText,
    required this.conversing,
    this.date,
    this.backgroundColor,
    this.incomingMessage,
  });

  final bool conversing;
  final String messageText;
  final DateTime? date;
  final Color? backgroundColor;
  final ViewModelProperty? incomingMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        (conversing && incomingMessage != null)
            ? ListenableBuilder(
                listenable: incomingMessage!,
                builder: (context, _) {
                  String message;
                  if (incomingMessage?.value != null) {
                    message = incomingMessage!.value;
                  } else {
                    message = '...';
                  }
                  return messageCard(message);
                })
            : messageCard(messageText),
        if (date != null)
          Align(
            alignment: Alignment.bottomRight,
            child: ElapsedTimeWidget(startDateTime: date!),
          ),
      ],
    );
  }

  Card messageCard(text) {
    return Card(
      color: backgroundColor,
      child: Markdown(
        shrinkWrap: true,
        selectable: true,
        data: text,
        padding: const EdgeInsets.all(24.0),
        // syntaxHighlighter: CodeHighlighter(),
        styleSheet: CodeStyleSheet(),
        // builders: {
        //   'code': CodeElementBuilder(),
        // },
      ),
    );
  }
}

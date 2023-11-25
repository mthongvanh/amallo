import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

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
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(color: Colors.white70, height: 1.65),
          listBullet: const TextStyle(color: Colors.white70),
          codeblockPadding: const EdgeInsets.all(16.0),
          code: GoogleFonts.robotoMono().copyWith(
            color: Colors.white70,
            fontSize: 14,
            backgroundColor: Colors.transparent,
            overflow: TextOverflow.visible,
          ),
          codeblockDecoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // builders: {
        //   'code': CodeElementBuilder(),
        // },
      ),
    );
  }
}

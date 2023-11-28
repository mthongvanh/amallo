import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class MouseTouchScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class CodeStyleSheet extends MarkdownStyleSheet {
  CodeStyleSheet()
      : super(
          p: const TextStyle(
            color: Colors.white70,
            height: 1.65,
          ),
          listBullet: const TextStyle(
            color: Colors.white70,
          ),
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
        );
}

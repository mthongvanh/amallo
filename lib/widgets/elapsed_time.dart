import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Updates every second when the elapsed time is less than a minute and every minute when it's less
/// than a day, otherwise it stops updating to prevent unnecessary ticks. It also stops the
/// AnimationController when the elapsed time is more than a day, as there are no longer any need
/// for ticks beyond that point.
///
/// Deepseek Coder (33b-instruct-q8) with developer-led revisions
class ElapsedTimeWidget extends StatefulWidget {
  /// Declaring a final DateTime variable to hold the start date and time.
  final DateTime startDateTime;
  final DateFormat? dateFormat;
  final TextStyle? dateTextStyle;

  /// Constructor of the class that takes two arguments: Key? key and required this.startDateTime.
  const ElapsedTimeWidget({
    required this.startDateTime,
    this.dateFormat,
    this.dateTextStyle,
    Key? key,
  }) : super(key: key);

  @override
  State<ElapsedTimeWidget> createState() => _ElapsedTimeWidgetState();
}

class _ElapsedTimeWidgetState extends State<ElapsedTimeWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            setState(() {});
          });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Calculating the difference between the current time and the startDateTime.
    Duration elapsed = DateTime.now().difference(widget.startDateTime);

    /// Declaring a string variable to hold the text that will be displayed in the widget.
    String text;

    /// If the elapsed duration is less than 60 seconds, format and set the text to "X second(s) ago", where X is the number of seconds.
    if (elapsed.inSeconds < 60) {
      int seconds = elapsed.inSeconds;
      text = "$seconds second(s) ago";
    } else if (elapsed.inMinutes < 1 * 60) {
      /// Else if the elapsed minutes are less than a day, format and set the text to "X minute(s) ago", where X is the number of minutes.
      int minutes = elapsed.inMinutes;
      text = "$minutes minute(s) ago";
    } else if (elapsed.inHours < 3) {
      /// Else if the elapsed hours are less three hours ago, format and set the text to "X hour(s) ago", where X is the number of hours.
      int minutes = elapsed.inHours;
      text = "$minutes hour(s) ago";
    } else if (elapsed.inHours < 24) {
      /// Else if the elapsed hours are less one day, format and set the text to the time in hours and minutes.
      String formattedDateTime =
          widget.dateFormat?.format(widget.startDateTime) ??
              DateFormat.Hm().format(widget.startDateTime);
      text = "at $formattedDateTime";
    } else {
      /// If none of the above conditions are met, format and set the text to "on yyyy-MM-dd HH:mm", where yyyy-MM-dd HH:mm is the startDateTime formatted as such.
      String formattedDateTime =
          widget.dateFormat?.format(widget.startDateTime) ??
              DateFormat.yMMMMd().add_Hm().format(widget.startDateTime);
      text = "on $formattedDateTime";

      /// Stopping the AnimationController if the elapsed time is more than a day, to prevent unnecessary ticks.
      _controller.stop();
    }

    return Text(
      text,
      style: widget.dateTextStyle,
    );
  }
}

import 'package:amallo/data/enums/message_source.dart';

class Message {
  String? text;
  String? source;
  int? createdOn;

  /// message context with dialogue
  List? context;

  /// model used to generate response
  String? model;

  /// total time taken to generate the response measured in nanoseconds 1x10^9
  int? totalDuration;

  /// response token count
  int? evalTokens;

  /// total time taken to evaluate the response measured in nanoseconds 1x10^9
  int? evalDuration;

  /// chat thread identifier
  String? chatUuid;

  Message(
    this.text, {
    this.source,
    this.createdOn,
    this.chatUuid,
    this.context,
    this.model,
    this.totalDuration,
    this.evalTokens,
    this.evalDuration,
  });

  static Message fromMap(map) {
    final Message m = Message(
      map['text'] as String,
      source: map['source'] as String,
      createdOn: map['createdOn'] as int,
      chatUuid: map['chatUuid'] as String,
      context: map['context'] as List?,
      model: map['model'] as String?,
      totalDuration: map['total_duration'] as int?,
      evalTokens: map['eval_count'] as int?,
      evalDuration: map['eval_duration'] as int?,
    );
    return m;
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'source': source,
      'createdOn': createdOn,
      'chatUuid': chatUuid,
      'context': context,
      'model': model,
      'total_duratation': totalDuration,
      'eval_count': evalTokens,
      'eval_duration': evalDuration,
    };
  }

  Message finalizeFromJson(json) {
    context = json['context'] as List?;
    totalDuration = json['total_duration'] as int?;
    evalTokens = json['eval_count'] as int?;
    evalDuration = json['eval_duration'] as int?;
    return this;
  }

  double get tokensPerSecond => (evalTokens == null || evalDuration == null)
      ? 0
      : (evalTokens! / (evalDuration! / 1000000000.0));

  bool get done =>
      evalDuration != null || source == MessageSource.userInput.name;
}

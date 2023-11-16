class Chat {
  String uuid;
  String? title;
  int? createdOn;

  Chat(this.uuid, {this.title, this.createdOn});

  static Chat fromMap(map) {
    final Chat c = Chat(
      map['uuid'] as String,
      createdOn: map['createdOn'] as int,
      title: map['title'] as String,
    );
    return c;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createdOn': createdOn,
      'uuid': uuid,
    };
  }
}

class Data {
  final int id;
  String text;

  Data({this.id, this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
    };
  }
}
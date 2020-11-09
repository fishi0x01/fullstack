class Counter {
  final int id;
  String name;
  int val;

  Counter({this.id, this.name, this.val});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'val': val,
    };
  }
}
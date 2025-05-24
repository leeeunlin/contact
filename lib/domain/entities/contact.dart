class Contact {
  final int seq;
  final String name;
  final String number;
  final String email;

  Contact({int? seq, String? name, String? number, String? email})
    : seq = seq ?? 0,
      name = name ?? '',
      number = number ?? '',
      email = email ?? '';
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      seq: json['seq'] ?? 0,
      name: json['name'] ?? '',
      number: json['number'] ?? '',
      email: json['email'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
    'seq': seq,
    'name': name,
    'number': number,
    'email': email,
  };
}

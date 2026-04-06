class Recipient {
  final String name;
  final String email;
  const Recipient({required this.name, required this.email});
  String get initials => name.isNotEmpty
      ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
      : email.isNotEmpty
          ? email[0].toUpperCase()
          : '?';
}

class Attachment {
  final String filename;
  const Attachment({required this.filename});
}

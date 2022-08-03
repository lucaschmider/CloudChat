class Message {
  final String userId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.userId,
    required this.timestamp,
  });
}

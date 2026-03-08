class Friend {
  final String id;
  final String username;
  final String avatarUrl;
  final String status;

  Friend({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.status,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      status: json['status'],
    );
  }
}

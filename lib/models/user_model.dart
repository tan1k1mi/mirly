import 'package:mirly/models/friend_model.dart';

class User {
  final String id;
  final String username;
  final int pops;
  final String avatarUrl;
  final String status;
  final List<Friend> friends;

  User({
    required this.id,
    required this.username,
    required this.pops,
    required this.avatarUrl,
    required this.status,
    required this.friends,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      pops: json['pops'],
      avatarUrl: json['avatarUrl'],
      status: json['status'],
      friends: (json['friends'] as List)
          .map((friend) => Friend.fromJson(friend))
          .toList(),
    );
  }
}

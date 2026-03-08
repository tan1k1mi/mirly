import 'package:mirly/models/friend_model.dart';

class User {
  final String id;
  final String username;
  final int pops;
  final String avatarUrl;
  final String status;
  final List<Friend> friends;
  final List<String>? categories;

  User({
    required this.id,
    required this.username,
    required this.pops,
    required this.avatarUrl,
    required this.status,
    required this.friends,
    this.categories,
  });

  static User currentUser = User(
    id: '1',
    username: 'JohnDoe',
    pops: 0,
    avatarUrl: '',
    status: 'online',
    friends: [],
    categories: [],
  );

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
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mirly/models/friend_model.dart';

class FriendWidget extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onMore;

  const FriendWidget({super.key, required this.friend, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color.fromARGB(255, 40, 40, 40),
                backgroundImage: friend.avatarUrl.isNotEmpty
                    ? NetworkImage(friend.avatarUrl)
                    : null,
                child: friend.avatarUrl.isEmpty
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.username,
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  Text(
                    friend.status.isEmpty ? "No status" : friend.status,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(255, 179, 179, 179),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: onMore,
            icon: Icon(
              Icons.more_horiz,
              color: Color.fromARGB(255, 179, 179, 179),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

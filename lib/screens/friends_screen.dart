import 'package:flutter/material.dart';
import 'package:mirly/models/friend_model.dart';
import 'package:mirly/models/user_model.dart';
import 'package:mirly/widgets/friend_widget.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  User? user;
  List<Friend> friends = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    user = User(
      id: '1',
      username: "UserName",
      pops: 0,
      avatarUrl: '',
      status: 'Hello',
      friends: [
        Friend(id: '2', username: 'Friend 1', avatarUrl: '', status: 'Online'),
        Friend(
          id: '3',
          username: 'Friend 2',
          avatarUrl: '',
          status: 'Sleeping',
        ),
      ],
    );

    friends = user!.friends;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 10, 10),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Container(height: 0.5, color: Color.fromARGB(255, 87, 87, 87)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (user != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user!.username, style: TextStyle(color: Colors.white)),
                  Text(
                    "${user!.pops} Pops",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(255, 179, 179, 179),
                    ),
                  ),
                ],
              ),
            CircleAvatar(
              radius: 20,
              backgroundColor: Color.fromARGB(255, 40, 40, 40),
              backgroundImage: user!.avatarUrl.isNotEmpty
                  ? NetworkImage(user!.avatarUrl)
                  : null,
              child: user!.avatarUrl.isEmpty
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${friends.length} Friends",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 179, 179, 179),
                  ),
                ),

                SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];

                      return FriendWidget(
                        friend: friend,
                        onMore: () {
                          print("More clicked: ${friend.username}");
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 70, 70, 70),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

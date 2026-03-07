import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 10, 10, 10),
      appBar: new AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(5),
          child: Container(height: 0.5, color: Color.fromARGB(255, 87, 87, 87)),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(0, 10, 10, 10),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "UserName",
                  style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                ),
                Text(
                  "10 Pops",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 179, 179, 179),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.photo_camera,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 47,
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
                  "2 Friends",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 179, 179, 179),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.photo_camera,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 60,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FriendName 1",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                "Status...",
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
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_horiz,
                          color: Color.fromARGB(255, 179, 179, 179),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.photo_camera,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 60,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FriendName 2",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                "Status...",
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
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_horiz,
                          color: Color.fromARGB(255, 179, 179, 179),
                          size: 40,
                        ),
                      ),
                    ],
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

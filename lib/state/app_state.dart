import 'package:mirly/models/user_model.dart';
import 'package:mirly/models/friend_model.dart';

class AppState {
  static User currentUser = User(
    id: '1',
    username: "UserName",
    pops: 0,
    avatarUrl: '',
    status: 'Hello',
    friends: [
      Friend(id: '2', username: 'Friend 1', avatarUrl: '', status: 'Online'),
      Friend(id: '3', username: 'Friend 2', avatarUrl: '', status: 'Sleeping'),
    ],
    categories: [],
  );
}

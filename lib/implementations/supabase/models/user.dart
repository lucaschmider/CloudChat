class User {
  final String userId;
  final String name;

  User._({
    required this.userId,
    required this.name,
  });

  static User fromDynamic(dynamic data) => User._(
        userId: data["userId"],
        name: data["name"],
      );
}

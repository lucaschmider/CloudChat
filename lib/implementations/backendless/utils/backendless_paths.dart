class BackendlessPaths {
  static const loginPath = "/api/users/login";
  static const logoutPath = "/api/users/logout";
  static const registerPath = "/api/users/register";
  static String tablePath(String tableName) => "/api/data/$tableName";
  static String bulkTablePath(String tableName) => "/api/data/bulk/$tableName";

  static String get userPath => tablePath("user");
  static String get roomsPath => tablePath("rooms");
  static String get roomMessagesPath => tablePath("room_messages");
  static String get roomParticipantsPath => tablePath("room_participants");
  static String get bulkRoomPath => bulkTablePath("rooms");
  static String get bulkRoomParticipantsPath =>
      bulkTablePath("room_participants");
}

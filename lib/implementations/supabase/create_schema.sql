CREATE TABLE chat_room (
    chatRoomId UUID NOT NULL PRIMARY KEY,
    roomName VARCHAR(512) NOT NULL
);

CREATE TABLE chat_room_participant (
    chatRoomId UUID NOT NULL,
    userId uuid NOT NULL,

    PRIMARY KEY(chatRoomId, userId),
    FOREIGN KEY(chatRoomId) REFERENCES chat_room(chatRoomId),
    FOREIGN KEY(userId) REFERENCES auth.users(id)
);

CREATE TABLE chat_room_message (
    messageId UUID NOT NULL PRIMARY KEY,
    chatRoomId UUID NOT NULL,
    text text NOT NULL,
    createdAt TIMESTAMP NOT NULL,
    sender UUID NOT NULL,

    FOREIGN KEY(chatRoomId) REFERENCES chat_room(chatRoomId),
    FOREIGN KEY(sender) REFERENCES auth.users(id)
);

CREATE TABLE userData (
    userId UUID NOT NULL PRIMARY KEY,
    name VARCHAR(512) NOT NULL,

    FOREIGN KEY(userId) REFERENCES auth.users(id)
);
CREATE SCHEMA cloud_chat;

CREATE TABLE cloud_chat.chat_room (
    chatRoomId UUID NOT NULL PRIMARY KEY,
    roomName VARCHAR(512) NOT NULL
);

CREATE TABLE cloud_chat.chat_room_participant (
    chatRoomId UUID NOT NULL,
    userId uuid NOT NULL,

    PRIMARY KEY(chatRoomId, userId),
    FOREIGN KEY(chatRoomId) REFERENCES cloud_chat.chat_room(chatRoomId),
    FOREIGN KEY(userId) REFERENCES auth.users(id)
);

CREATE TABLE cloud_chat.chat_room_message (
    messageId UUID NOT NULL PRIMARY KEY,
    chatRoomId UUID NOT NULL,
    text text NOT NULL,
    createdAt TIMESTAMP NOT NULL,
    sender UUID NOT NULL,

    FOREIGN KEY(chatRoomId) REFERENCES cloud_chat.chat_room(chatRoomId),
    FOREIGN KEY(sender) REFERENCES auth.users(id)
);

CREATE TABLE cloud_chat.user (
    userId UUID NOT NULL PRIMARY KEY,
    name VARCHAR(512) NOT NULL,

    FOREIGN KEY(userId) REFERENCES auth.users(id)
);
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:flutter/foundation.dart';

import '../../logger.dart';
import 'models/chat_message.dart';
import 'models/chat_room_metadata.dart';
import 'models/chat_user.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Logger logger;
  final ChatRepository repository;

  StreamSubscription? messageSubscription;
  StreamSubscription? metadataSubscription;
  late final StreamSubscription userSubscription;

  ChatBloc({
    required this.logger,
    required this.repository,
  }) : super(const ChatInitial()) {
    on<ChatLogin>(
      (event, emit) {
        emit(ChatUserAvailable(sender: event.user));
        add(ChatRoomSelected("chatRoomId"));
      },
    );
    on<ChatLogout>(
      (event, emit) => emit(const ChatInitial()),
    );
    on<ChatRoomRetrieved>(_handleChatRoomRetrieved);
    on<ChatRoomSelected>(_handleChatRoomSelected);
    on<ChatMessageAdded>(_handleChatMessageAdded);
    on<ChatRoomChanged>(
      (event, emit) => emit(ChatRoomAvailable(
          sender: state.sender!,
          chatRoom: event.chatRoom,
          messages: state.messages)),
    );

    userSubscription = repository.getUserStream().listen(
        (event) => event != null ? add(ChatLogin(event)) : add(ChatLogout()));
  }

  void _handleChatRoomRetrieved(
      ChatRoomRetrieved event, Emitter<ChatState> emit) {
    if (state is! ChatUserAvailable) {
      logger.warn(
          "State transition 'ChatRoomRetrieved' is only valid from state 'ChatUserAvailable'");
      return;
    }
    messageSubscription = repository
        .getMessageStream(event.chatRoom.chatRoomId)
        .listen((event) => add(ChatMessageAdded(event)));
    metadataSubscription = repository
        .getMetadataStream(event.chatRoom.chatRoomId)
        .listen((event) => add(ChatRoomChanged(event)));
    emit(ChatRoomAvailable(
      sender: state.sender!,
      chatRoom: event.chatRoom,
      messages: event.messages,
    ));
  }

  void _handleChatMessageAdded(event, emit) {
    if (state is! ChatRoomAvailable) {
      logger.warn(
          "State transition 'ChatMessageAdded' is only valid from state 'ChatRoomAvailable'");
      return;
    }

    emit(ChatRoomAvailable(
      sender: state.sender!,
      chatRoom: state.chatRoom!,
      messages: [...state.messages, event.message],
    ));
  }

  Future<void> _handleChatRoomSelected(
    ChatRoomSelected event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatRoomAvailable && state is! ChatUserAvailable) {
      logger.warn(
          "State transition 'ChatRoomSelected' is only valid from either 'ChatRoomAvailable' or 'ChatUserAvailable'");
      return;
    }

    messageSubscription?.cancel();
    metadataSubscription?.cancel();

    emit(ChatUserAvailable(sender: state.sender!));
    final initialState = await repository.getChatRoom(event.chatRoomId);
    add(ChatRoomRetrieved(
      chatRoom: initialState.metadata,
      messages: initialState.messages,
    ));
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:cloud_chat/chat/bloc/models/chat_room_option.dart';
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
        emit(ChatUserAvailable(
          sender: event.user,
          chatRoomOptions: event.chatRoomOptions,
        ));
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
        messages: state.messages,
        chatRoomOptions: state.chatRoomOptions,
      )),
    );
    on<ChatTextSent>(_handleChatTextSent);

    userSubscription = repository.getUserStream().listen((event) =>
        event.user != null
            ? add(ChatLogin(event.user!, event.chatRoomOptions!))
            : add(ChatLogout()));
  }

  void _handleChatTextSent(event, emit) {
    if (state is! ChatRoomAvailable) {
      logger.warn(
          "State transition 'ChatTextSent' is only valid from state 'ChatRoomAvailable'");
      return;
    }
    repository.createMessage(
      state.chatRoom!.chatRoomId,
      ChatMessage(
        text: event.message,
        userId: state.sender!.userId,
        timestamp: DateTime.now(),
      ),
    );
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
      chatRoomOptions: state.chatRoomOptions,
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
      chatRoomOptions: state.chatRoomOptions,
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

    emit(ChatUserAvailable(
      sender: state.sender!,
      chatRoomOptions: state.chatRoomOptions
          .map((e) => ChatRoomOption(
                isSelected: e.chatRoomId == event.chatRoomId,
                chatRoomId: e.chatRoomId,
                name: e.name,
              ))
          .toList(),
    ));
    final initialState = await repository.getChatRoom(event.chatRoomId);
    add(ChatRoomRetrieved(
      chatRoom: initialState.metadata,
      messages: initialState.messages,
    ));
  }

  @override
  Future<void> close() {
    userSubscription.cancel();
    messageSubscription?.cancel();

    return super.close();
  }
}

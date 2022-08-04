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

  ChatBloc({
    required this.logger,
    required this.repository,
  }) : super(const ChatInitial()) {
    on<ChatLogin>(
      (event, emit) => emit(ChatUserAvailable(sender: event.user)),
    );
    on<ChatLogout>(
      (event, emit) => emit(const ChatInitial()),
    );
    on<ChatRoomRetrieved>(
      (event, emit) => emit(ChatRoomAvailable(
        sender: state.sender!,
        chatRoom: event.chatRoom,
        messages: event.messages,
      )),
    );
    on<ChatRoomSelected>(_handleChatRoomSelected);
    on<ChatMessageAdded>(_handleChatMessageAdded);
    on<ChatRoomChanged>(
      (event, emit) => emit(ChatRoomAvailable(
          sender: state.sender!,
          chatRoom: event.chatRoom,
          messages: state.messages)),
    );
  }

  void _handleChatMessageAdded(event, emit) {
    if (state is! ChatRoomAvailable) return;
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
    final initialState
  }
}

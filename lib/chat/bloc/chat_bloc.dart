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

  StreamSubscription? roomSubscription;
  late final StreamSubscription userSubscription;

  ChatBloc({
    required this.logger,
    required this.repository,
  }) : super(const ChatInitial()) {
    on<ChatLogin>(_handleLogin);
    on<ChatLogout>(_handleLogout);
    on<ChatRoomRetrieved>(_handleChatRoomRetrieved);
    on<ChatRoomSelected>(_handleChatRoomSelected);
    on<ChatRoomChanged>(_handleChatRoomChange);
    on<ChatTextSent>(_handleChatTextSent);
    on<ChatEditRequested>(_handleChatEditRequest);
    on<ChatEditCompleted>(_handleChatRoomEditCompleted);
    on<ChatAllUsersRetrieved>(_handleAllUsersRetrieved);
    on<ChatUserChanged>(_handleChatUserChanged);
    userSubscription = repository.getUserStream().listen((event) {
      print("User Changed");
      add(ChatUserChanged(
        chatRoomOptions: event.chatRoomOptions,
        user: event.user,
      ));
    });
  }

  void _handleChatUserChanged(ChatUserChanged event, Emitter<ChatState> emit) {
    if (event.user == null) {
      add(ChatLogout());
      return;
    }

    final selectedChatRoom = state.chatRoomOptions.where((e) => e.isSelected);
    final chatRoomOptions = selectedChatRoom.isEmpty
        ? event.chatRoomOptions!
        : event.chatRoomOptions!
            .map(
              (e) => ChatRoomOption(
                isSelected: e.chatRoomId == selectedChatRoom.single.chatRoomId,
                chatRoomId: e.chatRoomId,
                name: e.name,
              ),
            )
            .toList();

    if (state is ChatInitial) {
      add(ChatLogin(
        user: event.user!,
        chatRoomOptions: chatRoomOptions,
      ));
      return;
    }

    if (state is ChatRoomAvailable) {
      emit(ChatRoomAvailable(
        sender: event.user!,
        chatRoom: state.chatRoom,
        messages: state.messages,
        chatRoomOptions: chatRoomOptions,
      ));
      return;
    }

    if (state is ChatUserAvailable) {
      emit(ChatUserAvailable(
        sender: event.user!,
        chatRoomOptions: chatRoomOptions,
      ));
      return;
    }

    if (state is ChatRoomEditMode) {
      emit(ChatRoomEditMode(
        sender: event.user!,
        chatRoom: state.chatRoom,
        messages: state.messages,
        chatRoomOptions: chatRoomOptions,
        allUsers: (state as ChatRoomEditMode).allUsers,
      ));
    }
  }

  void _handleAllUsersRetrieved(event, emit) {
    if (state is ChatUserAvailable) {
      emit(ChatUserAvailable(
        sender: state.sender!,
        chatRoomOptions: state.chatRoomOptions,
      ));
      return;
    }

    if (state is ChatUserAvailable) {
      emit(ChatUserAvailable(
        sender: state.sender!,
        chatRoomOptions: state.chatRoomOptions,
      ));
      return;
    }
  }

  void _handleLogin(event, emit) {
    emit(ChatUserAvailable(
      sender: event.user,
      chatRoomOptions: event.chatRoomOptions,
    ));
  }

  void _handleLogout(event, emit) => emit(const ChatInitial());

  Future<void> _handleChatRoomEditCompleted(
      ChatEditCompleted event, Emitter<ChatState> emit) async {
    if (event.metadata != null) {
      await repository.updateChatRoom(event.metadata!);
      emit(ChatRoomAvailable(
        sender: state.sender!,
        chatRoom: event.metadata!,
        messages: state.messages,
        chatRoomOptions: state.chatRoomOptions,
      ));
      return;
    }
    emit(ChatRoomAvailable(
      sender: state.sender!,
      chatRoom: state.chatRoom!,
      messages: state.messages,
      chatRoomOptions: state.chatRoomOptions,
    ));
  }

  void _handleChatEditRequest(event, emit) =>
      repository.getAllUsers().then((value) => emit(ChatRoomEditMode(
          sender: state.sender!,
          chatRoom: event.metadata,
          messages: state.messages,
          chatRoomOptions: state.chatRoomOptions,
          allUsers: value)));

  void _handleChatRoomChange(event, emit) => emit(ChatRoomAvailable(
        sender: state.sender!,
        chatRoom: event.chatRoom,
        messages: state.messages,
        chatRoomOptions: state.chatRoomOptions,
      ));

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
    if (state is! ChatUserAvailable && state is! ChatRoomAvailable) {
      logger.warn(
          "State transition 'ChatRoomRetrieved' is only valid from state 'ChatUserAvailable' or 'ChatRoomAvailable'");
      return;
    }

    roomSubscription ??= repository
        .getChatRoomStream(event.chatRoom.chatRoomId)
        .listen((event) => add(ChatRoomRetrieved(
              chatRoom: event.metadata,
              messages: event.messages,
            )));

    emit(ChatRoomAvailable(
      sender: state.sender!,
      chatRoom: event.chatRoom,
      messages: event.messages,
      chatRoomOptions: state.chatRoomOptions,
    ));
  }

  Future<void> _handleChatRoomSelected(
    ChatRoomSelected event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatRoomAvailable &&
        state is! ChatUserAvailable &&
        state is! ChatRoomEditMode) {
      logger.warn(
          "State transition 'ChatRoomSelected' is only valid from either 'ChatRoomAvailable', 'ChatUserAvailable' or 'ChatRoomEditMode'");
      return;
    }

    roomSubscription?.cancel();

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
    roomSubscription?.cancel();

    return super.close();
  }
}

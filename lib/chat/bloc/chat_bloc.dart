import 'package:bloc/bloc.dart';
import 'package:cloud_chat/models/message.dart';
import 'package:meta/meta.dart';

import '../../models/user.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

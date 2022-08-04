import 'package:cloud_chat/bloc_observer.dart';
import 'package:cloud_chat/cloud_chat_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => BlocOverrides.runZoned(
      () => runApp(const CloudChatApp()),
      blocObserver: ConsoleBlocObserver(),
    );

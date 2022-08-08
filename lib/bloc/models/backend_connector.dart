import 'package:cloud_chat/bloc/authentification_repository.dart';
import 'package:cloud_chat/chat/bloc/chat_repository.dart';
import 'package:flutter/material.dart';

@immutable
class BackendConnector {
  final String name;
  final String assetName;
  final ChatRepository Function() chatRepositoryFactory;
  final AuthenticationRepository Function() authenticationRepository;

  const BackendConnector({
    required this.name,
    required this.assetName,
    required this.chatRepositoryFactory,
    required this.authenticationRepository,
  });
}

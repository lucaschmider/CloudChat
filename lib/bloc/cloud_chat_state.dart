part of 'cloud_chat_bloc.dart';

@immutable
abstract class CloudChatState {
  final List<BackendConnector> availableConnectors;
  final BackendConnector? connector;
  final bool isLoading;

  const CloudChatState({
    this.connector,
    required this.isLoading,
    required this.availableConnectors,
  });
}

class CloudChatInitial extends CloudChatState {
  const CloudChatInitial()
      : super(
          isLoading: false,
          availableConnectors: const [],
        );
}

class CloudChatConnectorsKnown extends CloudChatState {
  const CloudChatConnectorsKnown({
    required super.availableConnectors,
  }) : super(isLoading: false);
}

class CloudChatConnected extends CloudChatState {
  const CloudChatConnected({
    required super.availableConnectors,
    required super.connector,
    required super.isLoading,
  });
}

class CloudChatSignedIn extends CloudChatState {
  const CloudChatSignedIn({
    required super.availableConnectors,
    required super.connector,
    required super.isLoading,
  });
}

class CloudChatProfileCompletion extends CloudChatState {
  const CloudChatProfileCompletion({
    required super.availableConnectors,
    required super.connector,
    required super.isLoading,
  });
}

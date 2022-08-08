part of 'cloud_chat_bloc.dart';

@immutable
abstract class CloudChatEvent {
  const CloudChatEvent();
}

@immutable
class CloudChatBackendConnectorsRetrieved extends CloudChatEvent {
  final List<BackendConnector> availableConnectors;
  const CloudChatBackendConnectorsRetrieved(this.availableConnectors);
}

@immutable
class CloudChatBackendSelected extends CloudChatEvent {
  final String name;
  const CloudChatBackendSelected(this.name);
}

@immutable
class CloudChatPasswordLoginRequested extends CloudChatEvent {
  final String username;
  final String password;
  const CloudChatPasswordLoginRequested(
    this.username,
    this.password,
  );
}

@immutable
class CloudChatGoogleLoginRequested extends CloudChatEvent {}

@immutable
class CloudChatSignOutRequested extends CloudChatEvent {}

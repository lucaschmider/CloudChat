import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_chat/bloc/authentification_repository.dart';
import 'package:cloud_chat/bloc/backend_connector_repository.dart';
import 'package:cloud_chat/bloc/models/backend_connector.dart';
import 'package:flutter/foundation.dart';

import '../logger.dart';

part 'cloud_chat_event.dart';
part 'cloud_chat_state.dart';

class CloudChatBloc extends Bloc<CloudChatEvent, CloudChatState> {
  final BackendConnectorRepository connectorRepository;
  final Logger logger;
  StreamSubscription? signOutSubscription;
  AuthentificationRepository? authentificationRepository;

  CloudChatBloc({
    required this.connectorRepository,
    required this.logger,
  }) : super(const CloudChatInitial()) {
    on<CloudChatBackendConnectorsRetrieved>(_handleConnectorsRetrieved);
    on<CloudChatBackendSelected>(_handleBackendSelection);
    on<CloudChatPasswordLoginRequested>(_handlePasswordLogin);
    on<CloudChatGoogleLoginRequested>(_handleGoogleLogin);
    on<CloudChatSignOutRequested>(_handleSignOut);

    initialize();
  }

  void _handleSignOut(event, emit) async {
    if (state is! CloudChatSignedIn) {
      logger.warn(
          "State transition 'CloudChatSignOutRequested' is only valid from state 'CloudChatSignedIn.'");
      return;
    }

    emit(CloudChatSignedIn(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: true,
    ));

    await authentificationRepository!.signOut();

    emit(CloudChatConnected(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: false,
    ));
  }

  void _handleGoogleLogin(event, emit) async {
    if (authentificationRepository == null) {
      logger.warn(
          "State transition 'CloudChatGoogleLoginRequested' is only valid while a backend is selected.");
      return;
    }

    emit(CloudChatConnected(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: true,
    ));

    await authentificationRepository!.signInWithGoogleAsync();

    emit(CloudChatSignedIn(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: false,
    ));
  }

  void _handlePasswordLogin(event, emit) async {
    if (authentificationRepository == null) {
      logger.warn(
          "State transition 'CloudChatPasswordLoginRequested' is only valid while a backend is selected.");
      return;
    }

    emit(CloudChatConnected(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: true,
    ));

    await authentificationRepository!
        .signInWithUsernameAndPasswordAsync(event.username, event.password);

    emit(CloudChatSignedIn(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: false,
    ));
  }

  void _handleBackendSelection(event, emit) {
    if (state.availableConnectors.isEmpty) {
      logger.warn(
          "State transition 'CloudChatBackendSelected' is only valid while connectors are known.");
      return;
    }

    signOutSubscription?.cancel();
    final connector =
        state.availableConnectors.singleWhere((con) => con.name == event.name);
    authentificationRepository = connector.authentificationRepository();

    signOutSubscription = authentificationRepository!
        .createSignOutStream()
        .listen((_) => add(CloudChatSignOutRequested()));

    emit(CloudChatConnected(
      availableConnectors: state.availableConnectors,
      connector: connector,
      isLoading: false,
    ));
  }

  void _handleConnectorsRetrieved(event, emit) {
    if (state is! CloudChatInitial) {
      logger.warn(
          "State transition 'CloudChatBackendConnectorsRetrieved' is only valid from state 'CloudChatInitial'");
      return;
    }
    emit(CloudChatConnectorsKnown(
        availableConnectors: event.availableConnectors));
  }

  void initialize() {
    final availableConnectors = connectorRepository.getAvailableConnectors();
    add(CloudChatBackendConnectorsRetrieved(availableConnectors));
  }

  @override
  Future<void> close() {
    signOutSubscription?.cancel();
    return super.close();
  }
}
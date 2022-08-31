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
  AuthenticationRepository? authentificationRepository;

  CloudChatBloc({
    required this.connectorRepository,
    required this.logger,
  }) : super(const CloudChatInitial()) {
    on<CloudChatBackendConnectorsRetrieved>(_handleConnectorsRetrieved);
    on<CloudChatBackendSelected>(_handleBackendSelection);
    on<CloudChatPasswordLoginRequested>(_handlePasswordLogin);
    on<CloudChatSignOutRequested>(_handleSignOut);
    on<CloudChatProfileCompleted>(_handleProfileCompletion);
    on<CloudChatUserCreated>(_handleUserCreation);

    initialize();
  }

  void _handleUserCreation(
    CloudChatUserCreated event,
    Emitter<CloudChatState> emit,
  ) async {
    if (authentificationRepository == null) {
      logger.warn(
          "State transition 'CloudChatUserCreated' is only valid while a backend is selected.");
      return;
    }

    emit(CloudChatConnected(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: true,
    ));

    await authentificationRepository!
        .signUpWithUsernameAndPassword(event.username, event.password);

    final isProfileCompleted =
        await authentificationRepository!.isCurrentProfileCompleted();

    if (isProfileCompleted) {
      emit(CloudChatSignedIn(
        availableConnectors: state.availableConnectors,
        connector: state.connector,
        isLoading: false,
      ));
      return;
    }

    emit(CloudChatProfileCompletion(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: false,
    ));
  }

  void _handleProfileCompletion(
    CloudChatProfileCompleted event,
    Emitter<CloudChatState> emit,
  ) async {
    if (state is! CloudChatProfileCompletion) {
      logger.warn(
          "State transition 'CloudChatProfileCompleted' is only valid from state 'CloudChatProfileCompletion.'");
      return;
    }

    emit(CloudChatProfileCompletion(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: true,
    ));

    await authentificationRepository!.setFullName(event.fullName);

    emit(CloudChatSignedIn(
      availableConnectors: state.availableConnectors,
      connector: state.connector,
      isLoading: false,
    ));
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

    final isProfileCompleted =
        await authentificationRepository!.isCurrentProfileCompleted();

    if (isProfileCompleted) {
      emit(CloudChatSignedIn(
        availableConnectors: state.availableConnectors,
        connector: state.connector,
        isLoading: false,
      ));
      return;
    }

    emit(CloudChatProfileCompletion(
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
    final connector = state.availableConnectors
        .singleWhere((con) => con.name == event.userId);
    authentificationRepository = connector.authenticationRepository();

    signOutSubscription = authentificationRepository!
        .createSignOutStream()
        .listen((_) => add(CloudChatSignOutRequested()));

    emit(CloudChatConnected(
      availableConnectors: state.availableConnectors,
      connector: connector,
      isLoading: false,
    ));

    add(CloudChatPasswordLoginRequested(
        "max.mustermann@gmail.com", "12345678"));
  }

  void _handleConnectorsRetrieved(event, emit) {
    if (state is! CloudChatInitial) {
      logger.warn(
          "State transition 'CloudChatBackendConnectorsRetrieved' is only valid from state 'CloudChatInitial'");
      return;
    }
    emit(
      CloudChatConnectorsKnown(availableConnectors: event.availableConnectors),
    );
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

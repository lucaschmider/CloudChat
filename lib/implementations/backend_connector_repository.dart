import 'package:cloud_chat/bloc/backend_connector_repository.dart';
import 'package:cloud_chat/console_logger.dart';
import 'package:cloud_chat/implementations/appwrite/appwrite_repository.dart';
import 'package:cloud_chat/implementations/backendless/backendless_repository.dart';

import '../bloc/models/backend_connector.dart';
import 'firebase_repository.dart';

class BackendConnectorRegistry implements BackendConnectorRepository {
  @override
  List<BackendConnector> getAvailableConnectors() {
    return [
      BackendConnector(
        name: "Backendless",
        assetName: "anchor.svg",
        chatRepositoryFactory: () => BackendlessRepository(ConsoleLogger()),
        authenticationRepository: () => BackendlessRepository(ConsoleLogger()),
      ),
      BackendConnector(
        name: "Firebase",
        assetName: "layers.svg",
        chatRepositoryFactory: () => FirebaseRepository(),
        authenticationRepository: () => FirebaseRepository(),
      ),
      BackendConnector(
        name: "Appwrite",
        assetName: "layers.svg",
        chatRepositoryFactory: () => AppwriteRepository(),
        authenticationRepository: () => AppwriteRepository(),
      ),
    ];
  }
}

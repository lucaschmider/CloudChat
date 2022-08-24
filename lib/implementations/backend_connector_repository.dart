import 'package:cloud_chat/bloc/backend_connector_repository.dart';

import '../bloc/models/backend_connector.dart';
import 'firebase_repository.dart';

class BackendConnectorRegistry implements BackendConnectorRepository {
  @override
  List<BackendConnector> getAvailableConnectors() {
    return [
      BackendConnector(
        name: "Mocked",
        assetName: "anchor.svg",
        chatRepositoryFactory: () => FirebaseRepository(),
        authenticationRepository: () => FirebaseRepository(),
      ),
      BackendConnector(
        name: "Firebase",
        assetName: "layers.svg",
        chatRepositoryFactory: () => FirebaseRepository(),
        authenticationRepository: () => FirebaseRepository(),
      ),
    ];
  }
}

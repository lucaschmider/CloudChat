import 'package:cloud_chat/bloc/backend_connector_repository.dart';
import 'package:cloud_chat/console_logger.dart';
import 'package:cloud_chat/implementations/appwrite/appwrite_repository.dart';
import 'package:cloud_chat/implementations/backendless/backendless_repository.dart';
import 'package:cloud_chat/implementations/supabase/supabase_repository.dart';
import 'package:cloud_chat/logger.dart';

import '../bloc/models/backend_connector.dart';
import 'firebase_repository.dart';

class BackendConnectorRegistry implements BackendConnectorRepository {
  static const Logger _logger = ConsoleLogger();

  @override
  List<BackendConnector> getAvailableConnectors() {
    return [
      BackendConnector(
        name: "Backendless",
        assetName: "backendless.svg",
        chatRepositoryFactory: () =>
            Future.value(BackendlessRepository(_logger)),
        authenticationRepository: () =>
            Future.value(BackendlessRepository(_logger)),
      ),
      BackendConnector(
        name: "Firebase",
        assetName: "Firebase_Logo.svg",
        chatRepositoryFactory: () => Future.value(FirebaseRepository()),
        authenticationRepository: () => Future.value(FirebaseRepository()),
      ),
      BackendConnector(
        name: "Appwrite",
        assetName: "appwrite.svg",
        chatRepositoryFactory: () =>
            Future.value(AppwriteRepository.getInstance(_logger)),
        authenticationRepository: () =>
            Future.value(AppwriteRepository.getInstance(_logger)),
      ),
      BackendConnector(
        name: "Supabase",
        assetName: "supabase-logo-vector.svg",
        chatRepositoryFactory: () => SupabaseRepository.getInstance(),
        authenticationRepository: () => SupabaseRepository.getInstance(),
      ),
    ];
  }
}

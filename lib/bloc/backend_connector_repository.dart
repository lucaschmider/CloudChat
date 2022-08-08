import 'package:cloud_chat/bloc/models/backend_connector.dart';

abstract class BackendConnectorRepository {
  List<BackendConnector> getAvailableConnectors();
}

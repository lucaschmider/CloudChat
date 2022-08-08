import 'package:cloud_chat/bloc/models/backend_connector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';

class BackendSelector extends StatelessWidget {
  final List<BackendConnector> connectors;
  final void Function(BackendConnector selection) onBackendSelected;

  const BackendSelector({
    Key? key,
    required this.connectors,
    required this.onBackendSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        children: connectors
            .map(
              (e) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Tooltip(
                  message: e.name,
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all()),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SvgPicture.asset("assets/${e.assetName}"),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      );
}

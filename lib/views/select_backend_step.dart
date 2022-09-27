import 'package:cloud_chat/bloc/models/backend_connector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SelectBackendStep extends StatefulWidget {
  final List<BackendConnector> connectors;
  final void Function(BackendConnector selection) onBackendSelected;

  const SelectBackendStep({
    Key? key,
    required this.connectors,
    required this.onBackendSelected,
  }) : super(key: key);

  @override
  State<SelectBackendStep> createState() => _SelectBackendStepState();
}

class _SelectBackendStepState extends State<SelectBackendStep> {
  BackendConnector? selection;

  @override
  Widget build(BuildContext context) => selection == null
      ? Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.connectors
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _BackendSelectorButton(
                    onClick: () {
                      setState(() {
                        selection = e;
                      });
                      widget.onBackendSelected(e);
                    },
                    connector: e,
                  ),
                ),
              )
              .toList(),
        )
      : _BackendSelectorButton(connector: selection!);
}

class _BackendSelectorButton extends StatefulWidget {
  final BackendConnector connector;
  final void Function()? onClick;

  const _BackendSelectorButton({
    Key? key,
    required this.connector,
    this.onClick,
  }) : super(key: key);

  @override
  State<_BackendSelectorButton> createState() => _BackendSelectorButtonState();
}

class _BackendSelectorButtonState extends State<_BackendSelectorButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final buttonContent = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      constraints: const BoxConstraints.expand(
        height: 100,
        width: 100,
      ),
      decoration: BoxDecoration(
        color: isHovered
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SvgPicture.asset(
          "assets/${widget.connector.assetName}",
          color: isHovered
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );

    if (widget.onClick == null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: buttonContent,
      );
    }

    return GestureDetector(
      onTap: widget.onClick,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 150),
              turns: isHovered ? 0.02 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: isHovered ? 1.1 : 1.0,
                child: buttonContent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.connector.name),
            ),
          ],
        ),
      ),
    );
  }
}

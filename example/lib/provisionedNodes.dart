import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ProvisionedNodes extends StatefulWidget {
  DiscoveredDevice device;
  ProvisionedNodes(this.device, {super.key});
  @override
  State<ProvisionedNodes> createState() => _ProvisionedNodesState();
}

class _ProvisionedNodesState extends State<ProvisionedNodes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provisioned Nodes'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(widget.device.name),
            subtitle: Text(widget.device.id),
          ),
        ],
      ),
    );
  }
}

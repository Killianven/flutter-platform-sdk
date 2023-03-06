import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:golain_example/scanbloc/scan_bloc.dart';

class ProvisionedNodes extends StatefulWidget {
  DiscoveredDevice device;
  ProvisionedNodes(this.device, {super.key});
  @override
  State<ProvisionedNodes> createState() => _ProvisionedNodesState();
}

class _ProvisionedNodesState extends State<ProvisionedNodes> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ScanBloc>(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Provisioned Nodes'),
        ),
        body: Column(
          children: [
            ListTile(
              title: Text(widget.device.name),
              subtitle: Text(widget.device.id),
            ),
            ElevatedButton(
                onPressed: () async {
                  BlocProvider.of<ScanBloc>(context).add(ConnectToDevice());
                },
                child: Text('Connect to ${widget.device.name}')),
            BlocBuilder<ScanBloc, ScanState>(builder: (context, state) {
              if (state is ConnectedDevice) {
                return Text(state.message);
              } else if (state is ConnectionFailure) {
                return Text(state.message);
              } else {
                return const Text('Not Connected');
              }
            }),
          ],
        ),
      ),
    );
  }
}

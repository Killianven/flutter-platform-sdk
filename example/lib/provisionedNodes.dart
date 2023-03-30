import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:golain_example/scanbloc/scan_bloc.dart';

import 'vendor_model.dart';

class ProvisionedNodes extends StatefulWidget {
  final DiscoveredDevice device;
  const ProvisionedNodes(this.device, {super.key});
  @override
  State<ProvisionedNodes> createState() => _ProvisionedNodesState();
}

class _ProvisionedNodesState extends State<ProvisionedNodes> {
  List<DiscoveredDevice> provisionedDevices = [];
  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanBloc, ScanState>(
      listener: (context, state) {
        if (state is ProvisionedDevices) {
          provisionedDevices = state.provisionedDevices;
        }
        if (state is ConnectedDevice) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VendorModel(),
            ),
          );
        }
        if (state is LoadingState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loading...'),
            ),
          );
        }
      },
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
              onPressed: () {
                BlocProvider.of<ScanBloc>(context).add(
                  ProvisionedDevicesRequested(),
                );
              },
              child: const Text(
                'Scan for provisioned nodes',
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  BlocProvider.of<ScanBloc>(context).add(
                    ConnectToDevice(widget.device),
                  );
                },
                child: Text('Connect to ${widget.device.name}')),
            BlocBuilder<ScanBloc, ScanState>(
              builder: (context, state) {
                if (state is LoadingState) {
                  return const CircularProgressIndicator();
                }
                if (state is ConnectedDevice) {
                  return Text(state.message);
                } else if (state is ProvisionedDevices) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: state.provisionedDevices.length,
                    itemBuilder: (context, index) {
                      final provisionedDevices = state.provisionedDevices;
                      return ListTile(
                        title: Text(provisionedDevices[index].name),
                        subtitle: Text(provisionedDevices[index].id),
                      );
                    },
                  );
                } else if (state is ConnectionFailure) {
                  return Text(state.message);
                } else {
                  return const Text('Not Connected');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

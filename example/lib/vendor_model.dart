import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:golain_example/vendor_model_rgb.dart';

import 'protobuf/rgb_on_off/rgb_on_off.pb.dart';
import 'scanbloc/scan_bloc.dart';

class VendorModel extends StatelessWidget {
  final DiscoveredDevice device;
  const VendorModel(this.device, {super.key});
  @override
  Widget build(BuildContext context) {
    TextEditingController dataPlaneController = TextEditingController();
    TextEditingController dataPlaneElementAddressController =
        TextEditingController();
    TextEditingController controlPlaneElementAddressController =
        TextEditingController();
    TextEditingController deprovisionElementAddressController =
        TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Model'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Node Details',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          BlocConsumer<ScanBloc, ScanState>(listener: (context, state) {
            if (state is VendorModelDataFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Vendor Model Message: ${state.error}'),
                ),
              );
            }
            if (state is VendorModelControlGetSuccess) {
              final message = shadow.fromBuffer(state.data.message.toList());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Vendor Model Message: $message'),
                ),
              );
            }
            if (state is VendorModelControlFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Vendor Model Message: ${state.error}'),
                ),
              );
            }

            if (state is DeprovisioningSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }

            if (state is DeprovisioningFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          }, builder: (context, state) {
            return Expanded(
              child: SizedBox(
                height: 200,
                child: ListView(children: [
                  ExpansionTile(
                    title: const Text('Vendor Model Data plane '),
                    children: [
                      TextField(
                        decoration:
                            const InputDecoration(hintText: 'Element Address'),
                        controller: dataPlaneElementAddressController,
                      ),
                      TextField(
                        decoration: const InputDecoration(
                            hintText: 'Data Request Type'),
                        controller: dataPlaneController,
                      ),
                      TextButton(
                        onPressed: () async {
                          BlocProvider.of<ScanBloc>(context).add(
                            VendorModelDataGetRequested(
                              int.parse(dataPlaneElementAddressController.text),
                              dataPlaneController.text,
                            ),
                          );
                        },
                        child: const Text('Get'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("Vendor Mode Control Plane"),
                    children: [
                      TextField(
                        key:
                            const ValueKey('module-send-generic-level-address'),
                        decoration:
                            const InputDecoration(hintText: 'Element Address'),
                        controller: controlPlaneElementAddressController,
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RGBProtobuf(
                                selectedElementAddress: int.parse(
                                    controlPlaneElementAddressController.text),
                              ),
                            ),
                          );
                        },
                        child: const Text('Set'),
                      ),
                      TextButton(
                        onPressed: () async {
                          BlocProvider.of<ScanBloc>(context).add(
                            VendorModelControlGetRequested(
                              int.parse(
                                  controlPlaneElementAddressController.text),
                              Uint8List(0),
                            ),
                          );
                        },
                        child: const Text('Get'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    key: const ValueKey('module-send-deprovisioning-form'),
                    title: const Text('Send a deprovisioning'),
                    children: <Widget>[
                      TextField(
                        key: const ValueKey(
                            'module-send-deprovisioning-address'),
                        decoration:
                            const InputDecoration(hintText: 'Element Address'),
                        controller: deprovisionElementAddressController,
                      ),
                      TextButton(
                        onPressed: () {
                          BlocProvider.of<ScanBloc>(context).add(
                            DeprovisioningRequested(
                              int.parse(
                                  deprovisionElementAddressController.text),
                            ),
                          );
                        },
                        child: const Text('Send node reset'),
                      )
                    ],
                  )
                ]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

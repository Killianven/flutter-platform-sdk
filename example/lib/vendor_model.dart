import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'protobuf/rgb_on_off/rgb_on_off.pb.dart';
import 'scanbloc/scan_bloc.dart';
import 'vendor_model_rgb.dart';

class VendorModel extends StatelessWidget {
  const VendorModel({super.key});
  @override
  Widget build(BuildContext context) {
    TextEditingController dataPlaneController = TextEditingController();
    TextEditingController dataPlaneElementAddressController =
        TextEditingController();
    TextEditingController controlPlaneElementAddressController =
        TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Model'),
      ),
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is VendorModelDataGetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vendor Model Message: ${state.data.message}'),
              ),
            );
          }
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
        },
        builder: (context, state) {
          return ListView(
            children: [
              ExpansionTile(
                title: const Text('Vendor Model Data plane '),
                children: [
                  TextField(
                    decoration:
                        const InputDecoration(hintText: 'Element Address'),
                    controller: dataPlaneElementAddressController,
                  ),
                  TextField(
                    decoration:
                        const InputDecoration(hintText: 'Data Request Type'),
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
                    key: const ValueKey('module-send-generic-level-address'),
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
                          int.parse(controlPlaneElementAddressController.text),
                          Uint8List(0),
                        ),
                      );
                    },
                    child: const Text('Get'),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
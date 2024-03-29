import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:golain_example/provisionedNodes.dart';
import 'package:golain_example/scanbloc/scan_bloc.dart';

class Scanning extends StatelessWidget {
  const Scanning({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () async {
              BlocProvider.of<ScanBloc>(context).add(PermissionRequested());
            },
            child: const Text('Ask for permission'),
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<ScanBloc>(context).add(ResetMeshNetwork());
            },
            child: const Text('Reset Mesh Network'),
          ),
          ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                if (result != null) {
                  File file = File(result.files.single.path!);
                  BlocProvider.of<ScanBloc>(context)
                      .add(ImportMeshNetwork(file));
                }
              },
              child: const Text('Import Mesh Network')),
          ElevatedButton(
            child: const Text('Export mesh network'),
            onPressed: () async {
              BlocProvider.of<ScanBloc>(context).add(ExportMeshNetwork());
            },
          ),
          BlocBuilder<ScanBloc, ScanState>(builder: (context, state) {
            if (state is ExportMeshNetworkSuccess) {
              log(state.message);
            }
            return const Text('');
          }),
          ElevatedButton(
            onPressed: () async {
              BlocProvider.of<ScanBloc>(context).add(ScanRequested());
            },
            child: const Text('Scan for devices'),
          ),
          BlocConsumer<ScanBloc, ScanState>(
            listener: (context, state) {
              if (state is Provisioned) {
                Fluttertoast.showToast(
                    msg: "Provisioned",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProvisionedNodes(state.device),
                  ),
                );
              }
            },
            builder: (context, state) {
              switch (state.runtimeType) {
                case LoadingState:
                  return const CircularProgressIndicator();
                case ScanningSuccess:
                  Fluttertoast.showToast(
                      msg: "Scanning Success",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  final successState = state as ScanningSuccess;
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: successState.scannedDevices.length,
                    itemBuilder: (context, index) {
                      final scannedDevices = (state).scannedDevices;
                      return ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<ScanBloc>(context).add(
                            Provision(scannedDevices[index]),
                          );
                        },
                        child: ListTile(
                          title: Text(scannedDevices[index].name),
                          subtitle: Text(scannedDevices[index].id),
                        ),
                      );
                    },
                  );
                case ScanningFailure:
                  final failureState = state as ScanningFailure;
                  Fluttertoast.showToast(
                      msg: failureState.message.toString(),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  return Text(failureState.message.toString());
                default:
                  return const Text('No state');
              }
            },
          ),
        ],
      ),
    );
  }
}

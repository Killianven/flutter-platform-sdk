import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              BlocProvider.of<ScanBloc>(context).add(ScanRequested());
            },
            child: const Text('Scan for devices'),
          ),
          BlocConsumer<ScanBloc, ScanState>(
            listener: (context, state) {
              if (state is Provisioned) {
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

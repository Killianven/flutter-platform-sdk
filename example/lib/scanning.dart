import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golain_example/provisionedNodes.dart';
import 'package:golain_example/scanbloc/scan_bloc.dart';

class Scanning extends StatefulWidget {
  const Scanning({super.key});

  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  // @override
  // void dispose() {
  //   BlocProvider.of(context).close();
  //   super.dispose();
  // }

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
            onPressed: () async {
              BlocProvider.of<ScanBloc>(context).add(ScanRequested());
            },
            child: const Text('Scan for devices'),
          ),
          BlocBuilder<ScanBloc, ScanState>(builder: (context, state) {
            switch (state.runtimeType) {
              case ScanningInProgress:
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
                        BlocProvider.of<ScanBloc>(context)
                            .add(Provision(scannedDevices[index]));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProvisionedNodes(scannedDevices[index])));
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
          }),
        ],
      ),
    );
  }
}

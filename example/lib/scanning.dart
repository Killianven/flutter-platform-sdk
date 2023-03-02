import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golain/golain.dart';
import 'package:golain_example/provisionedNodes.dart';
import 'package:golain_example/scanbloc/scan_bloc.dart';

class Scanning extends StatefulWidget {
  const Scanning({super.key});

  @override
  State<Scanning> createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {

  @override
  void dispose() {
    BlocProvider.of(context).close();
    super.dispose();
  }

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
            if (state is ScanningInProgress) {
              return const CircularProgressIndicator();
            } else if (state is ScanningSuccess) {
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: state.scannedDevices.length,
                itemBuilder: (context, index) {
                  return 
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<ScanBloc>(context)
                          .add(Provision(state.scannedDevices[index]));
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ProvisionedNodes(state.scannedDevices[index])));
                    },
                    child: ListTile(
                      title: Text(state.scannedDevices[index].name),
                      subtitle: Text(state.scannedDevices[index].id),
                    ),
                  );
                },
              );
            } else if (state is ScanningFailure) {
              return Text(state.message.toString());
            } else {
              return const Text('No state');
            }
          }),
        ],
      ),
    );
  }
}

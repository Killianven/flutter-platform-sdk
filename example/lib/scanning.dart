import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golain_example/scanbloc/scan_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class Scanning extends StatefulWidget {
  const Scanning({super.key});

  @override
  State<Scanning> createState() => _ScanningState();
}




class _ScanningState extends State<Scanning> {

 @override
  void dispose() {
    // TODO: implement dispose
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

              // print(await _golainPlugin.scanUnprovisionedDevices().then((value)=>value.toString()));
              // await _golainPlugin.scanUnprovisionedDevices().then((value) {
              //   log(value.toString());
              // });
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
                  return ListTile(
                    title: Text(state.scannedDevices[index].name),
                    subtitle: Text(state.scannedDevices[index].id),
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



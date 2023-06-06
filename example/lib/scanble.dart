import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get_it/get_it.dart';
import 'package:golain/golain.dart';
import 'package:golain_example/connectble.dart';
GetIt getIt = GetIt.instance;
class ScanBle extends StatefulWidget {
  const ScanBle({super.key});

  @override
  State<ScanBle> createState() => _ScanBleState();
}

class _ScanBleState extends State<ScanBle> {
  
  Golain golain = getIt<Golain>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: golain.scanBLEDevice([], const Duration(seconds: 10)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap:(){
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ConnectBLE( device: snapshot.data![index])));
                    
                  },
                  child: ListTile(
                    leading: Icon(Icons.bluetooth),
                    title: Text(snapshot.data![index].name),
                    subtitle: Text(snapshot.data![index].id),
                  ),
                );
              },
            );
          } else {
           return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}



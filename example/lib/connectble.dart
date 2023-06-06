import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get_it/get_it.dart';
import 'package:golain/golain.dart';
import 'package:golain_example/servicelist.dart';

GetIt getIt = GetIt.instance;

class ConnectBLE extends StatefulWidget {
  DiscoveredDevice device;

  ConnectBLE({super.key, required this.device});

  @override
  State<ConnectBLE> createState() => _ConnectBLEState();
}

class _ConnectBLEState extends State<ConnectBLE> {
  Golain golain = getIt<Golain>();
  late List<DiscoveredService> services;

  @override
  void initState() {
    services = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text('Device Id : ${widget.device.id}'),
            Text('Device Name : ${widget.device.name}'),
            Text('RSSI : ${widget.device.rssi}'),
            ElevatedButton(
                onPressed: () async {
                  await golain.connectBLEDevice(widget.device);
                  log('Connected');
                },
                child: const Text('Connect')),
            ElevatedButton(
                onPressed: () async {
                  await golain.disconnectBLEDevice(
                      widget.device, const Duration(seconds: 3));
                  log('Disconnected');
                },
                child: const Text('Disconnect')),
            ElevatedButton(
              onPressed: () async {
                var services = await golain.discoverServices(widget.device);

                // ignore: use_build_context_synchronously
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ServiceDiscoveryList(
                    deviceId: widget.device.id,
                    discoveredServices: services,
                  );
                }));

                //log('Services : $services');
                for (var service in services) {
                  log('Service : ${service.serviceId.toString()}');
                  for (var characteristic in service.characteristics) {
                    log('Characteristic : ${characteristic.characteristicId.toString()}');
                  }
                }
                setState(() {
                  this.services = services;
                });
              },
              child: const Text('Discover Services'),
            ),
          ],
        ),
      ),
    );
  }
}

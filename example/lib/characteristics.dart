import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get_it/get_it.dart';
import 'package:golain/golain.dart';
import 'protobuf/rgb_on_off/rgb_on_off.pb.dart';

GetIt getIt = GetIt.instance;

class CharacteristicPage extends StatefulWidget {
  DiscoveredCharacteristic discoveredCharacteristic;
  QualifiedCharacteristic characteristic;

  CharacteristicPage({Key? key, required this.discoveredCharacteristic, required this.characteristic}) : super(key: key);

  @override
  State<CharacteristicPage> createState() => _CharacteristicPageState();
}

class _CharacteristicPageState extends State<CharacteristicPage> {
  Golain golain = getIt<Golain>();
  final TextEditingController _setshadowcontroller = TextEditingController();
  final TextEditingController _deviceAssociation = TextEditingController();
  final TextEditingController _wifiCredentials = TextEditingController();
  late List<int> readOutput;
  late String writeOutput;

  @override
  void initState() {
    readOutput = [];
    writeOutput = '';
    super.initState();
  }

  @override
  void dispose() {
    _setshadowcontroller.dispose();
    _deviceAssociation.dispose();
    _wifiCredentials.dispose();
    super.dispose();
  }

  String _functionCharacteristic(DiscoveredCharacteristic c){
    final props = <String>[];
    if(c.characteristicId.toString()=='00005fda-0000-1000-8000-00805f9b34fb'){
      props.add("Get Shadow");
    }
    if(c.characteristicId.toString()=='00005fdb-0000-1000-8000-00805f9b34fb'){
      props.add("Set Shadow");
    }
    if(c.characteristicId.toString()=='00005fdc-0000-1000-8000-00805f9b34fb'){
      props.add("User association");
    }
    if(c.characteristicId.toString()=='00005fdd-0000-1000-8000-00805f9b34fb'){
      props.add("Wifi credentials");
    }
    return props.join("\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Characteristics'),
      ),
      body: Column(
        children: [
         Text(
            '${_functionCharacteristic(widget.discoveredCharacteristic)}\n${widget.characteristic.characteristicId}',
            style: const TextStyle(
              fontSize: 14,
            ),
         ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(widget.characteristic.serviceId.toString()),

          // ),
          // get shadow
          widget.discoveredCharacteristic.isReadable?

          ElevatedButton(

              onPressed: () async{
                var result = await golain.readCharacteristic(widget.characteristic);
                List<int> values = [];
                values.add(Shadow.fromBuffer(result).red);
                values.add(Shadow.fromBuffer(result).green);
                values.add(Shadow.fromBuffer(result).blue);
                setState(() {
                  readOutput = values;
                });
              },
              child: const Text('Read')) : Container(),
          widget.discoveredCharacteristic.isReadable ?     Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(readOutput.toString()),
          ) : Container(), 
          //  Text(
          //   '${_functionCharacteristic(widget.discoveredCharacteristic)}',
          //   style: const TextStyle(
          //     fontSize: 14,
          //   ),
          // ), 
          //set shadow 
          _functionCharacteristic(widget.discoveredCharacteristic)=='Set Shadow' ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _setshadowcontroller,
              decoration: const InputDecoration(
                labelText: 'Input RGB values, comma separated',
              ),
            ),
          ): Container(),
         
          _functionCharacteristic(widget.discoveredCharacteristic)=='Set Shadow' ?  Padding(
            // Set shadow
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () async {
                    List<String> valueStrings = _setshadowcontroller.text.split(',');
                    List<int> values = valueStrings.map(int.parse).toList();
                    var data= Shadow(
                        red: values[0],
                        green: values[1],
                        blue: values[2],
                    ).writeToBuffer();
                    await golain.writeCharacteristicwithResponse(
                        widget.characteristic, data);
                        setState(() {
                          writeOutput = 'Success';
                        });
                        log('Success');
                  },
                  child: const Text('With response')),
            ),
          ): Container(),
// user association
          _functionCharacteristic(widget.discoveredCharacteristic)=='User association' ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _deviceAssociation,
              decoration: const InputDecoration(
                labelText: 'User id',
              ),
            ),
          ): Container(),
         
          _functionCharacteristic(widget.discoveredCharacteristic)=='User association' ?  Padding(
            
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () async {
                    String valueString =_deviceAssociation.text;
                    var bytes= utf8.encode(valueString);
                    
                    
                    await golain.writeCharacteristicwithResponse(
                        widget.characteristic, bytes);
                        setState(() {
                          writeOutput = 'Success';
                        });
                        log('Success');
                  },
                  child: const Text('With response')),
            ),
          ): Container(),
          _functionCharacteristic(widget.discoveredCharacteristic)=='Wifi credentials' ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller:_wifiCredentials,
              decoration: const InputDecoration(
                labelText: 'User ssid,password',
              ),
            ),
          ): Container(),
         
          _functionCharacteristic(widget.discoveredCharacteristic)=='Wifi credentials' ?  Padding(
           
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () async {
                    String valueString = _wifiCredentials.text;
                    var bytes = utf8.encode(valueString);
                    await golain.writeCharacteristicwithResponse(
                        widget.characteristic, bytes);
                        setState(() {
                          writeOutput = 'Success';
                        });
                        log('Success');
                  },
                  child: const Text('With response')),
            ),
          ): Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(writeOutput),
          ),
        ],
      ),
    );
  }
}

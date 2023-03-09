import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'protobuf/rgb_on_off/rgb_on_off.pb.dart';
import 'scanbloc/scan_bloc.dart';

Uint8List encodeMessage(message) {
  return message.writeToBuffer();
}

class RGBProtobuf extends StatefulWidget {
  final int selectedElementAddress;

  const RGBProtobuf({
    Key? key,
    required this.selectedElementAddress,
  }) : super(key: key);
  @override
  State<RGBProtobuf> createState() => _RGBProtobufState();
}

class _RGBProtobufState extends State<RGBProtobuf> {
  Color currentColor = Colors.blue;

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanBloc, ScanState>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is VendorModelControlSetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Vendor Model Received Data: ${String.fromCharCodes(state.data.message)}'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("RGB Picker", style: TextStyle(fontSize: 20)),
              ),
              Slider(
                  activeColor: Colors.red,
                  value: currentColor.red.toDouble(),
                  min: 0,
                  max: 255,
                  onChanged: (value) {
                    changeColor(Color.fromARGB(currentColor.alpha,
                        value.toInt(), currentColor.green, currentColor.blue));
                  }),
              Slider(
                  activeColor: Colors.green,
                  value: currentColor.green.toDouble(),
                  min: 0,
                  max: 255,
                  onChanged: (value) {
                    changeColor(Color.fromARGB(currentColor.alpha,
                        currentColor.red, value.toInt(), currentColor.blue));
                  }),
              Slider(
                  activeColor: Colors.blue,
                  value: currentColor.blue.toDouble(),
                  min: 0,
                  max: 255,
                  onChanged: (value) {
                    changeColor(Color.fromARGB(currentColor.alpha,
                        currentColor.red, currentColor.green, value.toInt()));
                  }),
              ColorPicker(
                pickerColor: currentColor,
                onColorChanged: changeColor,
                pickerAreaHeightPercent: 0.8,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final message = shadow()
                      ..red = currentColor.red
                      ..green = currentColor.green
                      ..blue = currentColor.blue;

                    final buffer = message.writeToBuffer();
                    log(buffer.toString());

                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    try {
                      BlocProvider.of<ScanBloc>(context).add(
                        VendorModelControlSetRequested(
                          int.parse(widget.selectedElementAddress.toString()),
                          buffer,
                        ),
                      );
                      Navigator.of(context).pop();
                    } on TimeoutException catch (_) {
                      scaffoldMessenger.showSnackBar(const SnackBar(
                          content: Text('Board didn\'t respond')));
                    } on PlatformException catch (e) {
                      scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('${e.message}')));
                    } catch (e) {
                      scaffoldMessenger
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: const Text('Send RGB')),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:golain_example/characteristics.dart';

String _charactisticsSummary(DiscoveredCharacteristic c) {
  final props = <String>[];
  if (c.isReadable) {
    props.add("read");
  }
  if (c.isWritableWithoutResponse) {
    props.add("write without response");
  }
  if (c.isWritableWithResponse) {
    props.add("write with response");
  }
  if (c.isNotifiable) {
    props.add("notify");
  }
  if (c.isIndicatable) {
    props.add("indicate");
  }

  return props.join("\n");
}

class ServiceDiscoveryList extends StatefulWidget {
  const ServiceDiscoveryList({
    required this.deviceId,
    required this.discoveredServices,
    Key? key,
  }) : super(key: key);

  final String deviceId;
  final List<DiscoveredService> discoveredServices;

  @override
  // ignore: library_private_types_in_public_api
  _ServiceDiscoveryListState createState() => _ServiceDiscoveryListState();
}

class _ServiceDiscoveryListState extends State<ServiceDiscoveryList> {
  late final List<int> _expandedItems;

  @override
  void initState() {
    _expandedItems = [];
    super.initState();
  }

  String _charactisticsSummary(DiscoveredCharacteristic c) {
    final props = <String>[];
    if (c.isReadable) {
      props.add("read");
    }
    if (c.isWritableWithoutResponse) {
      props.add("write without response");
    }
    if (c.isWritableWithResponse) {
      props.add("write with response");
    }
    if (c.isNotifiable) {
      props.add("notify");
    }
    if (c.isIndicatable) {
      props.add("indicate");
    }

    return props.join("\n");
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

  Widget _characteristicTile(
          DiscoveredCharacteristic characteristic, String deviceId) =>
      ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>  CharacteristicPage(
                        discoveredCharacteristic: characteristic,
                        characteristic: QualifiedCharacteristic(characteristicId: characteristic.characteristicId, serviceId:characteristic.serviceId, deviceId: deviceId),
                  )));
        },
        title: Text(
          '${_functionCharacteristic(characteristic)}\n(${_charactisticsSummary(characteristic)})',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      );

  List<ExpansionPanel> buildPanels() {
    final panels = <ExpansionPanel>[];

    widget.discoveredServices.asMap().forEach(
          (index, service) => panels.add(
            ExpansionPanel(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: 16.0),
                    child: Text(
                      'Characteristics',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) => _characteristicTile(
                      service.characteristics[index],
                      widget.deviceId,
                    ),
                    itemCount: service.characteristicIds.length,
                  ),
                ],
              ),
              headerBuilder: (context, isExpanded) => ListTile(
                title: Text(
                  '${service.serviceId}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              isExpanded: _expandedItems.contains(index),
            ),
          ),
        );

    return panels;
  }

  @override
  Widget build(BuildContext context) => widget.discoveredServices.isEmpty
      ? const SizedBox()
      : Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 20.0,
              start: 20.0,
              end: 20.0,
            ),
            child: SingleChildScrollView(
              child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    setState(() {
                      if (isExpanded) {
                        _expandedItems.remove(index);
                      } else {
                        _expandedItems.add(index);
                      }
                    });
                  });
                },
                children: [
                  ...buildPanels(),
                ],
              ),
            ),
          ),
        );
}

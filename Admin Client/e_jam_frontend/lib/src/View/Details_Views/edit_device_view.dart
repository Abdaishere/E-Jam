import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Lists/devices_list_view.dart';
import 'package:e_jam/src/controller/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final formKey = GlobalKey<FormState>();

class EditDeviceView extends StatefulWidget {
  const EditDeviceView(
      {super.key,
      required this.mac,
      required this.refresh,
      required this.device});

  final String mac;
  final Function refresh;
  final Device device;
  @override
  State<EditDeviceView> createState() => _EditDeviceViewState();
}

class _EditDeviceViewState extends State<EditDeviceView> {
  @override
  void initState() {
    super.initState();
    EditDeviceController.updateFields(widget.device, widget.mac);
  }

  Future<bool?> _editDevice() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: EditDeviceController.nameController.text,
        description: EditDeviceController.descriptionController.text,
        location: EditDeviceController.locationController.text,
        ipAddress: EditDeviceController.ipController.text,
        port: int.parse(EditDeviceController.portController.text),
        macAddress: widget.mac,
      );

      bool? result = await DevicesController.updateDevice(device);
      if (mounted) {
        widget.refresh();
        setState(() {});
        if (result ?? false) {
          return true;
        } else {
          return false;
        }
      }
      return null;
    }
    return null;
  }

  @override
  void dispose() {
    EditDeviceController.clearAllFields();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape
          ? const EdgeInsets.symmetric(horizontal: 300, vertical: 100)
          : const EdgeInsets.all(20),
      child: Hero(
        tag: widget.device.macAddress,
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Edit ${widget.device.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              centerTitle: true,
              actions: const [
                DevicePinger(),
              ],
              automaticallyImplyLeading: false,
            ),
            body: Form(
              key: formKey,
              child: _addDeviceFields(),
            ),
            bottomNavigationBar: _bottomOptionsBar(),
          ),
        ),
      ),
    );
  }

  BottomAppBar _bottomOptionsBar() {
    return BottomAppBar(
      elevation: 0,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            color: Colors.red,
            tooltip: 'Cancel',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check),
            color: Colors.blue,
            tooltip: 'Save',
            onPressed: () async {
              _editDevice().then(
                (value) => {
                  if (mounted && (value ?? false)) {Navigator.pop(context)}
                },
              );
            },
          ),
        ],
      ),
    );
  }

  SingleChildScrollView _addDeviceFields() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: const [
          NameField(),
          Description(),
          Location(),
          ConnectionIpAndPort(),
        ],
      ),
    );
  }
}

class DevicePinger extends StatefulWidget {
  const DevicePinger({super.key});

  @override
  State<DevicePinger> createState() => _DevicePingerState();
}

class _DevicePingerState extends State<DevicePinger> {
  bool? _isPinged;
  bool _isPinging = false;

  _pingDevice() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: EditDeviceController.nameController.text,
        description: EditDeviceController.descriptionController.text,
        location: EditDeviceController.locationController.text,
        ipAddress: EditDeviceController.ipController.text,
        port: int.parse(EditDeviceController.portController.text),
        macAddress: EditDeviceController.mac,
      );
      _isPinging = true;
      setState(() {});
      bool value = await DevicesController.pingNewDevice(device);

      _isPinged = value;
      _isPinging = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Visibility(
        visible: !_isPinging,
        replacement: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: LoadingAnimationWidget.beat(
            color: Colors.lightBlueAccent,
            size: 20.0,
          ),
        ),
        child: IconButton(
          icon: const Icon(
            MaterialCommunityIcons.wifi_sync,
            size: 20,
          ),
          onPressed: () => _pingDevice(),
          tooltip: _isPinged == null
              ? 'Ping device'
              : _isPinged!
                  ? 'Device is online'
                  : 'Device is offline',
          color: _isPinged == null
              ? Colors.lightBlueAccent
              : _isPinged!
                  ? deviceRunningOrOnlineColor
                  : deviceOfflineOrErrorColor,
        ),
      ),
    );
  }
}

class Location extends StatelessWidget {
  const Location({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Location',
        hintText: 'Location of the Device',
        icon: Icon(MaterialCommunityIcons.map_marker),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        } else if (value.length > 50) {
          return 'Please enter a Location less than 50 characters';
        }
        return null;
      },
      controller: EditDeviceController.locationController,
    );
  }
}

class Description extends StatelessWidget {
  const Description({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Description of the Device',
        icon: Icon(Icons.description),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        } else if (value.length > 255) {
          return 'Please enter a description less than 255 characters';
        }
        return null;
      },
      controller: EditDeviceController.descriptionController,
    );
  }
}

class ConnectionIpAndPort extends StatelessWidget {
  const ConnectionIpAndPort({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            enableIMEPersonalizedLearning: false,
            decoration: const InputDecoration(
              labelText: 'IP',
              hintText: 'IP Address of the Device',
              icon: Icon(MaterialCommunityIcons.ip),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an ip address for the Device';
              } else if (!RegExp(
                      r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
                  .hasMatch(value)) {
                return 'Please enter a valid ip address for the Device';
              }
              return null;
            },
            controller: EditDeviceController.ipController,
          ),
        ),
        const Text(" : ", style: TextStyle(fontSize: 30)),
        Expanded(
          flex: 1,
          child: TextFormField(
            enableIMEPersonalizedLearning: false,
            decoration: InputDecoration(
              labelText: 'Port',
              hintText: NetworkController.defaultDevicesPort.toString(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a port for the Device';
              }
              return null;
            },
            controller: EditDeviceController.portController,
          ),
        ),
      ],
    );
  }
}

class NameField extends StatefulWidget {
  const NameField({super.key});

  @override
  State<NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<NameField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Name',
        hintText: 'Name of the Device',
        icon: Icon(getDeviceIcon(EditDeviceController.nameController.text)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        } else if (value.length > 50) {
          return 'Please enter a name less than 50 characters';
        }
        return null;
      },
      controller: EditDeviceController.nameController,
      onChanged: (value) {
        setState(() {});
      },
    );
  }
}

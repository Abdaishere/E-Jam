import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Dialogues/device_status_icon_button.dart';
import 'package:e_jam/src/controller/Devices/edit_device_controller.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<EditDeviceController>()
          .updateFields(widget.device, widget.mac);
    });
  }

  Future<bool?> _editDevice() async {
    Device? device =
        await context.read<EditDeviceController>().updateDevice(formKey);
    if (!mounted || device == null) return null;
    bool result =
        await context.read<DevicesController>().updateDevice(device) ?? false;

    if (mounted) {
      widget.refresh();
      if (result) {
        Navigator.pop(context);
        return true;
      } else {
        Navigator.pop(context);
        return false;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape &&
              MediaQuery.of(context).size.width > 900
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.3,
              vertical: 100)
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
            onPressed: () => _editDevice(),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView _addDeviceFields() {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
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
    _isPinging = true;
    setState(() {});
    Device? device =
        await context.read<EditDeviceController>().pingDevice(formKey);
    if (!mounted || device == null) return;
    bool value = await context.read<DevicesController>().pingNewDevice(device);

    _isPinged = value;
    _isPinging = false;

    if (mounted) {
      setState(() {});
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
      controller: context.read<EditDeviceController>().getLocationController,
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
      controller: context.read<EditDeviceController>().getDescriptionController,
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
            controller: context.read<EditDeviceController>().getIpController,
          ),
        ),
        const Text(" : ", style: TextStyle(fontSize: 30)),
        Expanded(
          flex: 1,
          child: TextFormField(
            enableIMEPersonalizedLearning: false,
            decoration: InputDecoration(
              labelText: 'Port',
              hintText: SystemSettings.defaultDevicesPort.toString(),
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
            controller: context.read<EditDeviceController>().getPortController,
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
        icon: Icon(getDeviceIcon(
            context.read<EditDeviceController>().getNameController.text)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        } else if (value.length > 50) {
          return 'Please enter a name less than 50 characters';
        }
        return null;
      },
      controller: context.read<EditDeviceController>().getNameController,
      onChanged: (value) {
        setState(() {});
      },
    );
  }
}

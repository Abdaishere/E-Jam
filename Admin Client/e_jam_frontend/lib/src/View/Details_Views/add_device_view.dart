import 'package:e_jam/src/Model/Classes/device.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/device_status_icon_button.dart';
import 'package:e_jam/src/View/Dialogues_Buttons/request_status_icon.dart';
import 'package:e_jam/src/controller/Devices/add_device_controller.dart';
import 'package:e_jam/src/controller/Devices/devices_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

final formKey = GlobalKey<FormState>();

class AddDeviceView extends StatefulWidget {
  const AddDeviceView({super.key, this.ip, this.delete});

  final String? ip;
  final Function()? delete;
  @override
  State<AddDeviceView> createState() => _AddDeviceViewState();
}

class _AddDeviceViewState extends State<AddDeviceView> {
  @override
  void initState() {
    super.initState();
    if (widget.ip != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddDeviceController>().getIpController.text = widget.ip!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).orientation == Orientation.landscape &&
              MediaQuery.of(context).size.width > 900
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.3,
              vertical: MediaQuery.of(context).size.height * 0.1)
          : const EdgeInsets.all(20),
      child: Hero(
        tag: 'addDevice',
        createRectTween: (begin, end) =>
            CustomRectTween(begin: begin!, end: end!),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Add Device',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              actions: const [
                DevicePinger(),
              ],
              automaticallyImplyLeading: false,
            ),
            body: Form(
              key: formKey,
              child: const AddDeviceFields(),
            ),
            bottomNavigationBar: BottomOptionsBar(
              delete: widget.delete,
            ),
          ),
        ),
      ),
    );
  }
}

class AddDeviceFields extends StatelessWidget {
  const AddDeviceFields({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          NameField(),
          DescriptionField(),
          LocationField(),
          ConnectionIpAndPort(),
          MacAddressField(),
        ],
      ),
    );
  }
}

class BottomOptionsBar extends StatefulWidget {
  const BottomOptionsBar({super.key, this.delete});

  final Function()? delete;
  @override
  State<BottomOptionsBar> createState() => _BottomOptionsBarState();
}

class _BottomOptionsBarState extends State<BottomOptionsBar> {
  Message? _status;

  Future<bool?> _addDevice() async {
    Device? device =
        await context.read<AddDeviceController>().createNewDevice(formKey);

    if (!mounted || device == null) return null;
    Message? code =
        await context.read<DevicesController>().addNewDevice(device);

    if (!mounted) return null;
    _status = code;
    setState(() {});
    context.read<DevicesController>().loadAllDevices(true);
    return _status != null && _status!.responseCode <= 300;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(MaterialCommunityIcons.delete_empty),
            tooltip: 'Clear',
            color: Colors.redAccent,
            onPressed: () {
              if (formKey.currentState != null) formKey.currentState!.reset();
              context.read<AddDeviceController>().clearAllFields();
            },
          ),
          _status != null && _status!.responseCode >= 300
              ? RequestStatusIcon(
                  response: _status!,
                )
              : const SizedBox(
                  width: 40,
                ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check),
            color: Colors.blueAccent,
            tooltip: 'OK',
            onPressed: () async {
              bool? value = await _addDevice();
              if (value != null && value) {
                if (mounted) Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.xmark),
            color: Colors.red,
            tooltip: 'Cancel',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus),
            color: Colors.greenAccent.shade700,
            tooltip: 'Apply',
            onPressed: () => _addDevice(),
          ),
        ],
      ),
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
            controller: context.read<AddDeviceController>().getIpController,
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
              } else if (int.parse(value) > 65535) {
                return 'Please enter a valid port for the Device';
              }
              return null;
            },
            controller: context.read<AddDeviceController>().getPortController,
          ),
        ),
      ],
    );
  }
}

class LocationField extends StatelessWidget {
  const LocationField({
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
      controller: context.read<AddDeviceController>().getLocationController,
    );
  }
}

class DescriptionField extends StatelessWidget {
  const DescriptionField({
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
      controller: context.read<AddDeviceController>().getDescriptionController,
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
            context.read<AddDeviceController>().getNameController.text)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        } else if (value.length > 50) {
          return 'Please enter a name less than 50 characters';
        }
        return null;
      },
      controller: context.read<AddDeviceController>().getNameController,
      onChanged: (value) {
        setState(() {});
      },
    );
  }
}

class MacAddressField extends StatefulWidget {
  const MacAddressField({super.key});

  @override
  State<MacAddressField> createState() => _MacAddressFieldState();
}

class _MacAddressFieldState extends State<MacAddressField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'MAC Address',
        hintText: 'MAC Address of the Device',
        icon: Icon(MaterialCommunityIcons.ethernet),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a mac address for the Device';
        } else if (!RegExp(r"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")
            .hasMatch(value)) {
          return 'Please enter a valid mac address for the Device';
        }

        return null;
      },
      controller: context.read<AddDeviceController>().getMacController,
      onSaved: (value) {
        context.read<AddDeviceController>().getMacController.text =
            value!.toUpperCase();
      },
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
      _isPinging = true;
      setState(() {});
      Device? device =
          await context.read<AddDeviceController>().pingDevice(formKey);
      if (!mounted || device == null) return;
      bool result =
          await context.read<DevicesController>().pingNewDevice(device);

      _isPinged = result;
      _isPinging = false;
      if (mounted) {
        setState(
          () {},
        );
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
                  ? deviceStatusColorScheme(DeviceStatus.online)
                  : deviceStatusColorScheme(DeviceStatus.offline),
        ),
      ),
    );
  }
}

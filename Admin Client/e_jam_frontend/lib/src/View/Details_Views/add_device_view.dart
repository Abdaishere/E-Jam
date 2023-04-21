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

class AddDeviceView extends StatefulWidget {
  const AddDeviceView({super.key, required this.refresh, this.ip, this.delete});

  final Function refresh;
  final String? ip;
  final Function()? delete;
  @override
  State<AddDeviceView> createState() => _AddDeviceViewState();
}

class _AddDeviceViewState extends State<AddDeviceView> {
  Color _tabBarColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    if (widget.ip != null) {
      AddDeviceController.ipController.text = widget.ip!;
    }
  }

  Future<bool?> _addDevice() async {
    int? code = await AddDeviceController.createNewDevice(formKey);
    if (code == null) return null;

    bool result = _analyzeCode(code);
    if (mounted) {
      if (result) {
        setState(() {
          widget.refresh();
          _tabBarColor = Colors.greenAccent.shade700.withOpacity(0.8);
        });
        if (widget.delete != null) widget.delete!();
        return true;
      } else {
        setState(() {
          _tabBarColor = Colors.redAccent.withOpacity(0.8);
        });
        return false;
      }
    }
    return null;
  }

  bool _analyzeCode(int code) {
    if (code == 201) {
      return true;
    } else if (code == 409) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Device already exists'),
          content: const Text(
              'The device you are trying to add already exists, please check the MAC address and try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      );
      return false;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'addDevice',
      createRectTween: (begin, end) =>
          CustomRectTween(begin: begin!, end: end!),
      child: SizedBox(
        height: MediaQuery.of(context).size.height *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 1
                : 0.8),
        width: MediaQuery.of(context).size.width *
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? 1
                : 0.45),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Scaffold(
            // IDEA: make it ping a device and if it responds then add it to the list of devices
            appBar: AppBar(
              backgroundColor: _tabBarColor,
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
              child: _addDeviceFields(),
            ),
            // for now this is the same as the add stream view
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          IconButton(
            icon: const Icon(MaterialCommunityIcons.delete_empty),
            tooltip: 'Clear all fields',
            color: Colors.redAccent,
            onPressed: () {
              setState(() {
                _tabBarColor = Colors.transparent;
                formKey.currentState!.reset();
                AddDeviceController.clearAllFields();
              });
            },
          ),
          const Divider(),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check),
            color: Colors.blueAccent,
            onPressed: () async {
              bool? value = await _addDevice();
              if (value != null && value) {
                if (mounted) Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus),
            color: Colors.greenAccent.shade700,
            onPressed: () => _addDevice(),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView _addDeviceFields() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          const NameField(),
          _descriptionField(),
          _locationField(),
          _connectionIpAndPort(),
          const MacAddressField(),
        ],
      ),
    );
  }

  TextFormField _descriptionField() {
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
      controller: AddDeviceController.descriptionController,
    );
  }

  TextFormField _locationField() {
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
      controller: AddDeviceController.locationController,
    );
  }

  Row _connectionIpAndPort() {
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
            controller: AddDeviceController.ipController,
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
            controller: AddDeviceController.portController,
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
        icon: Icon(getDeviceIcon(AddDeviceController.nameController.text)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        } else if (value.length > 50) {
          return 'Please enter a name less than 50 characters';
        }
        return null;
      },
      controller: AddDeviceController.nameController,
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
      controller: AddDeviceController.macController,
      onSaved: (value) {
        setState(() {
          AddDeviceController.macController.text = value?.toUpperCase() ?? '';
        });
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
      setState(() {
        _isPinging = true;
      });
      bool result = await AddDeviceController.pingDevice(formKey) ?? false;
      setState(
        () {
          _isPinged = result;
          _isPinging = false;
        },
      );
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

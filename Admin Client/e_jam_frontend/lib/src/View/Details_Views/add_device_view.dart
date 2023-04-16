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

class AddDeviceView extends StatefulWidget {
  const AddDeviceView({super.key, required this.refresh, this.ip, this.delete});

  final Function refresh;
  final String? ip;
  final Function()? delete;
  @override
  State<AddDeviceView> createState() => _AddDeviceViewState();
}

class _AddDeviceViewState extends State<AddDeviceView> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(
      text: NetworkController.defaultDevicesPort.toString());
  final TextEditingController _macController = TextEditingController();
  Color _topBarIndicator = Colors.transparent;
  bool? _isPinged;
  bool _isPinging = false;

  @override
  void initState() {
    super.initState();
    _ipController.text = widget.ip ?? '';
  }

  Future<bool?> _addDevice() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        ipAddress: _ipController.text,
        port: int.parse(_portController.text),
        macAddress: _macController.text,
      );
      ScaffoldMessenger.of(context);

      return DevicesController.createNewDevice(device).then(
        (code) {
          bool result = _analyzeCode(code);
          if (result) {
            setState(() {
              widget.refresh();
              _topBarIndicator = Colors.greenAccent.withOpacity(0.8);
            });
            if (widget.delete != null) widget.delete!();
            return true;
          } else {
            setState(() {
              _topBarIndicator = Colors.redAccent.withOpacity(0.8);
            });
            return false;
          }
        },
      );
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

  _pingDevice() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Device device = Device(
        name: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        ipAddress: _ipController.text,
        port: int.parse(_portController.text),
        macAddress: _macController.text,
      );
      setState(() {
        _isPinging = true;
      });
      DevicesController.pingNewDevice(device).then(
        (value) => setState(
          () {
            _isPinged = value;
            _isPinging = false;
          },
        ),
      );
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
                : 0.4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Scaffold(
            // IDEA: make it ping a device and if it responds then add it to the list of devices
            appBar: AppBar(
              backgroundColor: _topBarIndicator,
              title: const Text('Add Device',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              actions: [
                Padding(
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
                ),
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
            color: Colors.redAccent,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.check),
            color: Colors.blueAccent,
            onPressed: () async {
              _addDevice().then(
                (value) => {
                  if (value != null && value) {Navigator.pop(context)}
                },
              );
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus),
            color: Colors.greenAccent,
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
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Name of the Device',
              icon: Icon(getDeviceIcon(_nameController.text)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name for the Device';
              } else if (value.length > 50) {
                return 'Please enter a name less than 50 characters';
              }
              return null;
            },
            controller: _nameController,
            onChanged: (value) {
              setState(() {});
            },
          ),
          TextFormField(
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Description of the Device',
              icon: Icon(Icons.description),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description for the Device';
              } else if (value.length > 255) {
                return 'Please enter a description less than 255 characters';
              }
              return null;
            },
            controller: _descriptionController,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'Location of the Device',
              icon: Icon(MaterialCommunityIcons.map_marker),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a Location for the stream';
              } else if (value.length > 50) {
                return 'Please enter a Location less than 50 characters';
              }
              return null;
            },
            controller: _locationController,
          ),
          _connectionIpAndPort(),
          TextFormField(
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
            controller: _macController,
            onSaved: (value) {
              setState(() {
                _macController.text = value?.toUpperCase() ?? '';
              });
            },
          ),
        ],
      ),
    );
  }

  Row _connectionIpAndPort() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            enableIMEPersonalizedLearning: false,
            decoration: const InputDecoration(
              labelText: 'IP',
              hintText: '127.0.0.1',
              icon: Icon(MaterialCommunityIcons.ip),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a ip address for the Device';
              } else if (!RegExp(
                      r"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
                  .hasMatch(value)) {
                return 'Please enter a valid ip address for the Device';
              }
              return null;
            },
            controller: _ipController,
          ),
        ),
        const Text(" : ", style: TextStyle(fontSize: 35)),
        Expanded(
          flex: 1,
          child: TextFormField(
            enableIMEPersonalizedLearning: false,
            decoration: const InputDecoration(
              labelText: 'Port',
              hintText: '8000',
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
            controller: _portController,
          ),
        ),
      ],
    );
  }
}

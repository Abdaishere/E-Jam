import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class ChangeServerIPScreen extends StatefulWidget {
  const ChangeServerIPScreen({super.key});

  @override
  State<ChangeServerIPScreen> createState() => _ChangeServerIPScreenState();
}

class _ChangeServerIPScreenState extends State<ChangeServerIPScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _serverIpAddressController =
      TextEditingController();
  final TextEditingController _serverPortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serverIpAddressController.text = NetworkController.serverIpAddress.host;
    _serverPortController.text =
        NetworkController.serverIpAddress.port.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: 500,
      height: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Change Server',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 160,
                    height: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_serverPortController.text.isEmpty) {
                          _serverPortController.text = "8080";
                        }
                        if (_serverIpAddressController.text.isEmpty) {
                          _serverIpAddressController.text = "127.0.0.1";
                        }
                        formKey.currentState!.save();
                        NetworkController.changeServerIpAddress(
                            "localhost", _serverPortController.text);

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Column(
                        children: const [
                          SizedBox(height: 10),
                          Icon(FontAwesome.download,
                              size: 50, color: Colors.green),
                          Divider(),
                          Text(
                            'Same Device',
                            style: TextStyle(fontSize: 15, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 60),
                  SizedBox(
                    width: 160,
                    height: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          NetworkController.changeServerIpAddress(
                              _serverIpAddressController.text,
                              _serverPortController.text);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: Column(
                        children: const [
                          SizedBox(height: 10),
                          Icon(MaterialCommunityIcons.server_network,
                              size: 50, color: Colors.orange),
                          Divider(),
                          Text(
                            'Other Device',
                            style:
                                TextStyle(fontSize: 15, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      enableIMEPersonalizedLearning: false,
                      decoration: const InputDecoration(
                        labelText: 'IP',
                        hintText: 'IP Address of the Device',
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
                      controller: _serverIpAddressController,
                    ),
                  ),
                  const Text(" : ", style: TextStyle(fontSize: 30)),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      enableIMEPersonalizedLearning: false,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        hintText: 'Port Number of the Server',
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
                      controller: _serverPortController,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

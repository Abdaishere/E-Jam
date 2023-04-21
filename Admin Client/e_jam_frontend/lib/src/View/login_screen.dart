import 'package:e_jam/src/Model/Shared/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

// TODO: Add a login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _serverIpAddressController =
      TextEditingController();
  final TextEditingController _serverPortController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Switches Login',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: 500,
            height: 500,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface,
                width: 2,
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 180,
                      height: 130,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_serverPortController.text.isNotEmpty) {
                            formKey.currentState!.save();
                            NetworkController.serverIpAddress =
                                "http://${_serverIpAddressController.text}:${_serverPortController.text}";

                            Navigator.pop(context);
                          }
                        },
                        child: Column(
                          children: const [
                            SizedBox(height: 10),
                            Icon(FontAwesome.download, size: 50),
                            Divider(),
                            Text('Same Device', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    SizedBox(
                      width: 180,
                      height: 130,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            NetworkController.serverIpAddress =
                                "http://localhost:${_serverPortController.text}";
                            Navigator.pop(context);
                          }
                        },
                        child: Column(
                          children: const [
                            SizedBox(height: 10),
                            Icon(MaterialCommunityIcons.server_network,
                                size: 50),
                            Divider(),
                            Text('Other Device',
                                style: TextStyle(fontSize: 15)),
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
      ),
    );
  }
}

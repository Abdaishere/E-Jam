import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddDeviceView extends StatefulWidget {
  const AddDeviceView({super.key});

  @override
  State<AddDeviceView> createState() => _AddDeviceViewState();
}

class _AddDeviceViewState extends State<AddDeviceView> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'addDevice',
      createRectTween: (begin, end) =>
          CustomRectTween(begin: begin!, end: end!),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.35,
        height: MediaQuery.of(context).size.height * 0.8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Scaffold(
            // IDEA: make it ping a device and if it responds then add it to the list of devices
            appBar: AppBar(
              title: const Text('Add Device'),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  MaterialCommunityIcons.wifi_sync,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Ping Device',
                color: Colors.lightBlueAccent,
              ),
            ),
            body: Column(
              children: const [
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Text('Add Device'),
                  ),
                ),
              ],
            ),
            // for now this is the same as the add stream view
            bottomNavigationBar: const BottomAddDeviceOptions(),
          ),
        ),
      ),
    );
  }
}

class BottomAddDeviceOptions extends StatefulWidget {
  const BottomAddDeviceOptions({super.key});

  @override
  State<BottomAddDeviceOptions> createState() => _BottomAddDeviceOptionsState();
}

class _BottomAddDeviceOptionsState extends State<BottomAddDeviceOptions> {
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plus),
            color: Colors.greenAccent,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

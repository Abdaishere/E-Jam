import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class DevicesDetailsView extends StatefulWidget {
  const DevicesDetailsView(this.index, {super.key});

  final int index;
  @override
  State<DevicesDetailsView> createState() => _DevicesDetailsViewState();
}

class _DevicesDetailsViewState extends State<DevicesDetailsView> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'device$index',
      createRectTween: (begin, end) =>
          CustomRectTween(begin: begin!, end: end!),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Device $index',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.pencil),
                  color: Colors.green,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(MaterialCommunityIcons.trash_can),
                  color: Colors.red,
                  onPressed: () {},
                ),
                const SizedBox(width: 10),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: DeviceGraph(index),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 2,
                        child: DeviceFieldsDetails(index),
                      ),
                    ],
                  ),
                ),
                ProgressDeviceDetails(index),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeviceGraph extends StatefulWidget {
  const DeviceGraph(this.index, {super.key});

  final int index;
  @override
  State<DeviceGraph> createState() => _DeviceGraphState();
}

class _DeviceGraphState extends State<DeviceGraph> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return const Text('Device Graph');
  }
}

class DeviceFieldsDetails extends StatefulWidget {
  const DeviceFieldsDetails(this.index, {super.key});

  final int index;
  @override
  State<DeviceFieldsDetails> createState() => _DeviceFieldsDetailsState();
}

class _DeviceFieldsDetailsState extends State<DeviceFieldsDetails> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return const Text('Device Fields Details');
  }
}

class ProgressDeviceDetails extends StatefulWidget {
  const ProgressDeviceDetails(this.index, {super.key});

  final int index;
  @override
  State<ProgressDeviceDetails> createState() => _ProgressDeviceDetailsState();
}

class _ProgressDeviceDetailsState extends State<ProgressDeviceDetails> {
  get index => widget.index;
  @override
  Widget build(BuildContext context) {
    return const Text('Progress Device Details');
  }
}

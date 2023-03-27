import 'dart:ffi';
import 'dart:math';

import 'package:e_jam/src/Model/Classes/stream_entry.dart';
import 'package:e_jam/src/Theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_jam/src/View/Animation/custom_rest_tween.dart';

// TODO: Make the AddStreamView a CardView
class AddStreamView extends StatefulWidget {
  const AddStreamView({super.key});

  @override
  State<AddStreamView> createState() => _AddStreamViewState();
}

class _AddStreamViewState extends State<AddStreamView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formKey = GlobalKey<FormState>();

  late StreamEntry streamEntry;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'addStream',
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
                : 0.5),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Scaffold(
            appBar: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 0,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
                color: Colors.blueAccent,
              ),
              labelColor: Colors.white,
              labelStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
              dividerColor: Colors.transparent,
              unselectedLabelColor: Colors.grey,
              controller: _tabController,
              tabs: const <Widget>[
                Tab(
                  height: 42.0,
                  text: 'Stream Details',
                ),
                Tab(
                  height: 42.0,
                  text: 'Pre sets',
                ),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Form(
                  key: formKey,
                  child: _addStreamFields(),
                ),
                const AddPresetStream(),
              ],
            ),
            bottomNavigationBar: _bottomAddStreamOptions(context),
          ),
        ),
      ),
    );
  }

  Padding _addStreamFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: _streamIDField(),
              ),
              const VerticalDivider(),
              Expanded(
                flex: 2,
                child: _streamNameField(),
              ),
            ],
          ),
          _streamDescriptionField(),
        ],
      ),
    );
  }

  TextFormField _streamIDField() {
    return TextFormField(
      enableIMEPersonalizedLearning: false,
      maxLength: 3,
      decoration: const InputDecoration(
        labelText: 'ID',
      ),
      validator: (value) {
        if (!RegExp(r'^\w{3}$').hasMatch(value!)) {
          return 'Please enter a valid ID';
        }
        return null;
      },
      onSaved: (value) {
        streamEntry.streamId = value!;
      },
    );
  }

  TextFormField _streamNameField() {
    return TextFormField(
      maxLength: 50,
      decoration: const InputDecoration(
        labelText: 'Name',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a name for the stream';
        }
        if (value.length > 50) {
          return 'Stream name must be less than 50 characters long';
        }
        return null;
      },
      onSaved: (value) {
        streamEntry.name = value!;
      },
    );
  }

  TextFormField _streamDescriptionField() {
    return TextFormField(
      maxLength: 255,
      maxLines: 1,
      decoration: const InputDecoration(
        labelText: 'Description',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description for the stream';
        }
        if (value.length > 255) {
          return 'Stream description must be less than 255 characters long';
        }
        return null;
      },
      onSaved: (value) {
        streamEntry.description = value!;
      },
    );
  }

  BottomAppBar _bottomAddStreamOptions(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      height: 60,
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
          const Divider(),
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

class AddPresetStream extends StatefulWidget {
  const AddPresetStream({super.key});

  @override
  State<AddPresetStream> createState() => _AddPresetStreamState();
}

class _AddPresetStreamState extends State<AddPresetStream> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Add Preset Stream'));
  }
}

class VerifyingDevicesDrawer extends StatefulWidget {
  const VerifyingDevicesDrawer({super.key});

  @override
  State<VerifyingDevicesDrawer> createState() => _VerifyingDevicesDrawerState();
}

// TODO: Make the DevicesDrawer a CardView and add the devices list view to it
// This should override the DeviceGridCardView to one that can mark each card to either be a generator or a verifier for the stream or both (if the device is a generator and a verifier)
class _VerifyingDevicesDrawerState extends State<VerifyingDevicesDrawer> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'verifyingDevices',
      createRectTween: (begin, end) =>
          CustomRectTween(begin: begin!, end: end!),
      child: Drawer(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        width: MediaQuery.of(context).size.width * 0.25,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(MaterialCommunityIcons.progress_check,
                  semanticLabel: 'Devices'),
              color: downloadColor,
              tooltip: 'Verifying Devices',
              onPressed: () {},
            ),
            actions: [
              // TODO: Add a search bar to search for devices
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.magnifyingGlass,
                    size: 20, semanticLabel: 'Search Devices'),
                tooltip: 'Search',
                onPressed: () {},
              ),
              // TODO: Add a button to sync the devices list
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowsRotate,
                    size: 20, semanticLabel: 'Sync Devices'),
                tooltip: 'Sync',
                onPressed: () {},
              ),
            ],
          ),
          // each device should be a card view with a checkbox to select the device as a generator or a verifier or both (if the device is a generator and a verifier)
          body: const Center(child: Text('Devices Drawer')),
        ),
      ),
    );
  }
}

class GeneratingDevicesDrawer extends StatefulWidget {
  const GeneratingDevicesDrawer({super.key});

  @override
  State<GeneratingDevicesDrawer> createState() =>
      _GeneratingDevicesDrawerState();
}

// TODO: Make the DevicesDrawer a CardView and add the devices list view to it
// This should override the DeviceGridCardView to one that can mark each card to either be a generator or a verifier for the stream or both (if the device is a generator and a verifier)
class _GeneratingDevicesDrawerState extends State<GeneratingDevicesDrawer> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'generatingDevices',
      createRectTween: (begin, end) =>
          CustomRectTween(begin: begin!, end: end!),
      child: Drawer(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        width: MediaQuery.of(context).size.width * 0.25,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: const Icon(MaterialCommunityIcons.progress_upload,
                    semanticLabel: 'Devices'),
              ),
              color: uploadColor,
              tooltip: 'Generating Devices',
              onPressed: () {},
            ),
            actions: [
              // TODO: Add a search bar to search for devices
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.magnifyingGlass,
                    size: 20, semanticLabel: 'Search Devices'),
                tooltip: 'Search',
                onPressed: () {},
              ),
              // TODO: Add a button to sync the devices list
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowsRotate,
                    size: 20, semanticLabel: 'Sync Devices'),
                tooltip: 'Sync',
                onPressed: () {},
              ),
            ],
          ),
          // each device should be a card view with a checkbox to select the device as a generator or a verifier or both (if the device is a generator and a verifier)
          body: const Center(child: Text('Devices Drawer')),
        ),
      ),
    );
  }
}

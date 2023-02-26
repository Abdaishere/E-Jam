import 'package:flutter/material.dart';
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            // Should fit all the input fields and buttons of the Stream Details
            // When clicking on generators or verifiers the screen should open the Devices list view in a card view and the user should be able to select devices from the list view and add them to the stream details
            // Try to make the card view as a drawer that slides in from the right side of the screen or from the left side of the screen (drawer approach)
            height: MediaQuery.of(context).size.height * 0.75,
            width: MediaQuery.of(context).size.width * 0.45,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(5),
              ),
              child: Scaffold(
                // top bar with back button for navigation bettwen presets and higher level details view
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
                  unselectedLabelColor: Colors.blueGrey,
                  controller: _tabController,
                  tabs: const <Widget>[
                    Tab(
                      height: 42.0,
                      text: 'Add Stream',
                    ),
                    Tab(
                      height: 42.0,
                      text: 'Preset',
                    ),
                  ],
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: const <Widget>[
                    AddStreamDetails(),
                    AddPresetStream(),
                  ],
                ),
                bottomNavigationBar: const BottomAddStreamOptions(),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.06,
          ),
          const DevicesDrawer(),
        ],
      ),
    );
  }
}

class AddStreamDetails extends StatefulWidget {
  const AddStreamDetails({super.key});

  @override
  State<AddStreamDetails> createState() => _AddStreamDetailsState();
}

class _AddStreamDetailsState extends State<AddStreamDetails> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Add Stream Details'));
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

class BottomAddStreamOptions extends StatefulWidget {
  const BottomAddStreamOptions({super.key});

  @override
  State<BottomAddStreamOptions> createState() => _BottomAddStreamOptionsState();
}

class _BottomAddStreamOptionsState extends State<BottomAddStreamOptions> {
  @override
  Widget build(BuildContext context) {
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

class DevicesDrawer extends StatefulWidget {
  const DevicesDrawer({super.key});

  @override
  State<DevicesDrawer> createState() => _DevicesDrawerState();
}

// TODO: Make the DevicesDrawer a CardView and add the devices list view to it
// This should override the DeviceGridCardView to one that can mark each card to either be a generator or a verifier for the stream or both (if the device is a generator and a verifier)
class _DevicesDrawerState extends State<DevicesDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            icon: const FaIcon(FontAwesomeIcons.microchip,
                size: 22, semanticLabel: 'Devices'),
            color: Colors.deepOrangeAccent,
            tooltip: 'Devices',
            // TODO: View the devices list view in a card view
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
    );
  }
}

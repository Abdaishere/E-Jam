import 'package:flutter/material.dart';

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
    return Center(
      child: Hero(
        tag: 'add-stream-button',
        child: SizedBox(
          // Should fit all the input fields and buttons of the Stream Details
          // When clicking on generators or verifiers the screen should open the Devices list view in a card view and the user should be able to select devices from the list view and add them to the stream details
          // Try to make the card view as a drawer that slides in from the right side of the screen or from the left side of the screen (drawer approach)
          height: MediaQuery.of(context).size.height * 0.75,
          width: MediaQuery.of(context).size.width * 0.45,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(25),
              bottomLeft: Radius.circular(35),
              topLeft: Radius.circular(25),
              bottomRight: Radius.circular(10),
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
            ),
          ),
        ),
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
    return const Scaffold(
      body: Center(
        child: Text('Add Stream Details'),
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
    return const Scaffold(
      body: Center(
        child: Text('Add Preset Stream'),
      ),
    );
  }
}

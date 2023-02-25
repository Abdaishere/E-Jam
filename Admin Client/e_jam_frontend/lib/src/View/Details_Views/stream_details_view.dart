import 'package:flutter/material.dart';

// TODO: Make the StreamDetailsView a CardView
class StreamDetailsView extends StatefulWidget {
  const StreamDetailsView({super.key, required this.index});
  final int index;

  @override
  State<StreamDetailsView> createState() => _StreamDetailsViewState();
}

class _StreamDetailsViewState extends State<StreamDetailsView> {
  get index => widget.index;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'stream$index',
      child: Scaffold(
        appBar: AppBar(
          title: Text('Stream $index Details View'),
        ),
        body: Center(child: Text('Stream $index Details View')),
      ),
    );
  }
}

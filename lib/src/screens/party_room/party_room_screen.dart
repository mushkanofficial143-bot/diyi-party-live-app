import 'package:flutter/material.dart';

class PartyRoomScreen extends StatefulWidget {
  final String? roomId;

  const PartyRoomScreen({Key? key, this.roomId}) : super(key: key);

  @override
  State<PartyRoomScreen> createState() => _PartyRoomScreenState();
}

class _PartyRoomScreenState extends State<PartyRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Room'),
      ),
      body: const Center(
        child: Text('Party Room - Coming Soon'),
      ),
    );
  }
}

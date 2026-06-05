import 'package:flutter/material.dart';

class ManualPage extends StatelessWidget {
  final String? jobId;
  const ManualPage({super.key, this.jobId});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Manual — TODO')));
}

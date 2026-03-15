import 'package:flutter/material.dart';

class SyncIndicator extends StatelessWidget {
  final bool isSynced;

  const SyncIndicator({super.key, required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSynced ? Icons.cloud_done : Icons.cloud_upload_outlined,
      size: 18,
      color: isSynced ? Colors.green : Colors.orange,
    );
  }
}
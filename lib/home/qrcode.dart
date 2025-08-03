import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ShowQrScreen extends StatelessWidget {
  final String
      qrUrl; // This will be base64 string like "data:image/png;base64,..."

  const ShowQrScreen({super.key, required this.qrUrl});

  @override
  Widget build(BuildContext context) {
    // Remove the "data:image/png;base64," prefix
    final base64Str = qrUrl.split(',').last;
    Uint8List bytes = base64Decode(base64Str);

    return Scaffold(
      appBar: AppBar(title: const Text("Your QR Code")),
      body: Center(
        child: Image.memory(bytes),
      ),
    );
  }
}

import 'dart:convert';
import 'package:reva/models/qr/qrModel.dart';
import '../baseFileService.dart';

class ReferralQRService {
  final BaseApiService _apiService = BaseApiService();

  /// Generate a new QR code
  Future<ReferralQRCodeModel?> generateQRCode(String purpose) async {
    final response = await _apiService.authenticatedPost(
      'qrgenerator',
      body: {'purpose': purpose},
    );

    if (response.statusCode == 200) {
      return ReferralQRCodeModel.fromJson(jsonDecode(response.body));
    } else {
      print("Failed to generate QR Code: ${response.body}");
      return null;
    }
  }

  /// Get all QR codes of user
  Future<List<ReferralQRCodeModel>> getQRCodesByUser() async {
    final response = await _apiService.authenticatedGet('qrverifier');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ReferralQRCodeModel.fromJson(e)).toList();
    } else {
      print("Failed to fetch QR Codes: ${response.body}");
      return [];
    }
  }

  Future<bool> verifyScannedQRCode(String scannedCode) async {
    final response = await _apiService.authenticatedGet(
      'qrverifier',
      // body: {'scannedCode': scannedCode},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Verification failed: ${response.body}");
      return false;
    }
  }
}

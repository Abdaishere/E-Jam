import 'dart:convert';
import 'package:e_jam/src/Model/Classes/Statistics/generator_statistics_instance.dart';
import 'package:e_jam/src/Model/Classes/Statistics/verifier_statistics_instance.dart';
import 'package:e_jam/src/Model/Shared/shared_preferences.dart';

class StatisticsService {
  Uri uri = Uri.parse('${NetworkController.serverIpAddress}');
  get client => NetworkController.client;

  Future<List<VerifierStatisticsInstance>>
      getAllVerifierStatisticsInstances() async {
    try {
      final response =
          await client.get(Uri.parse('$uri/statistics_all/verifier/earliest'));
      if (200 == response.statusCode) {
        return (jsonDecode(response.body) as List)
            .map((e) => VerifierStatisticsInstance.fromJson(e))
            .toList();
      } else if (204 == response.statusCode) {
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<GeneratorStatisticsInstance>>
      getAllGeneratorStatisticsInstance() async {
    try {
      final response =
          await client.get(Uri.parse('$uri/statistics_all/generator/earliest'));

      if (200 == response.statusCode) {
        return (jsonDecode(response.body) as List)
            .map((e) => GeneratorStatisticsInstance.fromJson(e))
            .toList();
      } else if (204 == response.statusCode) {
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

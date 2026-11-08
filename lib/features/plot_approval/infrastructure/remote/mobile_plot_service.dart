import '../../../../core/network/api_client.dart';

/// Backend endpoints the mobile apps use for plots (`mobile/plots`).
class MobilePlotService {
  const MobilePlotService(this._client);

  final ApiClient _client;

  Future<List<dynamic>> getPlots(String token) => _client.getList('mobile/plots', token: token);

  Future<void> putPlot(String token, int id, Map<String, dynamic> plot) =>
      _client.putJson('mobile/plots/$id', plot, token: token);
}

import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

import 'settings_service.dart';

enum OllamaModels {
  codellama34b('codellama:34b');

  final String value;

  const OllamaModels(this.value);
}

class OllamaClient {
  static OllamaClient? instance;

  OllamaEndpoint _endpoints;

  OllamaClient._init(this._endpoints);

  factory OllamaClient({
    String? host = 'localhost',
    int? port = 11434,
    bool? requireSSL = false,
  }) {
    return instance ??
        OllamaClient._init(
          OllamaEndpoint(
            host ?? 'locahost',
            port ?? 11434,
            requireSSL: requireSSL ?? false,
          ),
        );
  }

  Future<StreamedResponse> postGenerate(
    String prompt, {
    String? model,
    List? context,
    host,
    port,
    base,
    requireSSL,
  }) async {
    model ??= OllamaModels.codellama34b.value;

    host ??= await SettingService().serverAddress();
    port ??= await SettingService().serverPort();
    requireSSL ??= await SettingService().useTLSSSL();

    Uri? uri = _endpoints
        .generate(
          host: host,
          port: port,
          base: base,
          requireSSL: requireSSL,
        )
        .$1;
    if (uri != null) {
      Map<String, dynamic> body = {'prompt': prompt, 'model': model};

      if (context?.isNotEmpty == true) {
        body['context'] = context;
      }

      var bString = jsonEncode(body);
      // final Response response = await post(uri, body: bString);
      final request = Request('POST', uri);
      request.followRedirects = true;
      request.body = bString;
      final response = await Client().send(request);
      switch (response.statusCode) {
        case 200:
          return StreamedResponse(response.stream, 200);
        default:
          return throw Exception('Failed to load data');
      }
    }
    throw Exception('Failed to load data');
  }

  Future<List> getTags({
    host,
    port,
    base,
    requireSSL,
  }) async {
    Uri? uri = _endpoints
        .tags(
          host: host,
          port: port,
          base: base,
          requireSSL: requireSSL,
        )
        .$1;
    if (uri != null) {
      final response = await get(uri);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData['models'];
      } else {
        throw Exception('Request did not succeed');
      }
    }
    throw Exception('Invalid Uri');
  }
}

class OllamaEndpoint {
  const OllamaEndpoint(this._host, this._port, {this.requireSSL = false});

  final bool requireSSL;

  final String _host;
  final int _port;
  final String _base = '/api';

  /// Endpoints
  final String _generate = '/generate';
  final String _tags = '/tags';

  (Uri? uri, String? string) generate({host, port, base, requireSSL}) {
    String? url;
    Uri? result;

    try {
      url = _buildEndpointUrl(
        _generate,
        host: host,
        port: port,
        base: base,
        requireSSL: requireSSL,
      );
      result = Uri.tryParse(url);
    } catch (e) {
      debugPrint(e.toString());
    }

    return (result, url);
  }

  (Uri? uri, String? string) tags({host, port, base, requireSSL}) {
    String? url;
    Uri? result;

    try {
      url = _buildEndpointUrl(
        _tags,
        host: host,
        port: port,
        base: base,
        requireSSL: requireSSL,
      );
      result = Uri.tryParse(url);
    } catch (e) {
      debugPrint(e.toString());
    }

    return (result, url);
  }

  String _buildEndpointUrl(endpoint, {host, port, base, requireSSL}) {
    requireSSL ??= this.requireSSL;
    host ??= _host;
    port ??= _port;
    base ??= _base;
    return "http${requireSSL ? 's' : ''}://$host:$port$base$endpoint";
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:remind_caldav_client/src/multistatus/multistatus.dart';
import 'package:xml/xml.dart';

class CalResponse {
  final String url;
  final int statusCode;
  final Map<String, dynamic> headers;
  final XmlDocument? document;
  final MultiStatus? multistatus;

  CalResponse({
    required this.url,
    required this.statusCode,
    required this.headers,
    this.document,
  }) : multistatus = document != null ? MultiStatus.fromXml(document) : null;

  static Future<CalResponse> fromHttpResponse(HttpClientResponse response, String url) async {
    final headers = <String, dynamic>{};

    // set headers
    response.headers.forEach((name, values) {
      headers[name] = values.length == 1 ? values[0] : values;
    });

    final body = await utf8.decoder.bind(response).join();

    late final XmlDocument? document;

    try {
      document = XmlDocument.parse(body);
    } catch (e) {
      document = null;
    }

    return CalResponse(
      url: url,
      statusCode: response.statusCode,
      headers: headers,
      document: document,
    );
  }

  @override
  String toString() {
    return 'URL: $url\n' +
        'STATUS CODE: $statusCode\n' +
        'HEADERS:\n$headers\n' +
        'BODY:\n${document != null ? document!.toXmlString(pretty: true) : null}';
  }
}

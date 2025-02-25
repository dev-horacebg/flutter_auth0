part of auth0;

/// Class that makes API call easier
class DioWrapper {
  final Dio dio = Dio();
  final JsonDecoder _decoder = JsonDecoder();
  late String host;
  late String scheme;

  void configure(String baseUrl, int connectTimeout, int sendTimeout, int receiveTimeout, String accessToken,
      Auth0Client auth0client,
      {bool useLoggerInterceptor = false}) {
    var parsed = Uri.parse(baseUrl);
    scheme = parsed.scheme;
    host = parsed.host;

    dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = connectTimeout
      ..sendTimeout = sendTimeout
      ..receiveTimeout = receiveTimeout;
    if (useLoggerInterceptor) {
      dio
        ..interceptors.add(PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: true,
            error: true,
            compact: true,
            maxWidth: 90));
    }
  }

  String encodedTelemetry() {
    return base64.encode(utf8.encode(jsonEncode(telemetry)));
  }

  String url(String path, {dynamic query, bool includeTelemetry = false}) {
    dynamic params = query ?? {};
    if (includeTelemetry) {
      params['auth0Client'] = this.encodedTelemetry();
    }
    var parsed = Uri(
      scheme: scheme,
      host: host,
      path: path,
      queryParameters: Map.from(params),
    );
    return parsed.query.isEmpty ? parsed.toString().replaceAll('?', '') : parsed.toString();
  }

  /// DIO GET
  /// take [url], concrete route
  Future<Response> get(final String url, {Map<String, dynamic>? params, final Options? options}) async => await dio
          .get(
            url,
            queryParameters: params,
            options: options,
          )
          .then((response) => response)
          .catchError((error) {
        handleError(error, _decoder);
      });

  /// DIO POST
  /// take [url], concrete route
  Future<Response> post(final String url, {body, final Options? options}) async =>
      await dio.post(url, data: body, options: options).then((response) {
        return response;
      }).catchError((error) {
        handleError(error, _decoder);
      });

  /// DIO PATCH
  /// take [url], concrete route
  Future<Response> patch(final String url, {body, final Options? options}) async =>
      await dio.patch(url, data: body, options: options).then((response) {
        return response;
      }).catchError((error) {
        handleError(error, _decoder);
      });
}

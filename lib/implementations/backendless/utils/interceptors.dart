import 'dart:html';

import 'package:cloud_chat/implementations/backendless/utils/backendless_paths.dart';
import 'package:dio/dio.dart';

class ReauthenticationInterceptor extends InterceptorsWrapper {
  ReauthenticationInterceptor({
    required void Function() onReauthenticationRequired,
  }) : super(
          onError: (error, handler) {
            if (error.response?.statusCode == HttpStatus.forbidden) {
              onReauthenticationRequired();
              return;
            }

            return handler.next(error);
          },
        );
}

class AutomaticTokenInterceptor extends InterceptorsWrapper {
  AutomaticTokenInterceptor({
    required void Function(String) onTokenReceived,
    required String? Function() onTokenRequired,
  }) : super(
          onResponse: (response, handler) {
            if (response.requestOptions.path
                .endsWith(BackendlessPaths.loginPath)) {
              onTokenReceived(response.data["user-token"]);
            }
            return handler.next(response);
          },
          onRequest: (request, handler) {
            final token = onTokenRequired();
            request.headers["user-token"] = token;
            return handler.next(request);
          },
        );
}

class DefaultHeaderInterceptor extends InterceptorsWrapper {
  DefaultHeaderInterceptor({
    required String apiKey,
    required String applicationId,
  }) : super(
          onRequest: (request, handler) {
            request.headers["api-key"] = apiKey;
            request.headers["application-id"] = applicationId;
            return handler.next(request);
          },
        );
}

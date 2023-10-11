import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class DioLoading extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    EasyLoading.show(status: 'loading...');
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
    EasyLoading.dismiss();
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    EasyLoading.dismiss();
  }
}

import 'package:dio/dio.dart';
import 'package:music/dio/fltter/DioLoading.dart';

const String baseUrl = "https://www.musicenc.com";
const Map<String, String> headers = {"Accept": "*/*"};

Dio initDio() {
  final BaseOptions options = BaseOptions(baseUrl: baseUrl, headers: headers);
  var dio = Dio(options);
  // 添加拦截器
  dio.interceptors.add(DioLoading());
  return dio;
}

abstract class BaseService {
  Future<dynamic> getGetResponse(String url);
  Future<dynamic> getPostResponse(String url, dynamic data);
  Future<dynamic> getPutResponse(String url, dynamic data);
  Future<dynamic> getPatchResponse(String url, dynamic data);
  Future<dynamic> getDeleteResponse(String url);
}
// import 'package:dio/dio.dart';
// import 'dart:io';

// abstract class BaseService {
//   Future<dynamic> getPostResponse(String url, dynamic data);
// }

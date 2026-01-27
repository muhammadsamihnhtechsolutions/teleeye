import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eye_buddy/core/services/api/service/base_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/keys/shared_pref_keys.dart';
import '../../utils/keys/token_keys.dart';

class ApiService extends BaseService {
  static const Duration _connectTimeout = Duration(seconds: 120);
  static const Duration _receiveTimeout = Duration(seconds: 180);
  static const Duration _sendTimeout = Duration(seconds: 120);

  ApiService() {
    final options = BaseOptions(
      contentType: Headers.jsonContentType,
      headers: patientToken == ''
          ? <String, String>{
              'Accept': 'application/json',
              // 'Content-Type': 'application/json',
            }
          : <String, String>{
              // 'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $patientToken',
            },
      receiveTimeout: _receiveTimeout,
      connectTimeout: _connectTimeout,
      sendTimeout: _sendTimeout,
    );

    _dio = Dio(options);
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ),
    );
  }

  late Dio _dio;

  Future<void> _ensureAuthHeader() async {
    if (patientToken.trim().isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final stored = (prefs.getString(userTokenKey) ?? '').trim();
        if (stored.isNotEmpty) {
          patientToken = stored;
        }
      } catch (_) {
        // ignore
      }
    }
    _refreshAuthHeader();
  }

  void _refreshAuthHeader() {
    final headers = Map<String, dynamic>.from(_dio.options.headers);
    if (patientToken.trim().isEmpty) {
      headers.remove('Authorization');
    } else {
      headers['Authorization'] = 'Bearer $patientToken';
    }
    _dio.options.headers = headers;
  }

  @override
  Future getDeleteResponse(String url, {payloadData = ''}) async {
    dynamic responseJson;

    Response? response;

    await _ensureAuthHeader();

    try {
      response = await _dio.delete(
        url,
        //data: payloadData,
        //queryParameters: payloadData
      );
      responseJson = returnResponse(response);
    } on DioException catch (error) {
      if (error.response != null) {
        responseJson = returnResponse(error.response!);
      } else {
        responseJson = {
          'error': true,
          'message': error.message ?? 'An error occurred',
          'data': [],
        };
      }
    } on SocketException {
      return {'error': true, 'message': 'No internet connection.', 'data': []};
    } catch (e) {
      if (e is DioException) {
        print("Response at Repo ${e.response?.data["message"]}");
        return {
          'error': true,
          'message': e.response?.data['message'],
          'data': [],
        };
      }
    }

    return responseJson;
  }

  @override
  Future getGetResponse(String url) async {
    dynamic responseJson;

    Response response;

    await _ensureAuthHeader();
    try {
      response = await _dio.get(url);
      responseJson = returnResponse(response);
    } on DioException catch (error) {
      if (error.response != null) {
        responseJson = returnResponse(error.response!);
      } else {
        responseJson = {
          'error': true,
          'message': error.message ?? 'An error occurred',
          'data': [],
        };
      }
    } on SocketException {
      return {'error': true, 'message': 'No internet connection.', 'data': []};
    } catch (e) {
      if (e is DioException) {
        print("Response at Repo ${e.response?.data["message"]}");

        return {
          'error': true,
          'message': e.response?.data['message'],
          'data': [],
        };
      }
    }
    return responseJson;
  }

  Future getGetQueryParametersResponse(
    String url,
    Map<String, dynamic> parameters,
  ) async {
    dynamic responseJson;

    Response response;

    await _ensureAuthHeader();
    try {
      response = await _dio.get(url, queryParameters: parameters);
      responseJson = returnResponse(response);
    } on DioException catch (error) {
      if (error.response != null) {
        responseJson = returnResponse(error.response!);
      } else {
        responseJson = {
          'error': true,
          'message': error.message ?? 'An error occurred',
          'data': [],
        };
      }
    } on SocketException {
      return {'error': true, 'message': 'No internet connection.', 'data': []};
    } catch (e) {
      if (e is DioException) {
        print("Response at Repo ${e.response?.data["message"]}");

        return {
          'error': true,
          'message': e.response?.data['message'],
          'data': [],
        };
      }
    }
    return responseJson;
  }

  @override
  Future getPostResponse(String url, data) async {
    dynamic responseJson;
    Response response;

    await _ensureAuthHeader();
    try {
      response = await _dio.post(url, data: data);
      //log("Your Response : $response");
      responseJson = returnResponse(response);
      //log("Your Response : $responseJson");
    } on DioException catch (error) {
      if (error.response != null) {
        responseJson = returnResponse(error.response!);
      } else {
        responseJson = {
          'error': true,
          'message': error.message ?? 'An error occurred',
          'data': [],
        };
      }
    } on SocketException {
      return {'error': true, 'message': 'No internet connection.', 'data': []};
    } catch (e) {
      if (e is DioException) {
        print("Response at Repo ${e.response?.data["message"]}");
        return {
          'error': true,
          'message': e.response?.data['message'] ?? 'An error occurred',
          'data': [],
        };
      }
    }
    return responseJson;
  }

  @override
  Future getPutResponse(String url, data) async {
    //print("calling put");
    dynamic responseJson;

    //Response? response;
    Response response;

    await _ensureAuthHeader();
    try {
      response = await _dio.put(url, data: data);
      //log("Your Response : $response");
      responseJson = returnResponse(response);
      //log("Your Response : $responseJson");
    } on DioException catch (error) {
      if (error.response != null) {
        responseJson = returnResponse(error.response!);
      } else {
        responseJson = {
          'error': true,
          'message': error.message ?? 'An error occurred',
          'data': [],
        };
      }
    } on SocketException {
      return {'error': true, 'message': 'No internet connection.', 'data': []};
    } catch (e) {
      if (e is DioException) {
        // print("Response at Repo ${e.response?.data["message"]}");
        return {
          'error': true,
          'message': e.response?.data['message'],
          'data': [],
        };
      }
    }
    return responseJson;
  }

  @override
  Future getPatchResponse(String url, data) async {
    //print("calling put");
    dynamic responseJson;

    //Response? response;
    Response response;

    await _ensureAuthHeader();
    try {
      response = await _dio.patch(url, data: data);
      //log("Your Response : $response");
      responseJson = returnResponse(response);
      //log("Your Response : $responseJson");
    } on DioException catch (error) {
      if (error.response != null) {
        responseJson = returnResponse(error.response!);
      } else {
        responseJson = {
          'error': true,
          'message': error.message ?? 'An error occurred',
          'data': [],
        };
      }
    } on SocketException {
      return {'error': true, 'message': 'No internet connection.', 'data': []};
    } catch (e) {
      if (e is DioException) {
        // print("Response at Repo ${e.response?.data["message"]}");
        return {
          'error': true,
          'message': e.response?.data['message'],
          'data': [],
        };
      }
    }
    return responseJson;
  }

  @visibleForTesting
  dynamic returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        return response.data;
      case 201:
        return response.data;
      case 400:
        return response.data;
      case 404:
        return response.data;
      case 422:
        return response.data;
      case 401:
        // boxStorage.erase();
        // Get.offAll(FutureWedslyHomePage);
        return response.data;
      case 403:
        // boxStorage.erase();
        // Get.offAll(FutureWedslyHomePage);
        return response.data;
      case 500:
        log('RESPONSE DATA : ${response.data.toString()}');
        return response.data;
      default:
        log('RESPONSE DATA : ${response.data.toString()}');
        return response.data;
      // throw FetchDataException('Error occurred while communication with server'
      //     ' with status code : ${response.statusCode}');
    }
  }
}
// import 'dart:developer';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:eye_buddy/core/services/utils/keys/token_keys.dart';
// import 'base_service.dart';
// import 'api_constants.dart';

// class ApiService extends BaseService {
//   late Dio _dio;

//   ApiService() {
//     final options = BaseOptions(
//       contentType: Headers.jsonContentType,
//       headers: patientToken == ''
//           ? {'Accept': 'application/json'}
//           : {
//               'Accept': 'application/json',
//               'Authorization': 'Bearer $patientToken',
//             },
//       receiveTimeout: const Duration(seconds: 15),
//       connectTimeout: const Duration(seconds: 15),
//     );

//     _dio = Dio(options);
//   }

//   /// POST
//   @override
//   Future<dynamic> getPostResponse(String url, dynamic data) async {
//     try {
//       final response = await _dio.post(url, data: data);
//       return _returnResponse(response);
//     } on DioException catch (error) {
//       if (error.response != null) return _returnResponse(error.response!);
//       return {'error': true, 'message': 'Something went wrong'};
//     } on SocketException {
//       return {'error': true, 'message': 'No internet connection'};
//     } catch (e) {
//       return {'error': true, 'message': e.toString()};
//     }
//   }

//   /// GET
//   @override
//   Future<dynamic> getGetResponse(String url) async {
//     try {
//       final response = await _dio.get(url);
//       return _returnResponse(response);
//     } on DioException catch (error) {
//       if (error.response != null) return _returnResponse(error.response!);
//       return {'error': true, 'message': 'Something went wrong'};
//     } on SocketException {
//       return {'error': true, 'message': 'No internet connection'};
//     } catch (e) {
//       return {'error': true, 'message': e.toString()};
//     }
//   }

//   /// PUT
//   @override
//   Future<dynamic> getPutResponse(String url, dynamic data) async {
//     try {
//       final response = await _dio.put(url, data: data);
//       return _returnResponse(response);
//     } on DioException catch (error) {
//       if (error.response != null) return _returnResponse(error.response!);
//       return {'error': true, 'message': 'Something went wrong'};
//     } on SocketException {
//       return {'error': true, 'message': 'No internet connection'};
//     } catch (e) {
//       return {'error': true, 'message': e.toString()};
//     }
//   }

//   /// PATCH
//   @override
//   Future<dynamic> getPatchResponse(String url, dynamic data) async {
//     try {
//       final response = await _dio.patch(url, data: data);
//       return _returnResponse(response);
//     } on DioException catch (error) {
//       if (error.response != null) return _returnResponse(error.response!);
//       return {'error': true, 'message': 'Something went wrong'};
//     } on SocketException {
//       return {'error': true, 'message': 'No internet connection'};
//     } catch (e) {
//       return {'error': true, 'message': e.toString()};
//     }
//   }

//   /// DELETE
//   @override
//   Future<dynamic> getDeleteResponse(String url) async {
//     try {
//       final response = await _dio.delete(url);
//       return _returnResponse(response);
//     } on DioException catch (error) {
//       if (error.response != null) return _returnResponse(error.response!);
//       return {'error': true, 'message': 'Something went wrong'};
//     } on SocketException {
//       return {'error': true, 'message': 'No internet connection'};
//     } catch (e) {
//       return {'error': true, 'message': e.toString()};
//     }
//   }

//   /// OTP Login Helper
//   Future<dynamic> verifyOtp({
//     required String traceId,
//     required String code,
//     String? deviceToken,
//   }) async {
//     return getPostResponse(ApiConstants.verifyOtp, {
//       "traceId": traceId,
//       "code": code,
//       "deviceToken": deviceToken ?? "",
//     });
//   }

//   /// Resend OTP Helper
//   Future<dynamic> resendOtp({required String traceId}) async {
//     return getPostResponse(ApiConstants.resendOtp, {"traceId": traceId});
//   }

//   /// Response handler
//   dynamic _returnResponse(Response response) {
//     switch (response.statusCode) {
//       case 200:
//       case 201:
//       case 400:
//       case 401:
//       case 403:
//       case 422:
//       case 404:
//         return response.data;
//       case 500:
//         log('Server Error: ${response.data.toString()}');
//         return response.data;
//       default:
//         log('Unexpected Status Code: ${response.statusCode.toString()}');
//         return response.data;
//     }
//   }
// }

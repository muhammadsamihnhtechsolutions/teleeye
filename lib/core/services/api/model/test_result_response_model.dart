import 'dart:convert';

class TestResultResponseModel {
  TestResultResponseModel({this.status, this.message, this.data});

  final String? status;
  final String? message;
  final TestResultResponseData? data;

  factory TestResultResponseModel.fromJson(Map<String, dynamic> json) {
    return TestResultResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? TestResultResponseData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  factory TestResultResponseModel.fromJsonString(String jsonStr) {
    return TestResultResponseModel.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }
}

class TestResultResponseData {
  TestResultResponseData({
    this.docs,
    this.totalDocs,
    this.limit,
    this.page,
    this.totalPages,
    this.pagingCounter,
    this.hasPrevPage,
    this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  final List<TestResult>? docs;
  final int? totalDocs;
  final int? limit;
  final int? page;
  final int? totalPages;
  final int? pagingCounter;
  final bool? hasPrevPage;
  final bool? hasNextPage;
  final String? prevPage;
  final String? nextPage;

  factory TestResultResponseData.fromJson(Map<String, dynamic> json) {
    return TestResultResponseData(
      docs: (json['docs'] is List)
          ? (json['docs'] as List)
                .whereType<Map<String, dynamic>>()
                .map(TestResult.fromJson)
                .toList()
          : <TestResult>[],
      totalDocs: json['totalDocs'] is num
          ? (json['totalDocs'] as num).toInt()
          : null,
      limit: json['limit'] is num ? (json['limit'] as num).toInt() : null,
      page: json['page'] is num ? (json['page'] as num).toInt() : null,
      totalPages: json['totalPages'] is num
          ? (json['totalPages'] as num).toInt()
          : null,
      pagingCounter: json['pagingCounter'] is num
          ? (json['pagingCounter'] as num).toInt()
          : null,
      hasPrevPage: json['hasPrevPage'] as bool?,
      hasNextPage: json['hasNextPage'] as bool?,
      prevPage: json['prevPage']?.toString(),
      nextPage: json['nextPage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docs': docs?.map((e) => e.toJson()).toList(),
      'totalDocs': totalDocs,
      'limit': limit,
      'page': page,
      'totalPages': totalPages,
      'pagingCounter': pagingCounter,
      'hasPrevPage': hasPrevPage,
      'hasNextPage': hasNextPage,
      'prevPage': prevPage,
      'nextPage': nextPage,
    };
  }
}

class TestResult {
  TestResult({
    this.id,
    this.title,
    this.attachment,
    this.status,
    this.createdAt,
  });

  final String? id;
  final String? title;
  final String? attachment;
  final String? status;
  final String? createdAt;

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['_id']?.toString(),
      title: json.containsKey('title')
          ? (json['title']?.toString().isNotEmpty == true
                ? json['title']?.toString()
                : 'No Title Found')
          : '',
      attachment: json['attachment']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'attachment': attachment,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

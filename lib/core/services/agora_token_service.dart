// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// /// Service for fetching Agora tokens from the server
// class AgoraTokenService {
//   static const String _baseUrl =
//       'https://your-api-server.com/api'; // Replace with your actual API base URL

//   /// Fetch Agora token for a specific channel
//   static Future<String?> fetchToken({
//     required String channelId,
//     required int uid,
//     String? appointmentId,
//   }) async {
//     try {
//       log('TOKEN SERVICE: Fetching token for channel: $channelId');

//       final response = await http
//           .post(
//             Uri.parse('$_baseUrl/agora/token'),
//             headers: {
//               'Content-Type': 'application/json',
//               // Add authentication headers if needed
//               // 'Authorization': 'Bearer $authToken',
//             },
//             body: jsonEncode({
//               'channelName': channelId,
//               'uid': uid,
//               'appointmentId': appointmentId,
//               'role': 'publisher', // or 'subscriber' as needed
//             }),
//           )
//           .timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final token = data['token'] as String?;

//         if (token != null && token.isNotEmpty) {
//           log('TOKEN SERVICE: Token fetched successfully');
//           return token;
//         } else {
//           log('TOKEN SERVICE ERROR: Empty token in response');
//           return null;
//         }
//       } else {
//         log(
//           'TOKEN SERVICE ERROR: Failed to fetch token - ${response.statusCode}',
//         );
//         log('TOKEN SERVICE ERROR: Response body - ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       log('TOKEN SERVICE ERROR: Exception while fetching token - $e');
//       return null;
//     }
//   }

//   /// Generate a temporary token for testing (remove in production)
//   static String generateTestToken(String channelId, int uid) {
//     log(
//       'TOKEN SERVICE WARNING: Using test token - replace with real API in production',
//     );
//     // This is a placeholder - replace with actual token generation logic
//     // In production, you should always fetch from your server
//     return '007eJxTYDjDvephdun5qU923LPh/qKue0OvWjOtsEDXK93pwVuNzmAFhjSzJEMTg1QzIxMTQxNTC4Mkg1TjNHNLA3PT1CQTo8TUpIUCKQ2BjAzlJ/ezMDJAIIjPzlCUn59raGTMwAAAoF0fpw==';
//   }
// }

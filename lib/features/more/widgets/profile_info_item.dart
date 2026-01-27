import 'package:flutter/material.dart';

// class ProfileInfoItem extends StatelessWidget {
//   final String title;
//   final String value;

//   const ProfileInfoItem({super.key, required this.title, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 14, color: Colors.black54),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
// }
class ProfileInfoItem extends StatelessWidget {
  final String title;
  final String titleDetails;

  const ProfileInfoItem({
    super.key,
    required this.title,
    required this.titleDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (titleDetails.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            titleDetails,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

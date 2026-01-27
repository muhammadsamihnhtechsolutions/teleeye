import 'package:eye_buddy/features/global_widgets/inter_text.dart'; // File not found
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selectcropcompressimage/selectcropcompressimage.dart';

Future<void> selectImage(BuildContext context, Function callBackFunction) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          width: MediaQuery.of(context).size.width * .6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  await SelectCropCompressImage()
                      .selectCropCompressImageFromGallery(
                        compressionAmount: 30,
                        context: context,
                      )
                      .then((selectedCroppedAndCompressImage) {
                        if (selectedCroppedAndCompressImage != null) {
                          callBackFunction(selectedCroppedAndCompressImage);
                          Navigator.pop(context);
                        }
                      });
                },
                child: InterText(title: 'Select from storage'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 40,
                    maxWidth: 700,
                    maxHeight: 700,
                  );
                  if (picked != null) {
                    callBackFunction(File(picked.path));
                    Navigator.pop(context);
                  }
                },
                child: InterText(title: 'Take image'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

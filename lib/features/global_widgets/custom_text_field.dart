// import 'package:eye_buddy/app/utils/config/app_colors.dart';
// import 'package:eye_buddy/app/views/global_widgets/inter_text.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    required this.textEditingController,
    super.key,
    this.hPadding = 10,
    this.vPadding = 8,
    this.textColor = Colors.black,
    this.hint,
    this.maxLines = 1,
    this.isPassword = false,
    this.containsPrefix = false,
    this.containsSuffix = false,
    this.prefixSvgPath = '',
    this.suffixSvgPath = '',
    this.prefixOnTapFunction,
    this.sufffixOnTapFunction,
    this.isEnabled = true,
    this.textInputType = TextInputType.text,
    // required this.validateFormFunction,
    this.showBorders = true,
    this.inputFormatters,
    this.validator,
    this.maxLength,
    this.onChanged,
  });

  final double hPadding;
  final double vPadding;
  final Color textColor;
  final bool isEnabled;
  final String? hint;
  final int maxLines;
  // Function validateFormFunction;
  final TextEditingController textEditingController;
  final bool? isPassword;
  final bool containsPrefix;
  final bool containsSuffix;
  final String prefixSvgPath;
  final String suffixSvgPath;
  final Function? prefixOnTapFunction;
  final Function? sufffixOnTapFunction;
  final TextInputType? textInputType;
  final bool showBorders;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  // final FocusNode focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final customBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(
        context,
        color: !showBorders ? Colors.transparent : AppColors.colorBBBBBB,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    );
    return TextFormField(
      //focusNode: focus,
      keyboardType: textInputType,
      maxLength: maxLength,
      buildCounter:
          (
            context, {
            required currentLength,
            required isFocused,
            required maxLength,
          }) => null,
      textAlignVertical: TextAlignVertical.center,
      controller: textEditingController,
      style: interTextStyle,
      maxLines: maxLines,
      textCapitalization: isPassword == true
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      cursorColor: AppColors.primaryColor,
      enabled: isEnabled,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        suffixIcon: suffixSvgPath == ''
            ? const SizedBox.shrink()
            : Padding(
                padding: EdgeInsets.only(right: hPadding),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: Align(child: SvgPicture.asset(suffixSvgPath)),
                ),
              ),
        hintText: hint ?? '',
        hintStyle: interTextStyle.copyWith(
          color: AppColors.color888E9D,
          fontSize: 11,
        ),
        filled: true,
        fillColor: AppColors.appBackground,
        // helperText: " ",
        contentPadding: EdgeInsets.symmetric(
          horizontal: hPadding,
          vertical: maxLines > 1 ? 15 : vPadding,
        ),
        border: customBorder,
        enabledBorder: customBorder,
        disabledBorder: customBorder,
        focusedBorder: OutlineInputBorder(
          borderSide: Divider.createBorderSide(
            context,
            color: !showBorders ? Colors.transparent : AppColors.primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: Divider.createBorderSide(
            context,
            color: !showBorders ? Colors.transparent : AppColors.colorF14F4A,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: Divider.createBorderSide(
            context,
            color: !showBorders ? Colors.transparent : AppColors.colorF14F4A,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: interTextStyle,
      ),
      validator: validator,
      // validator: (value) {
      //   final validator = validateFormFunction(value);
      //   if (validator == null) {
      //     return null;
      //   } else {
      //     log('Requesting focus');
      //     //focus.requestFocus();
      //     // return validator;
      //   }
      // },
    );
  }
}

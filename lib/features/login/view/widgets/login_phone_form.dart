import 'package:country_code_picker/country_code_picker.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/features/global_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const int kMaxE164NationalNumberLength = 15;

class LoginPhoneTextField extends StatefulWidget {
  const LoginPhoneTextField({
    super.key,
    required this.phoneNumberController,
    required this.countryCodeController,
    required this.countryIsoCodeController,
    this.onPhoneChanged,
    this.onCountryChanged,
  });

  final TextEditingController phoneNumberController;
  final TextEditingController countryCodeController;
  final TextEditingController countryIsoCodeController;
  final ValueChanged<String>? onPhoneChanged;
  final VoidCallback? onCountryChanged;

  @override
  State<LoginPhoneTextField> createState() => _LoginPhoneTextFieldState();
}

class _LoginPhoneTextFieldState extends State<LoginPhoneTextField> {
  int _maxLength = kMaxE164NationalNumberLength;

  @override
  void initState() {
    super.initState();
    widget.countryCodeController.text = "+880";
    widget.countryIsoCodeController.text = "BD";
    widget.onCountryChanged?.call();
    widget.onPhoneChanged?.call(widget.phoneNumberController.text);
  }

  void _applyCountrySelection({
    required String dialCode,
    required String isoCode,
  }) {
    widget.countryCodeController.text = dialCode;
    widget.countryIsoCodeController.text = isoCode;
    widget.onCountryChanged?.call();

    const nextMaxLength = kMaxE164NationalNumberLength;
    if (_maxLength != nextMaxLength) {
      setState(() {
        _maxLength = nextMaxLength;
      });
    }

    final current = widget.phoneNumberController.text;
    if (current.length > nextMaxLength) {
      widget.phoneNumberController.text = current.substring(0, nextMaxLength);
      widget.phoneNumberController.selection = TextSelection.collapsed(
        offset: widget.phoneNumberController.text.length,
      );
      widget.onPhoneChanged?.call(widget.phoneNumberController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      width: getWidth(context: context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.colorBBBBBB, width: 1.5),
      ),
      padding: EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              color: AppColors.colorEFEFEF,
            ),
            alignment: Alignment.center,
            height: double.maxFinite,
            // child: InterText(
            //   title: "🇧🇩 +880",
            // ),
            child: CountryCodePicker(
              onChanged: (value) {
                final dialCode = value.dialCode;
                if (dialCode == null) return;
                final isoCode = value.code;
                if (isoCode == null) return;
                _applyCountrySelection(dialCode: dialCode, isoCode: isoCode);
              },
              initialSelection: '+880',
              favorite: ['+880'],
              showCountryOnly: false,
              showOnlyCountryWhenClosed: false,
              alignLeft: false,
              showDropDownButton: true,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.only(right: 5),
              flagWidth: 16,
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.dialCodeColor,
              ),
            ),
          ),
          Expanded(
            child: CustomTextFormField(
              textEditingController: widget.phoneNumberController,
              showBorders: false,
              textInputType: TextInputType.phone,
              maxLength: _maxLength,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_maxLength),
              ],
              onChanged: widget.onPhoneChanged,
            ),
          ),
        ],
      ),
    );

    // CustomTextFormField(
    //   textEditingController: phoneNumberController,
    // );

    //  IntlPhoneField(
    //   // initialValue: countryCode,
    //   // initialCountryCode: countryCode,
    //   controller: phoneNumberController,
    //   cursorColor: AppColors.primaryColor,
    //   dropdownTextStyle: interTextStyle,
    //   style: interTextStyle,
    //   dropdownIcon: const Icon(
    //     Icons.keyboard_arrow_down_rounded,
    //     color: AppColors.primaryColor,
    //     size: 20,
    //   ),
    //   validator: (p0) {
    //     return null;

    //     // return InputValidation(p0!.number.toString()).isCorrectPhoneNumber();
    //   },

    //   flagsButtonMargin: const EdgeInsets.only(left: 15),
    //   dropdownIconPosition: IconPosition.trailing,
    //   disableLengthCheck: true,
    //   keyboardType: TextInputType.number,
    //   pickerDialogStyle: PickerDialogStyle(
    //     listTileDivider: const SizedBox(height: 1),
    //     countryCodeStyle: interTextStyle,
    //     countryNameStyle: interTextStyle,
    //     backgroundColor: AppColors.appBackground,
    //     searchFieldCursorColor: AppColors.primaryColor,
    //     searchFieldInputDecoration: InputDecoration(
    //       filled: true,
    //       fillColor: Colors.white,
    //       hintText: 'Search',
    //       hintStyle: interTextStyle.copyWith(
    //         color: AppColors.colorBBBBBB,
    //       ),
    //       contentPadding: const EdgeInsets.symmetric(
    //         horizontal: 10,
    //         // vertical: vPadding,
    //       ),
    //       border: OutlineInputBorder(
    //         borderSide: Divider.createBorderSide(
    //           context,
    //           color: AppColors.colorBBBBBB,
    //           width: 1,
    //         ),
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //       enabledBorder: OutlineInputBorder(
    //         borderSide: Divider.createBorderSide(
    //           context,
    //           color: AppColors.colorBBBBBB,
    //           width: 1,
    //         ),
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //       focusedBorder: OutlineInputBorder(
    //         borderSide: Divider.createBorderSide(
    //           context,
    //           color: AppColors.primaryColor,
    //           width: 2,
    //         ),
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //     ),
    //   ),
    //   decoration: InputDecoration(
    //     hintText: 'XXXXXXXXXX',
    //     hintStyle: interTextStyle.copyWith(
    //       color: AppColors.colorBBBBBB,
    //     ),
    //     contentPadding: const EdgeInsets.symmetric(
    //       horizontal: 10,
    //       // vertical: vPadding,
    //     ),
    //     filled: true,
    //     fillColor: Colors.white,
    //     border: OutlineInputBorder(
    //       borderSide: Divider.createBorderSide(
    //         context,
    //         color: AppColors.colorBBBBBB,
    //         width: 1,
    //       ),
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     enabledBorder: OutlineInputBorder(
    //       borderSide: Divider.createBorderSide(
    //         context,
    //         color: AppColors.colorBBBBBB,
    //         width: 1,
    //       ),
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     focusedBorder: OutlineInputBorder(
    //       borderSide: Divider.createBorderSide(
    //         context,
    //         color: AppColors.primaryColor,
    //         width: 2,
    //       ),
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //   ),
    //   onCountryChanged: (value) {
    //     countryCodeController.text = value.dialCode;
    //   },
    // );
  }
}

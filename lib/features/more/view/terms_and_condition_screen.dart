import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionScreen extends StatefulWidget {
  const TermsAndConditionScreen({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  late final WebViewController _controller;
  bool _failedToLoad = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() {
              _failedToLoad = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: widget.title,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: _failedToLoad
          ? Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20),
                vertical: getProportionateScreenWidth(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterText(
                    title: widget.title,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  CommonSizeBox(height: getProportionateScreenHeight(10)),
                  InterText(
                    title: 'Unable to load. Please try opening in browser.',
                    fontSize: 14,
                    textColor: AppColors.color888E9D,
                  ),
                  const Spacer(),
                  CustomButton(
                    title: 'Open in browser',
                    callBackFunction: () async {
                      final launched = await launchUrlString(
                        widget.url,
                        mode: LaunchMode.externalApplication,
                      );
                      if (!launched && context.mounted) {
                        showToast(
                          message: 'Unable to open link',
                          context: context,
                        );
                      }
                    },
                  ),
                  CommonSizeBox(height: getProportionateScreenHeight(12)),
                ],
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}

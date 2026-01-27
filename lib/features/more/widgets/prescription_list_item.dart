import 'package:eye_buddy/core/services/api/model/prescription_list_response_model.dart';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/widgets/prescription_option_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';

class PrescriptionListItem extends StatefulWidget {
  final Prescription prescription;
  final bool showAddToMedicine;
  final bool showUploaderLabel;

  const PrescriptionListItem({
    required this.prescription,
    this.showAddToMedicine = true,
    this.showUploaderLabel = true,
    super.key,
  });

  @override
  State<PrescriptionListItem> createState() => _PrescriptionListItemState();
}

class _PrescriptionListItemState extends State<PrescriptionListItem> {
  bool _isOpening = false;

  String _resolveS3Url(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    return '${ApiConstants.imageBaseUrl}$v';
  }

  String _normalizeDoctorLabel(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) return 'Doctor';
    final lower = name.toLowerCase();
    if (lower.startsWith('dr ') ||
        lower.startsWith('dr.') ||
        lower.startsWith('doctor')) {
      return name;
    }
    return 'Dr. $name';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MoreController>();
    final l10n = AppLocalizations.of(context);
    final fileUrl = _resolveS3Url(widget.prescription.file);

    final lower = fileUrl.toLowerCase();
    final isPdf = lower.endsWith('.pdf');
    final isImage =
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');

    final isRxTitle =
        (widget.prescription.title ?? '').trim().toLowerCase() == 'rx';

    final doctorLabel = _normalizeDoctorLabel(
      (widget.prescription.patientDetails?.name ?? '').toString(),
    );
    final uploaderLabel = isRxTitle ? doctorLabel : (l10n?.myself ?? 'My Self');
    final rawTitle = (widget.prescription.title ?? '').trim();
    final isMissingTitle =
        rawTitle.isEmpty || rawTitle.toLowerCase() == 'no data';
    final displayTitle = isMissingTitle
        ? doctorLabel
        : controller.prescriptionDisplayTitle(widget.prescription);
    final firstInstruction = widget.showAddToMedicine
        ? (widget.prescription.medicines ?? const [])
            .map((m) => (m.instructions ?? '').trim())
            .firstWhere((v) => v.isNotEmpty, orElse: () => '')
        : '';

    Future<void> openPrescription() async {
      if (fileUrl.isEmpty) return;
      if (_isOpening) return;
      if (mounted) setState(() => _isOpening = true);

      try {
        if (isImage) {
          await Get.dialog(
            Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      child: Image.network(
                        fileUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text('Failed to load image'),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
          );
          return;
        }

        if (isPdf) {
          bool loaderShown = false;
          try {
            loaderShown = true;
            Get.dialog(
              const Center(child: CircularProgressIndicator()),
              barrierDismissible: false,
            );

            await controller.openPrescriptionPreview(
              fileUrl: fileUrl,
              title: widget.prescription.title,
            );
          } finally {
            if (loaderShown && (Get.isDialogOpen ?? false)) {
              Get.back();
            }
          }
          return;
        }

        await Get.to(
          () => _PrescriptionWebViewScreen(
            url: fileUrl,
            title: (widget.prescription.title ?? 'Prescription').toString(),
          ),
        );
      } finally {
        if (mounted) setState(() => _isOpening = false);
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
        border: Border.all(color: AppColors.colorEFEFEF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(getProportionateScreenWidth(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: openPrescription,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.colorE6F2EE,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isImage
                        ? Image.network(
                            fileUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: AppColors.primaryColor,
                                  size: 44,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              );
                            },
                          )
                        : (isPdf
                            ? IgnorePointer(
                                child: SfPdfViewer.network(
                                  fileUrl,
                                  pageSpacing: 0,
                                  canShowPaginationDialog: false,
                                  canShowPageLoadingIndicator: false,
                                  canShowScrollHead: false,
                                  canShowScrollStatus: false,
                                  canShowHyperlinkDialog: false,
                                  canShowPasswordDialog: false,
                                  canShowTextSelectionMenu: false,
                                  enableTextSelection: false,
                                  enableDoubleTapZooming: false,
                                  initialZoomLevel: 2.2,
                                  pageLayoutMode: PdfPageLayoutMode.single,
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.description,
                                  color: AppColors.primaryColor,
                                  size: 44,
                                ),
                              )),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      await controller.sharePrescription(
                        file: fileUrl,
                        title: widget.prescription.title,
                      );
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: AppColors.colorE6F2EE,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.ios_share,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.bottomSheet(
                        PrescriptionOptionBottomSheet(
                        prescription: widget.prescription,
                        showAddToMedicine: widget.showAddToMedicine,
                      ),
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: AppColors.colorE6F2EE,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.more_vert,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CommonSizeBox(height: getProportionateScreenHeight(7)),
          InterText(
            title: controller.formatDate(
              widget.prescription.createdAt.toString(),
            ),
            fontSize: 12,
            textColor: AppColors.color888E9D,
            maxLines: 1,
          ),
          CommonSizeBox(height: getProportionateScreenWidth(5)),
          InterText(
            title: displayTitle,
            fontSize: 14,
            textColor: AppColors.black,
            maxLines: 2,
          ),
          if (firstInstruction.isNotEmpty) ...[
            CommonSizeBox(height: getProportionateScreenWidth(3)),
            InterText(
              title: firstInstruction,
              fontSize: 12,
              textColor: AppColors.color888E9D,
              maxLines: 2,
            ),
          ],
          if (widget.showUploaderLabel) ...[
            CommonSizeBox(height: getProportionateScreenWidth(4)),
            InterText(
              title: uploaderLabel,
              fontSize: 12,
              textColor: AppColors.color888E9D,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrescriptionWebViewScreen extends StatefulWidget {
  const _PrescriptionWebViewScreen({required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<_PrescriptionWebViewScreen> createState() =>
      _PrescriptionWebViewScreenState();
}

class _PrescriptionWebViewScreenState
    extends State<_PrescriptionWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  String _viewerUrl(String raw) {
    final lower = raw.toLowerCase();
    if (lower.endsWith('.pdf')) {
      final encoded = Uri.encodeComponent(raw);
      return 'https://docs.google.com/gview?embedded=1&url=$encoded';
    }
    return raw;
  }

  @override
  void initState() {
    super.initState();
    final url = _viewerUrl(widget.url);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

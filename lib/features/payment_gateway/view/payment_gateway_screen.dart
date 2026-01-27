import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/controler/app_state_controller.dart';
import '../../../core/services/api/model/doctor_list_response_model.dart';
import '../../../core/services/api/model/patient_list_model.dart';
import '../../../core/services/api/service/api_constants.dart';
import '../../../features/global_widgets/toast.dart';
import '../../../l10n/app_localizations.dart';
import '../../appointments/controller/appointment_controller.dart';
import '../../reason_for_visit/controller/reason_for_visit_controller.dart';

enum _TerminalPaymentResult { none, success, failed, cancel }

class PaymentGatewayScreen extends StatefulWidget {
  const PaymentGatewayScreen({super.key});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  InAppWebViewController? _controller;
  late final String _initialUrl;
  bool _isLoading = true;
  int _progress = 0;
  bool _handledTerminalResult = false;
  bool _isProcessingTerminalResult = false;
  bool _didWatchdogReload = false;
  Timer? _loadWatchdogTimer;
  Timer? _slowUiTimer;
  bool _showSlowLoadActions = false;
  bool _isOpeningExternal = false;
  int? _popupWindowId;
  String _appointmentId = '';
  final Stopwatch _loadStopwatch = Stopwatch();
  Map<String, dynamic> _args = <String, dynamic>{};

  Future<bool> _handleExternalScheme(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final scheme = uri.scheme.toLowerCase();
    if (scheme.isEmpty ||
        scheme == 'http' ||
        scheme == 'https' ||
        scheme == 'about' ||
        scheme == 'data' ||
        scheme == 'blob') {
      return false;
    }
    try {
      return await launchUrlString(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<NavigationActionPolicy> _decideNavigation(String url) async {
    if (url.isEmpty) return NavigationActionPolicy.ALLOW;
    if (await _handleExternalScheme(url)) {
      return NavigationActionPolicy.CANCEL;
    }
    if (_handlePaymentUrlIfTerminal(url)) {
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

  bool _isCancelledWebError(WebResourceError error) {
    return error.type == WebResourceErrorType.CANCELLED;
  }

  String _normalizeUrl(String raw) {
    final trimmed = raw.trim();
    // Remove stray whitespace/newlines that can sneak in from API/log formatting.
    final cleaned = trimmed.replaceAll(RegExp(r'\\s+'), '');
    if (cleaned.isEmpty) return '';
    // If the scheme is missing but it looks like a host, default to https.
    final parsed = Uri.tryParse(cleaned);
    if (parsed != null && parsed.hasScheme) return cleaned;
    if (parsed != null &&
        parsed.host.isNotEmpty &&
        (parsed.scheme.isEmpty || parsed.scheme == 'null')) {
      return 'https://$cleaned';
    }
    return cleaned;
  }

  bool _isSandboxSslCommerzHost(String host) {
    return host.toLowerCase().contains('sandbox.sslcommerz.com');
  }

  Future<void> _loadPaymentUrl() async {
    final normalized = _normalizeUrl(_initialUrl);
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        uri.host.isEmpty ||
        !(uri.hasScheme && (uri.isScheme('https') || uri.isScheme('http')))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showToast(message: 'Payment URL invalid', context: context);
        Get.back();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _progress = 0;
      _showSlowLoadActions = false;
    });
    final c = _controller;
    if (c == null) return;
    await c.loadUrl(urlRequest: URLRequest(url: WebUri.uri(uri)));
  }

  Future<void> _openInBrowser() async {
    final trimmed = _normalizeUrl(_initialUrl);
    if (_isOpeningExternal) return;
    if (trimmed.isEmpty) return;
    setState(() {
      _isOpeningExternal = true;
    });
    try {
      final ok = await launchUrlString(
        trimmed,
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        final ctx = Get.context;
        if (ctx != null) {
          showToast(message: 'Could not open in browser', context: ctx);
        }
      }
    } catch (e) {
      log('Failed to open payment url externally: $e');
      final ctx = Get.context;
      if (ctx != null) {
        showToast(message: 'Could not open in browser', context: ctx);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningExternal = false;
        });
      }
    }
  }

  Map<String, dynamic> _readArgsMap() {
    final args = Get.arguments;
    if (args is Map) {
      return args.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  MyPatient? _parsePatient(dynamic raw) {
    if (raw is MyPatient) return raw;
    if (raw is Map) {
      return MyPatient.fromMap(raw.map((k, v) => MapEntry(k.toString(), v)));
    }
    return null;
  }

  Doctor? _parseDoctor(dynamic raw) {
    if (raw is Doctor) return raw;
    if (raw is Map) {
      return Doctor.fromJson(raw.map((k, v) => MapEntry(k.toString(), v)));
    }
    return null;
  }

  void _cancelLoadWatchdog() {
    _loadWatchdogTimer?.cancel();
    _loadWatchdogTimer = null;
  }

  void _cancelSlowUiTimer() {
    _slowUiTimer?.cancel();
    _slowUiTimer = null;
  }

  void _closePopupWindow() {
    if (_popupWindowId == null) return;
    setState(() {
      _popupWindowId = null;
    });
  }

  void _startSlowUiTimer() {
    _cancelSlowUiTimer();
    _slowUiTimer = Timer(const Duration(seconds: 20), () {
      if (!mounted) return;
      if (_handledTerminalResult) return;
      if (!_isLoading) return;
      setState(() {
        _showSlowLoadActions = true;
      });
    });
  }

  void _startLoadWatchdog() {
    _cancelLoadWatchdog();
    _startSlowUiTimer();

    _loadWatchdogTimer = Timer(const Duration(seconds: 30), () {
      if (!mounted) return;
      if (_handledTerminalResult) return;
      if (!_isLoading) return;
      if (_didWatchdogReload) return;

      _didWatchdogReload = true;
      log(
        'PaymentGateway: watchdog reload (t=${_loadStopwatch.elapsedMilliseconds}ms)',
      );
      final normalized = _normalizeUrl(_initialUrl);
      final uri = Uri.tryParse(normalized);
      final c = _controller;
      if (c != null && uri != null) {
        c.loadUrl(urlRequest: URLRequest(url: WebUri.uri(uri)));
      }
    });
  }

  _TerminalPaymentResult _classifyTerminalUrl(String url) {
    final lowerUrl = url.toLowerCase();
    final uri = Uri.tryParse(url);
    final qp = uri?.queryParameters ?? const <String, String>{};

    final merchantHost = Uri.parse(ApiConstants.baseUrl).host.toLowerCase();
    final currentHost = (uri?.host ?? '').toLowerCase();
    final isMerchantReturn =
        currentHost.isNotEmpty &&
        (currentHost == merchantHost || currentHost.endsWith(merchantHost));
    if (!isMerchantReturn) {
      return _TerminalPaymentResult.none;
    }

    final tranType = (qp['tran_type'] ?? '').toLowerCase();
    final paymentStatus = (qp['payment_status'] ?? '').toLowerCase();
    final status = (qp['status'] ?? '').toLowerCase();
    final payStatus = (qp['pay_status'] ?? '').toLowerCase();

    final hasTransactionRef =
        (qp['tran_id'] ?? '').trim().isNotEmpty ||
        (qp['val_id'] ?? '').trim().isNotEmpty;

    final isSuccessCandidate =
        lowerUrl.contains('payment-success') ||
        lowerUrl.contains('payment_success') ||
        (hasTransactionRef &&
            (lowerUrl.contains('tran_type=success') ||
                tranType == 'success' ||
                paymentStatus == 'success' ||
                status == 'success' ||
                status == 'paid' ||
                payStatus == 'valid'));

    final isFailedCandidate =
        lowerUrl.contains('payment-failed') ||
        lowerUrl.contains('payment_failed') ||
        (hasTransactionRef &&
            (status == 'failed' || paymentStatus == 'failed'));

    final isCancelCandidate =
        lowerUrl.contains('payment-cancel') ||
        lowerUrl.contains('payment_cancel') ||
        (hasTransactionRef &&
            (status == 'cancel' || paymentStatus == 'cancel'));

    if (isSuccessCandidate) return _TerminalPaymentResult.success;
    if (isFailedCandidate) return _TerminalPaymentResult.failed;
    if (isCancelCandidate) return _TerminalPaymentResult.cancel;
    return _TerminalPaymentResult.none;
  }

  bool _handlePaymentUrlIfTerminal(String url) {
    if (_handledTerminalResult) return true;
    final terminalResult = _classifyTerminalUrl(url);
    if (terminalResult == _TerminalPaymentResult.none) {
      return false;
    }

    if (_isProcessingTerminalResult) return true;
    _isProcessingTerminalResult = true;

    if (terminalResult == _TerminalPaymentResult.failed ||
        terminalResult == _TerminalPaymentResult.cancel) {
      _handledTerminalResult = true;
      _isProcessingTerminalResult = false;
      Get.back();
      return true;
    }

    final MyPatient? patientData = _parsePatient(_args['patientData']);
    final Doctor? selectedDoctor = _parseDoctor(_args['selectedDoctor']);

    if (patientData == null || selectedDoctor == null) {
      _handledTerminalResult = true;
      _isProcessingTerminalResult = false;
      Get.back();
      return true;
    }

    _handledTerminalResult = true;

    final ctx = Get.context;
    if (ctx != null) {
      final l10n = AppLocalizations.of(ctx)!;
      showToast(message: l10n.payment_successful, context: ctx);
    }

    // Navigate immediately; backend verification can be slow.
    final appStateController = Get.isRegistered<AppStateController>()
        ? Get.find<AppStateController>()
        : Get.put(AppStateController());
    appStateController.setPaymentVerificationInProgress(true);

    unawaited(() async {
      try {
        final reasonController = Get.isRegistered<ReasonForVisitController>()
            ? Get.find<ReasonForVisitController>()
            : null;
        if (reasonController == null) return;
        await _verifyAppointmentPaidWithRetries(
          reasonController,
          _appointmentId,
        );
        reasonController.clearState();
        if (Get.isRegistered<ReasonForVisitController>()) {
          Get.delete<ReasonForVisitController>(force: true);
        }
      } catch (_) {
        // ignore
      } finally {
        appStateController.setPaymentVerificationInProgress(false);
      }
    }());

    Get.offNamed(
      '/waiting-for-doctor',
      arguments: {
        'patientData': patientData,
        'selectedDoctor': selectedDoctor,
        'appointmentId': _appointmentId,
        'queueStatus': null,
      },
    );

    _isProcessingTerminalResult = false;
    return true;
  }

  @override
  void initState() {
    super.initState();

    _loadStopwatch
      ..reset()
      ..start();

    _args = _readArgsMap();
    _initialUrl = (_args['url'] ?? '').toString();
    _appointmentId = (_args['appointmentId'] ?? '').toString();

    log(
      'PaymentGateway: init with url=$_initialUrl (t=${_loadStopwatch.elapsedMilliseconds}ms)',
    );

    if (_initialUrl.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showToast(message: 'Payment URL missing', context: context);
        Get.back();
      });
      return;
    }
  }

  @override
  void dispose() {
    _cancelLoadWatchdog();
    _cancelSlowUiTimer();
    _loadStopwatch.stop();
    _popupWindowId = null;
    super.dispose();
  }

  Future<bool> _isAppointmentPaid(String appointmentId) async {
    if (appointmentId.isEmpty) {
      return false;
    }

    try {
      final appointmentController = Get.isRegistered<AppointmentController>()
          ? Get.find<AppointmentController>()
          : Get.put(AppointmentController());

      final upcoming =
          appointmentController.upcomingAppointments.value?.appointmentList;
      final past =
          appointmentController.pastAppointments.value?.appointmentList;
      final followup =
          appointmentController.followupAppointments.value?.appointmentList;

      final all = <dynamic>[
        ...(upcoming?.appointmentData ?? const []),
        ...(followup?.appointmentData ?? const []),
        ...(past?.appointmentData ?? const []),
      ];

      dynamic match;
      for (final a in all) {
        if ((a.id?.toString() ?? '') == appointmentId) {
          match = a;
          break;
        }
      }

      if (match == null) {
        return false;
      }

      final paymentId = (match.paymentId?.toString() ?? '').trim();
      final paymentMethod = (match.paymentMethod?.toString() ?? '').trim();
      final patientAgoraToken = (match.patientAgoraToken?.toString() ?? '')
          .trim();
      final doctorAgoraToken = (match.doctorAgoraToken?.toString() ?? '')
          .trim();
      final channelId = (match.channelId?.toString() ?? '').trim();
      final status = (match.status?.toString() ?? '').toLowerCase().trim();

      if (paymentId.isNotEmpty || paymentMethod.isNotEmpty) return true;
      if (patientAgoraToken.isNotEmpty || doctorAgoraToken.isNotEmpty) {
        return true;
      }
      if (channelId.isNotEmpty) return true;
      if (status == 'paid' || status == 'confirmed' || status == 'upcoming') {
        return true;
      }

      return false;
    } catch (e) {
      log('Payment verification error: $e');
      return false;
    }
  }

  Future<bool> _verifyAppointmentPaidWithRetries(
    ReasonForVisitController reasonController,
    String appointmentId,
  ) async {
    const attempts = 4;
    for (var i = 0; i < attempts; i++) {
      await reasonController.refreshAppointments();
      final ok = await _isAppointmentPaid(appointmentId);
      if (ok) return true;
      await Future.delayed(const Duration(milliseconds: 900));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initialUri = Uri.tryParse(_normalizeUrl(_initialUrl));
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.payment_gateway)),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                transparentBackground: false,
                supportZoom: true,
                useShouldOverrideUrlLoading: true,
                supportMultipleWindows: true,
                javaScriptCanOpenWindowsAutomatically: true,
                domStorageEnabled: true,
                sharedCookiesEnabled: true,
                thirdPartyCookiesEnabled: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                mediaPlaybackRequiresUserGesture: false,
                userAgent: isAndroid
                    ? 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36'
                    : null,
              ),
              initialUrlRequest: initialUri == null
                  ? null
                  : URLRequest(url: WebUri.uri(initialUri)),
              onWebViewCreated: (controller) {
                _controller = controller;
                if (mounted) {
                  _loadPaymentUrl();
                }
              },
              shouldOverrideUrlLoading: (controller, action) async {
                final url = action.request.url?.toString() ?? '';
                return _decideNavigation(url);
              },
              onCreateWindow: (controller, createWindowAction) async {
                // Some payment gateways open OTP/3DS in a new window. Load it
                // in the same webview to keep the user inside the app.
                final request = createWindowAction.request;
                final newUrl = request.url?.toString() ?? '';
                final windowId = createWindowAction.windowId;
                if (windowId != null) {
                  if (!mounted) return true;
                  setState(() {
                    _popupWindowId = windowId;
                  });
                  return true;
                }
                if (newUrl.isNotEmpty) {
                  try {
                    // Preserve method/headers/body (OTP pages often POST).
                    await controller.loadUrl(urlRequest: request);
                  } catch (_) {
                    // ignore
                  }
                }
                return true;
              },
              onLoadStart: (controller, url) {
                final u = url?.toString() ?? '';
                log(
                  'Payment page started: $u (t=${_loadStopwatch.elapsedMilliseconds}ms)',
                );
                if (u.isNotEmpty && _handlePaymentUrlIfTerminal(u)) {
                  return;
                }
                if (!mounted) return;
                setState(() {
                  _isLoading = true;
                  _progress = 0;
                  _showSlowLoadActions = false;
                });
                _startLoadWatchdog();
              },
              onLoadStop: (controller, url) async {
                final u = url?.toString() ?? '';
                log(
                  'Payment page finished: $u (t=${_loadStopwatch.elapsedMilliseconds}ms)',
                );
                _cancelLoadWatchdog();
                _cancelSlowUiTimer();

                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _progress = 100;
                    _showSlowLoadActions = false;
                  });
                }

                if (u.isNotEmpty) _handlePaymentUrlIfTerminal(u);
              },
              onProgressChanged: (controller, progress) {
                if (!mounted) return;
                setState(() {
                  _progress = progress;
                  if (!_handledTerminalResult) {
                    _isLoading = progress < 85;
                  }
                });
                if (progress == 0 ||
                    progress == 10 ||
                    progress == 25 ||
                    progress == 50 ||
                    progress == 75 ||
                    progress == 100) {
                  log(
                    'Payment page progress: $progress% (t=${_loadStopwatch.elapsedMilliseconds}ms)',
                  );
                }
              },
              onReceivedError: (controller, request, error) {
                if (!(request.isForMainFrame ?? true)) return;
                if (_isCancelledWebError(error)) return;
                log('Web resource error: ${error.description}');
                _cancelLoadWatchdog();
                _cancelSlowUiTimer();

                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _showSlowLoadActions = true;
                  });
                }

                final ctx = Get.context;
                if (ctx != null) {
                  showToast(
                    message: 'Failed to load payment page. Please try again.',
                    context: ctx,
                  );
                }
              },
              onReceivedHttpError: (controller, request, response) {
                if (!(request.isForMainFrame ?? true)) return;
                log(
                  'HTTP error ${response.statusCode} for ${request.url?.toString() ?? ''}',
                );
                _cancelLoadWatchdog();
                _cancelSlowUiTimer();

                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _showSlowLoadActions = true;
                  });
                }

                final ctx = Get.context;
                if (ctx != null) {
                  showToast(
                    message: 'Failed to load payment page. Please try again.',
                    context: ctx,
                  );
                }
              },
              onReceivedServerTrustAuthRequest: kDebugMode
                  ? (controller, challenge) async {
                      final host = challenge.protectionSpace.host;
                      if (!_isSandboxSslCommerzHost(host)) {
                        log(
                          'PaymentGateway: allowing SSL host in debug: $host',
                        );
                      }
                      return ServerTrustAuthResponse(
                        action: ServerTrustAuthResponseAction.PROCEED,
                      );
                    }
                  : null,
            ),
            if (_isLoading)
              IgnorePointer(
                ignoring: true,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(width: 10),
                            const _PaymentLoadingLabel(),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (_progress.clamp(0, 100)) / 100.0,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$_progress%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_showSlowLoadActions)
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _loadPaymentUrl();
                          _startLoadWatchdog();
                        },
                        child: const Text('Retry loading'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _isOpeningExternal ? null : _openInBrowser,
                        child: _isOpeningExternal
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Open in browser'),
                      ),
                    ],
                  ),
                ),
              ),
            if (_popupWindowId != null)
              _PaymentPopupWebView(
                windowId: _popupWindowId!,
                onClose: _closePopupWindow,
                onDecideNavigation: _decideNavigation,
                onHandleTerminalUrl: _handlePaymentUrlIfTerminal,
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentLoadingLabel extends StatelessWidget {
  const _PaymentLoadingLabel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(
      l10n.loading,
      style: const TextStyle(fontSize: 16, color: Colors.black54),
    );
  }
}

class _PaymentPopupWebView extends StatelessWidget {
  const _PaymentPopupWebView({
    required this.windowId,
    required this.onClose,
    required this.onDecideNavigation,
    required this.onHandleTerminalUrl,
  });

  final int windowId;
  final VoidCallback onClose;
  final Future<NavigationActionPolicy> Function(String) onDecideNavigation;
  final bool Function(String) onHandleTerminalUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.payment_gateway,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InAppWebView(
                  windowId: windowId,
                  onCloseWindow: (controller) => onClose(),
                  shouldOverrideUrlLoading: (controller, action) async {
                    final url = action.request.url?.toString() ?? '';
                    return onDecideNavigation(url);
                  },
                  onLoadStart: (controller, url) {
                    final u = url?.toString() ?? '';
                    if (u.isNotEmpty) onHandleTerminalUrl(u);
                  },
                  onLoadStop: (controller, url) {
                    final u = url?.toString() ?? '';
                    if (u.isNotEmpty) onHandleTerminalUrl(u);
                  },
                  onReceivedError: (controller, request, error) {
                    if (!(request.isForMainFrame ?? true)) return;
                    final ctx = Get.context;
                    if (ctx != null) {
                      showToast(
                        message:
                            'Failed to load payment page. Please try again.',
                        context: ctx,
                      );
                    }
                  },
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                    supportMultipleWindows: true,
                    sharedCookiesEnabled: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

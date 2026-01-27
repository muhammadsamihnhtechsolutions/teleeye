import 'dart:async';

import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../l10n/app_localizations.dart';

class LiveSupportScreen extends StatefulWidget {
  const LiveSupportScreen({super.key});

  @override
  State<LiveSupportScreen> createState() => _LiveSupportScreenState();
}

class _LiveSupportScreenState extends State<LiveSupportScreen> {
  late final TextEditingController _messageController;
  late final MoreController controller;
  Timer? _pollTimer;
  String _lastSupportId = '';

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    // Ensure MoreController is available even when LiveSupportScreen
    // is opened from outside the MoreScreen tab.
    controller = Get.isRegistered<MoreController>()
        ? Get.find<MoreController>()
        : Get.put(MoreController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initSupport().whenComplete(_startPolling);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      if (controller.isLoadingSupportMessages.value ||
          controller.isSendingSupportMessage.value) {
        return;
      }
      final supportId = controller.activeSupportId.value.trim();
      if (supportId.isEmpty) return;
      if (supportId != _lastSupportId) {
        _lastSupportId = supportId;
      }
      await controller.fetchSupportMessages(supportId);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: InterText(
          title: l10n.support,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          textColor: AppColors.black,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _SupportHeader(l10n: l10n),
            Expanded(
              child: Obx(
                () {
                  final isLoading = controller.isLoadingSupportMessages.value;
                  final messages = controller.supportMessages;
                  if (isLoading && messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (messages.isEmpty) {
                    return Center(
                      child: _EmptyState(l10n: l10n),
                    );
                  }
                  final reversed = messages.reversed.toList();
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(16),
                      vertical: getProportionateScreenWidth(14),
                    ),
                    reverse: true,
                    itemCount: reversed.length,
                    itemBuilder: (context, index) {
                      final message = reversed[index];
                      return _MessageBubble(
                        message: message.message,
                        time: _formatTime(message.sentAt),
                        fromUser: message.fromUser,
                      );
                    },
                  );
                },
              ),
            ),
            Obx(
              () => _MessageComposer(
                controller: _messageController,
                onSend: _handleSendMessage,
                isSending: controller.isSendingSupportMessage.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _handleSendMessage() {
    final l10n = AppLocalizations.of(context)!;
    if (_messageController.text.trim().isEmpty) {
      showToast(message: l10n.type_a_message_to_continue, context: context);
      return;
    }
    controller.sendSupportMessage(_messageController.text.trim());
    _messageController.clear();
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(16),
        vertical: getProportionateScreenWidth(10),
      ),
      padding: EdgeInsets.only(
        left: getProportionateScreenWidth(12),
        right: getProportionateScreenWidth(8),
        bottom: getProportionateScreenWidth(8),
        top: getProportionateScreenWidth(6),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.colorEDEDED),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.type_your_message,
                border: InputBorder.none,
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isSending
                  ? AppColors.colorEDEDED
                  : AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, size: 18, color: Colors.white),
              onPressed: isSending ? null : onSend,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportHeader extends StatelessWidget {
  const _SupportHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        getProportionateScreenWidth(16),
        getProportionateScreenWidth(12),
        getProportionateScreenWidth(16),
        getProportionateScreenWidth(4),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(14),
        vertical: getProportionateScreenWidth(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.colorE6F2EE,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.headset_mic, color: Colors.white),
          ),
          CommonSizeBox(width: getProportionateScreenWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InterText(
                  title: l10n.general_support,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.color001B0D,
                ),
                const SizedBox(height: 4),
                InterText(
                  title: l10n.type_your_message,
                  fontSize: 12,
                  textColor: AppColors.color777777,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  height: 6,
                  width: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 10, color: AppColors.color777777),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(32),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.colorCCE7D9,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 36),
          ),
          const SizedBox(height: 16),
          InterText(
            title: l10n.support,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            textColor: AppColors.black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          InterText(
            title: l10n.type_your_message,
            fontSize: 12,
            textColor: AppColors.color888E9D,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.time,
    required this.fromUser,
  });

  final String message;
  final String time;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    final bubbleColor =
        fromUser ? AppColors.primaryColor : AppColors.colorCCE7D9;
    final textColor = fromUser ? Colors.white : AppColors.black;
    final timeColor =
        fromUser ? AppColors.colorEDEDED : AppColors.color888E9D;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(fromUser ? 16 : 4),
      bottomRight: Radius.circular(fromUser ? 4 : 16),
    );

    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: EdgeInsets.only(
            bottom: getProportionateScreenHeight(8),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(12),
            vertical: getProportionateScreenHeight(10),
          ),
          decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InterText(
                title: message,
                fontSize: 14,
                textColor: textColor,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(6)),
              InterText(
                title: time,
                fontSize: 10,
                textColor: timeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

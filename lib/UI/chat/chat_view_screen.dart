import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/constant/app_color.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/provider/chat/chat_view_provider.dart';
import 'package:talknep/util/file_checker.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_loader.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';
import 'package:talknep/widget/app_textfield.dart';

class ChatViewScreen extends StatefulWidget {
  final String slug;
  final int receiverId;
  final String receiverName;
  final String? receiverAvatarUrl;

  const ChatViewScreen({
    super.key,
    required this.slug,
    this.receiverAvatarUrl,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: -10,
            leading: InkWell(
              onTap: () => Get.back(),
              child: const Icon(Icons.arrow_back_ios, size: 18),
            ),
            title: Row(
              spacing: Sizer.w(2),
              children: [
                AdvancedAvatar(
                  animated: true,
                  image:
                      (widget.receiverAvatarUrl != null &&
                              widget.receiverAvatarUrl!.startsWith('http'))
                          ? NetworkImage(widget.receiverAvatarUrl!)
                          : AssetImage(Assets.image.png.profile.path)
                              as ImageProvider,
                ),
                AppText(text: widget.receiverName, fontWeight: FontWeight.w600),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.phone_fill),
                onPressed: () {
                  provider.startCall(
                    context: context,
                    isVideo: false,
                    id: widget.receiverId,
                  );
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.videocam_circle),
                onPressed: () {
                  provider.startCall(
                    context: context,
                    isVideo: true,
                    id: widget.receiverId,
                  );
                },
              ),
            ],
          ),
          backgroundColor: context.scaffoldBackgroundColor,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: Sizer.w(4)),
            child: Column(
              children: [
                Expanded(
                  child:
                      provider.isLoadingMessages
                          ? const Center(child: CommonLoader())
                          : provider.messagesData.isEmpty
                          ? Center(child: AppText(text: "No messages yet."))
                          : ListView.builder(
                            reverse: true,
                            cacheExtent: 999999999999999,
                            controller: provider.scrollController,
                            itemCount: provider.messagesData.length,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemBuilder: (context, index) {
                              final msg = provider.messagesData[index];

                              final msgId = msg['id'] as int?;

                              final msgType = msg['message_type'];

                              final createdAt = msg['created_at'] ?? '';

                              final isMine =
                                  msg['sender_id'] != widget.receiverId;

                              final msgText = msg['message'] ?? '';

                              final time =
                                  createdAt.isNotEmpty
                                      ? formatTime(createdAt)
                                      : '';

                              return msgId != null && isMine
                                  ? Slidable(
                                    key: Key(msgId.toString()),
                                    endActionPane: ActionPane(
                                      extentRatio: 0.15,
                                      motion: const DrawerMotion(),
                                      children: [
                                        CustomSlidableAction(
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                          onPressed:
                                              (_) => provider.deleteMessage(
                                                context,
                                                msgId,
                                              ),
                                          child: Container(
                                            height: 40,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                              left: 2,
                                              bottom: 20,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.redColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.delete),
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: buildMessageBubble(
                                      msgText,
                                      isMine,
                                      time,
                                      msgType: msgType,
                                    ),
                                  )
                                  : buildMessageBubble(
                                    msgText,
                                    isMine,
                                    time,
                                    msgType: msgType,
                                  );
                            },
                          ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Sizer.h(2)),
                  child: CommonTextField2(
                    text: 'Write a message...',
                    controller: messageController,
                    /* prefixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.attach_file_rounded),
                    ), */
                    suffixIcon: IconButton(
                      onPressed: () {
                        provider.sendMessage(
                          context,
                          onSuccess: () {},
                          slug: widget.slug,
                          receiverId: widget.receiverId,
                          message: messageController.text,
                        );
                        messageController.clear();
                        provider.scrollToBottom();
                      },
                      icon: const Icon(CupertinoIcons.arrow_right_circle_fill),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMessageBubble(
    String msgText,
    bool isMine,
    String time, {
    String? msgType,
  }) {
    final bool isFile = msgType == 'file';
    Widget content;

    if (isFile) {
      if (isImageFile(msgText)) {
        content = ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: NetImage(
            height: 200,
            width: 200,
            imageUrl:
                msgText.startsWith("http")
                    ? msgText
                    : "https://talknep.com/storage/$msgText",
          ),
        );
      } else if (isVideoFile(msgText)) {
        content = Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(size: 50, Icons.play_circle_fill),
        );
      } else {
        content = const AppText(text: "[File]");
      }
    } else {
      content = AppText(
        text: msgText,
        fontWeight: FontWeight.w400,
        color: isMine ? AppColors.whiteColor : context.colorsScheme.onPrimary,
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: Sizer.h(0.5),
              bottom: Sizer.h(0.5),
              left: isMine ? Sizer.w(15) : 0,
              right: isMine ? 0 : Sizer.w(15),
            ),
            padding:
                isFile
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  isMine
                      ? AppColors.primaryColor.withValues(alpha: 0.8)
                      : context.colorsScheme.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
            ),
            child: content,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 8),
            child: AppText(
              text: time,
              fontSize: Sizer.sp(2.5),
              color: context.colorsScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(String dateTime) {
    try {
      final now = DateTime.now();
      final dt = DateTime.parse(dateTime).toLocal();
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final isToday =
          dt.year == now.year && dt.month == now.month && dt.day == now.day;

      if (isToday) {
        return "$hour:$minute $amPm";
      } else {
        return "${dt.day}/${dt.month}/${dt.year}  $hour:$minute $amPm";
      }
    } catch (e) {
      return '';
    }
  }
}

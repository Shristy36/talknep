import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

class ChatWidget extends StatelessWidget {
  final int userId;
  final String name;
  final String slug;
  final String avatar;
  final int unreadCount;
  final String createdAt;
  final String messageText;
  final VoidCallback? onTap;

  const ChatWidget({
    super.key,
    this.onTap,
    required this.name,
    required this.slug,
    this.unreadCount = 0,
    required this.userId,
    required this.avatar,
    required this.createdAt,
    required this.messageText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: Sizer.h(1)),
        padding: EdgeInsets.symmetric(
          horizontal: Sizer.w(3),
          vertical: Sizer.h(1.5),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorsScheme.onSecondary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar
            AdvancedAvatar(
              size: Sizer.w(12),
              animated: true,
              image: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child:
                  avatar.isEmpty
                      ? Icon(
                        Icons.person,
                        size: Sizer.w(6),
                        color:
                            context.colorsScheme.onSurface
                              ..withValues(alpha: 0.6),
                      )
                      : null,
            ),
            SizedBox(width: Sizer.w(3)),
            // Chat details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          text: name,
                          fontSize: 16,
                          fontWeight:
                              unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                          color: context.colorsScheme.onSurface,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (createdAt.isNotEmpty) ...[
                            AppText(
                              text: createdAt,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color:
                                  unreadCount > 0
                                      ? context.colorsScheme.primary
                                      : context.colorsScheme.onSurface
                                          .withValues(alpha: 0.6),
                            ),
                            SizedBox(width: Sizer.w(2)),
                          ],
                          // Unread count badge
                          if (unreadCount > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    unreadCount > 99
                                        ? Sizer.w(2)
                                        : Sizer.w(1.5),
                                vertical: Sizer.h(0.3),
                              ),
                              decoration: BoxDecoration(
                                color: context.colorsScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(minWidth: Sizer.w(5)),
                              child: Center(
                                child: AppText(
                                  text:
                                      unreadCount > 99
                                          ? '99+'
                                          : unreadCount.toString(),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Sizer.h(0.5)),
                  AppText(
                    text: messageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    fontWeight:
                        unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                    color:
                        unreadCount > 0
                            ? context.colorsScheme.onSurface
                            : context.colorsScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

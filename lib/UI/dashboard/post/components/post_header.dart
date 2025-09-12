import 'package:flutter/material.dart';
import 'package:talknep/components/net_image.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';
import 'package:talknep/widget/app_text.dart';

enum Audience { public, friends, onlyMe }

class PostHeader extends StatelessWidget {
  const PostHeader({
    super.key,
    this.location,
    this.onTapMenu,
    this.trailing,
    this.onTapProfile,
    this.avatarSize = 44,
    this.isVerified = false,
    required this.timestamp,
    required this.avatarUrl,
    required this.displayName,
    this.withUsers = const [],
    this.audience = Audience.public,
  });

  final bool isVerified;
  final String? location;
  final String timestamp;
  final String avatarUrl;
  final String? trailing;
  final double avatarSize;
  final Audience audience;
  final String displayName;
  final List<String> withUsers;
  final VoidCallback? onTapMenu;
  final VoidCallback? onTapProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final subStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
      height: 1.2,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTapProfile,
          borderRadius: BorderRadius.circular(avatarSize),
          child:
              avatarUrl.isNotEmpty
                  ? Container(
                    width: avatarSize,
                    height: avatarSize,
                    child: ClipRRect(
                      child: NetImage(imageUrl: avatarUrl),
                      borderRadius: BorderRadius.circular(avatarSize),
                    ),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                  )
                  : Icon(Icons.person, size: avatarSize * 0.55),
        ),
        SizedBox(width: Sizer.w(4)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row with verified tick
              Row(
                spacing: 6,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: AppText(
                      text: displayName,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isVerified) ...[
                    Icon(
                      size: 16,
                      Icons.verified,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
              SizedBox(height: Sizer.h(0.5)),
              // Meta line (time • audience • with • at)
              MetaLine(
                audience: audience,
                subStyle: subStyle,
                location: location,
                withUsers: withUsers,
                timestamp: timestamp,
              ),
            ],
          ),
        ),

        InkWell(
          onTap: onTapMenu,
          child: AppText(
            text: trailing ?? "",
            fontWeight: FontWeight.w600,
            color: context.colorsScheme.primary,
          ),
        ),
      ],
    );
  }
}

class MetaLine extends StatelessWidget {
  const MetaLine({
    required this.subStyle,
    required this.timestamp,
    required this.audience,
    required this.location,
    required this.withUsers,
  });

  final String? location;
  final String timestamp;
  final Audience audience;
  final TextStyle? subStyle;
  final List<String> withUsers;

  @override
  Widget build(BuildContext context) {
    final parts = <InlineSpan>[];
    // time-ago
    parts.add(TextSpan(text: timestamp));
    // dot •
    parts.add(const TextSpan(text: " • "));
    // privacy icon
    parts.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: _audienceIcon(context, audience),
        ),
      ),
    );

    // with users
    if (withUsers.isNotEmpty) {
      parts.add(const TextSpan(text: " • "));
      parts.add(
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.person, size: 14),
          ),
        ),
      );
      parts.add(TextSpan(text: "with ${_joinNames(withUsers)}"));
    }
    // location
    if ((location ?? "").isNotEmpty) {
      parts.add(const TextSpan(text: " • "));
      parts.add(
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.location_on, size: 14),
          ),
        ),
      );
      parts.add(TextSpan(text: location));
    }
    return Text.rich(
      maxLines: 2,
      style: subStyle,
      TextSpan(children: parts),
      overflow: TextOverflow.ellipsis,
    );
  }

  static String _joinNames(List<String> names) {
    if (names.length == 1) return names.first;
    if (names.length == 2) return "${names[0]} and ${names[1]}";
    return "${names[0]}, ${names[1]} and ${names.length - 2} others";
  }

  static Widget _audienceIcon(BuildContext context, Audience a) {
    final color = Theme.of(context).textTheme.bodySmall?.color;
    switch (a) {
      case Audience.public:
        return Icon(Icons.public, size: 14, color: color);
      case Audience.friends:
        return Icon(Icons.group, size: 14, color: color);
      case Audience.onlyMe:
        return Icon(Icons.lock, size: 14, color: color);
    }
  }
}

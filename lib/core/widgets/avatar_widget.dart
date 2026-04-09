import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Reusable circular avatar — shows network image, local asset fallback, or initials.
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 28,
    this.onTap,
    this.showEditBadge = false,
  });

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (_, img) => CircleAvatar(
          radius: radius,
          backgroundImage: img,
        ),
        placeholder: (_, __) => _InitialsAvatar(
          initials: _initials,
          radius: radius,
          color: cs.primary,
        ),
        errorWidget: (_, __, ___) => _InitialsAvatar(
          initials: _initials,
          radius: radius,
          color: cs.primary,
        ),
      );
    } else {
      avatar = _InitialsAvatar(
        initials: _initials,
        radius: radius,
        color: cs.primary,
      );
    }

    if (showEditBadge && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            avatar,
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final double radius;
  final Color color;

  const _InitialsAvatar({
    required this.initials,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.15),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}

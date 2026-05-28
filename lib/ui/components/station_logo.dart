import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class StationLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;
  final double borderRadius;

  const StationLogo({
    super.key,
    required this.logoUrl,
    this.size = 56,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: logoUrl != null
            ? CachedNetworkImage(
                imageUrl: logoUrl!,
                fit: BoxFit.contain,
                placeholder: (_, _) => _placeholder(),
                errorWidget: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceElevated,
        child: Icon(Icons.radio, color: AppColors.brandTeal, size: size * 0.5),
      );
}

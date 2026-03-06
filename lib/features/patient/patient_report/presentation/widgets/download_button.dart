import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:smart_glove/core/localization/app_localizations.dart';

class DownloadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DownloadButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          context.tr('Download Report'),
          style: textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

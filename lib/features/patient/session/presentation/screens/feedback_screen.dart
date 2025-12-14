import 'package:flutter/material.dart';
import 'package:smart_glove/core/utils/size_config.dart';
import 'package:smart_glove/core/widgets/primary_button.dart';

class FeedbackScreen extends StatefulWidget {
  final String sessionTitle;
  const FeedbackScreen({super.key, required this.sessionTitle});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int painRating = 0;
  int easeRating = 0;

  Widget _starsRow({required int value, required ValueChanged<int> onSelect}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final index = i + 1;
        return IconButton(
          onPressed: () => onSelect(index),
          icon: Icon(index <= value ? Icons.star : Icons.star_border),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Feedback")),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 5,
          vertical: SizeConfig.blockHeight * 2,
        ),
        child: Column(
          children: [
            Text(
              "Session Completed",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1),
            Text(
              widget.sessionTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 3),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      theme.brightness == Brightness.dark ? 0.12 : 0.06,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "How would you rate your pain?",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _starsRow(
                    value: painRating,
                    onSelect: (v) => setState(() => painRating = v),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 2),
                  Text(
                    "How easy was the session?",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _starsRow(
                    value: easeRating,
                    onSelect: (v) => setState(() => easeRating = v),
                  ),
                ],
              ),
            ),

            const Spacer(),

            PrimaryButton(
              text: "Submit",
              onPressed: () {
                // TODO: save feedback to Firebase later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Feedback submitted")),
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}

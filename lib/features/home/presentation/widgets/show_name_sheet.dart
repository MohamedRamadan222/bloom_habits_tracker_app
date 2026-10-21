import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/widgets/close_button_sheet.dart';

Future<void> showNameSheet(
  BuildContext context, {
  String initialName = '',
  required ValueChanged<String> onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim.withValues(alpha: 0.35),
    builder: (_) => ShowNameSheet(initialName: initialName, onSave: onSave),
  );
}

class ShowNameSheet extends StatefulWidget {
  const ShowNameSheet({super.key, this.initialName = '', required this.onSave});

  final String initialName;
  final ValueChanged<String> onSave;

  @override
  State<ShowNameSheet> createState() => _ShowNameSheetState();
}

class _ShowNameSheetState extends State<ShowNameSheet> {
  late final _controller = TextEditingController(text: widget.initialName);

  String get _value => _controller.text.trim();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_value.isEmpty) return;
    widget.onSave(_value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(32, 12, 32, 32 + safeBottom),
        // Scrolls instead of overflowing when the keyboard is open
        // on short screens (same pattern as the habit sheet).
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // handel
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Make yourself at home',
                        style: TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your little space',
                        style: TextStyle(
                          fontSize: context.isCompact ? 26 : 30,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                CloseButtonSheet(onTap: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 32),
            // label
            const Text(
              'What should we call you?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            // input
            TextField(
              controller: _controller,
              maxLength: 40,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.givenName],
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
              style: const TextStyle(fontSize: 18, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Alex',
                hintStyle: const TextStyle(color: AppColors.hint),
                counterText: '',
                filled: true,
                fillColor: AppColors.field,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Description
            const Text(
              'Your habits and progress stay on this device. No account needed.',
              style: TextStyle(
                fontSize: 15,
                height: 1.8,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 32),
            // Button
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _value.isEmpty ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: AppColors.primaryColor.withValues(
                    alpha: 0.5,
                  ),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Save my name'),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}



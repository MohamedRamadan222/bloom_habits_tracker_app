import 'package:bloom_habit_tracker/core/widgets/close_button_sheet.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/data/habit_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/responsive.dart';

Future<void> showHabitSheet(
  BuildContext context, {
  HabitItem? initial,
  required ValueChanged<HabitItem> onSave,
  VoidCallback? onDelete,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim.withValues(alpha: 0.35),
    builder: (_) =>
        ShowHabitSheet(initial: initial, onSave: onSave, onDelete: onDelete),
  );
}

class ShowHabitSheet extends StatefulWidget {
  const ShowHabitSheet({
    super.key,
    this.initial,
    required this.onSave,
    this.onDelete,
  });

  final HabitItem? initial;
  final ValueChanged<HabitItem> onSave;
  final VoidCallback? onDelete;

  @override
  State<ShowHabitSheet> createState() => _ShowHabitSheetState();
}

class _ShowHabitSheetState extends State<ShowHabitSheet> {
  final _name = TextEditingController();
  final _goal = TextEditingController(text: '10');
  final _unit = TextEditingController(text: 'unit');

  int _icon = 2;
  int _period = 1;
  int _color = 1;

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      (int.tryParse(_goal.text.trim()) ?? 0) > 0 &&
      _unit.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _name.text = widget.initial!.name;
      _goal.text = widget.initial!.goal.toString();
      _unit.text = widget.initial!.unit;
      _icon = widget.initial!.iconIndex;
      _period = widget.initial!.period;

      final colorIndex = colors.indexWhere(
        (c) => c.toARGB32() == widget.initial!.colorValue,
      );
      if (colorIndex != -1) {
        _color = colorIndex;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _goal.dispose();
    _unit.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_valid) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    widget.onSave(
      HabitItem(
        id: widget.initial?.id ?? const Uuid().v4(),
        name: _name.text.trim(),
        iconIndex: _icon,
        goal: int.parse(_goal.text.trim()),
        unit: _unit.text.trim(),
        period: _period,
        colorValue: colors[_color].toARGB32(),
        createdAt: widget.initial?.createdAt ?? now,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final isEditing = widget.initial != null;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(32, 12, 32, 32 + safeBottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // handle
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
                        Text(
                          isEditing ? 'Make it better' : 'A small beginning',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing ? 'Edit habit' : 'Plant a new habit',
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
              // name
              const _Label('What would you like to do?'),
              const SizedBox(height: 12),
              _Field(
                controller: _name,
                hint: 'Read a little every day',
                maxLength: 60,
                capitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              // icon
              const _Label('Give it a little personality'),
              const SizedBox(height: 12),
              // Box size shrinks on narrow screens instead of overflowing
              // (6 x 44px no longer fits below ~330dp).
              LayoutBuilder(
                builder: (context, constraints) {
                  final box = (constraints.maxWidth - 5 * 12) / 6;
                  final size = box >= 44 ? 44.0 : box.clamp(28.0, 44.0);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < habitIcons.length; i++)
                        _Choice(
                          selected: i == _icon,
                          onTap: () => setState(() => _icon = i),
                          child: SizedBox(
                            width: size,
                            height: size,
                            child: Icon(
                              safeHabitIcon(i),
                              size: 20,
                              color: i == _icon
                                  ? AppColors.primaryColor
                                  : AppColors.muted,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // goal + unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Daily goal'),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _goal,
                          hint: '10',
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Unit'),
                        const SizedBox(height: 12),
                        _Field(
                          controller: _unit,
                          hint: 'pages',
                          maxLength: 16,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _submit(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // period
              const _Label('Make room for it'),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < periods.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _Choice(
                        selected: i == _period,
                        onTap: () => setState(() => _period = i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Column(
                            children: [
                              Icon(
                                safePeriod(i).icon,
                                size: 20,
                                color: i == _period
                                    ? AppColors.primaryColor
                                    : AppColors.muted,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                safePeriod(i).label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: i == _period
                                      ? AppColors.primaryColor
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              // color
              const _Label('A color that feels like you'),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var i = 0; i < colors.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => setState(() => _color = i),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: i == _color
                                ? AppColors.primaryColor
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: i == _color
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.primaryColor,
                              )
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              // description
              const Row(
                children: [
                  Icon(Icons.repeat_rounded, size: 16, color: AppColors.muted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Every day is a fresh chance. Start small.',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // button
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _valid ? _submit : null,
                  icon: Icon(
                    isEditing ? Icons.save_rounded : Icons.add_rounded,
                    size: 20,
                  ),
                  label: Text(isEditing ? 'Save changes' : 'Add to my day'),
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
                ),
              ),
              if (isEditing && widget.onDelete != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        title: const Text('Delete Habit?'),
                        content: const Text(
                          'Are you sure you want to delete this habit? All associated logs will also be permanently removed.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),

                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              widget.onDelete!();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Delete habit'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization? capitalization;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  const _Field({
    required this.controller,
    required this.hint,
    required this.maxLength,
    this.keyboardType,
    this.capitalization,
    required this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textCapitalization: capitalization ?? TextCapitalization.none,
      textInputAction: onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 16, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }
}

class _Choice extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _Choice({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: selected ? AppColors.primaryColor : AppColors.border,
        width: selected ? 1.5 : 1,
      ),
    );

    return Material(
      color: selected
          ? AppColors.primaryColor.withValues(alpha: 0.08)
          : Colors.white,
      shape: shape,
      child: InkWell(customBorder: shape, onTap: onTap, child: child),
    );
  }
}

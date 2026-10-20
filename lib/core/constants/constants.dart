import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const habitIcons = [
  LucideIcons.personStandingDir,
  Icons.water_drop_outlined,
  Icons.menu_book_outlined,
  Icons.spa_outlined,
  Icons.directions_run_rounded,
  Icons.edit_note_rounded,
];

const periods = [
  (label: 'Morning', icon: Icons.wb_twilight_rounded),
  (label: 'Afternoon', icon: Icons.wb_sunny_outlined),
  (label: 'Evening', icon: Icons.dark_mode_outlined),
];

const colors = [
  Color(0xFFE9E5F7),
  Color(0xFFFBE7D3),
  Color(0xFFE3F1E5),
  Color(0xFFE0ECF8),
  Color(0xFFFBE3E8),
];
IconData safeHabitIcon(int index) {
  if (index < 0 || index >= habitIcons.length) {
    return habitIcons[0];
  }
  return habitIcons[index];
}

dynamic safePeriod(int index) {
  if (index < 0 || index >= periods.length) {

    return periods[0];
  }
  return periods[index];
}
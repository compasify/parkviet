import 'package:flutter/foundation.dart';
import 'package:pos_api/pos_api.dart';

import '../../l10n/app_localizations.dart';

/// The courses a waiter picks from: starter, main, dessert.
const tableCourses = [1, 2, 3];

/// The name of a course, the branch's own when the board gives one.
String courseLabel(AppLocalizations l10n, int course) => switch (course) {
  1 => l10n.courseStarter,
  2 => l10n.courseMain,
  3 => l10n.courseDessert,
  _ => l10n.courseNumber(course),
};

/// Where the next dishes of a table go: their course, held until it is
/// fired, and the seat that ordered them.
@immutable
class TablePlacement {
  const TablePlacement({this.course, this.seat, this.hold = false});

  final int? course;
  final int? seat;

  /// Only a dish with a course waits for its fire.
  final bool hold;

  bool get holds => course != null && hold;

  TablePlacement copyWith({int? Function()? course, int? Function()? seat, bool? hold}) {
    final nextCourse = course == null ? this.course : course();
    return TablePlacement(
      course: nextCourse,
      seat: seat == null ? this.seat : seat(),
      hold: nextCourse == null ? false : (hold ?? this.hold),
    );
  }

  /// Fills the course, seat and hold of an append item.
  void apply(AppendItemBuilder builder) {
    if (course != null) builder.course = course;
    if (seat != null) builder.seat = seat;
    if (holds) builder.hold = true;
  }

  @override
  bool operator ==(Object other) =>
      other is TablePlacement && other.course == course && other.seat == seat && other.hold == hold;

  @override
  int get hashCode => Object.hash(course, seat, hold);
}

/// The courses of an order still held back from the kitchen, first first,
/// with how many units each holds.
List<({int course, int count})> heldCourses(Workspace workspace) {
  final held = <int, int>{};
  for (final line in workspace.lineItems ?? const <WorkspaceLine>[]) {
    final course = line.course;
    if (course == null || line.courseStatus != WorkspaceLineCourseStatusEnum.held) continue;
    held[course] = (held[course] ?? 0) + line.quantity;
  }
  final courses = held.keys.toList()..sort();
  return [for (final course in courses) (course: course, count: held[course]!)];
}

/// "Ghế 2 · Món chính · chờ gọi" for a line, empty when it has none.
String placementLabel(AppLocalizations l10n, WorkspaceLine line) => [
  if (line.seat != null) l10n.seatNumber(line.seat!),
  if (line.course != null) courseLabel(l10n, line.course!),
  if (line.courseStatus == WorkspaceLineCourseStatusEnum.held) l10n.courseHold,
].join(' · ');

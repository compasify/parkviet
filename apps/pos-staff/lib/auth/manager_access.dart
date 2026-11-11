import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manager_access.g.dart';

/// Whether a manager PIN opened device management. Closed again when the
/// management screen is left.
@Riverpod(keepAlive: true)
class ManagerAccess extends _$ManagerAccess {
  @override
  bool build() => false;

  void grant() => state = true;

  void close() => state = false;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/manage_screen.dart';
import 'auth/manager_access.dart';
import 'auth/pin_screen.dart';
import 'auth/staff_picker_screen.dart';
import 'auth/staff_session.dart';
import 'core/app_mode.dart';
import 'core/session.dart';
import 'modes/expo/expo_screen.dart' deferred as expo;
import 'modes/kds/kds_screen.dart' deferred as kds;
import 'modes/kiosk/kiosk_screen.dart' deferred as kiosk;
import 'modes/owner/owner_screen.dart' deferred as owner;
import 'modes/print_station/print_station_screen.dart' deferred as print_station;
import 'modes/waiter/waiter_screen.dart' deferred as waiter;
import 'pairing/device_checklist.dart';
import 'pairing/manual_pair_screen.dart';
import 'pairing/offline_screen.dart';
import 'pairing/scan_screen.dart';
import 'pairing/welcome_screen.dart';

/// Where a device should be, given its pairing, mode and signed-in person.
/// Null keeps the current location.
String? redirectFor({
  required AsyncValue<AppSession> session,
  required StaffSession? staff,
  required bool managerAccess,
  required String location,
  bool checklist = false,
}) {
  final current = session.value;
  if (current == null) return location == '/' ? null : '/';

  switch (current) {
    case Unpaired():
      return location == '/welcome' || location.startsWith('/pair/') ? null : '/welcome';
    case Offline():
      return location == '/offline' ? null : '/offline';
    case Paired(:final me):
      final mode = AppMode.of(me.device.mode);
      // Just paired: its checklist comes before anything else.
      if (checklist) return location == '/checklist' ? null : '/checklist';
      final home = mode.staffSignIn && staff == null ? '/staff' : '/mode/${mode.path}';
      if (location == '/manage') return managerAccess ? null : home;
      if (location.startsWith('/manage/')) return null;
      if (location.startsWith('/staff')) return mode.staffSignIn && staff == null ? null : home;
      if (location == '/mode/${mode.path}') return home == location ? null : home;
      return home;
  }
}

/// Re-runs the redirect when the pairing, the person or management access
/// changes.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
    ref.listen(staffSessionControllerProvider, (_, _) => notifyListeners());
    ref.listen(managerAccessProvider, (_, _) => notifyListeners());
    ref.listen(deviceChecklistPendingProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(
      session: ref.read(sessionProvider),
      staff: ref.read(staffSessionControllerProvider),
      managerAccess: ref.read(managerAccessProvider),
      location: state.matchedLocation,
      checklist: ref.read(deviceChecklistPendingProvider),
    ),
    routes: [
      GoRoute(path: '/', builder: (_, _) => const _Splash()),
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: '/pair/scan', builder: (_, _) => const ScanScreen()),
      GoRoute(path: '/pair/manual', builder: (_, _) => const ManualPairScreen()),
      GoRoute(path: '/offline', builder: (_, _) => const OfflineScreen()),
      GoRoute(path: '/checklist', builder: (_, _) => const DeviceChecklistScreen()),
      GoRoute(path: '/staff', builder: (_, _) => const StaffPickerScreen(purpose: PinPurpose.signIn)),
      GoRoute(
        path: '/staff/pin/:id',
        builder: (_, state) => PinScreen(
          membershipId: state.pathParameters['id']!,
          name: state.extra is String ? state.extra! as String : '',
          purpose: PinPurpose.signIn,
        ),
      ),
      GoRoute(path: '/manage', builder: (_, _) => const ManageScreen()),
      GoRoute(path: '/manage/staff', builder: (_, _) => const StaffPickerScreen(purpose: PinPurpose.manage)),
      GoRoute(
        path: '/manage/pin/:id',
        builder: (_, state) => PinScreen(
          membershipId: state.pathParameters['id']!,
          name: state.extra is String ? state.extra! as String : '',
          purpose: PinPurpose.manage,
        ),
      ),
      _lazy(AppMode.waiter, waiter.loadLibrary, () => waiter.WaiterScreen()),
      _lazy(AppMode.kds, kds.loadLibrary, () => kds.KdsScreen()),
      _lazy(AppMode.expo, expo.loadLibrary, () => expo.ExpoScreen()),
      _lazy(AppMode.kiosk, kiosk.loadLibrary, () => kiosk.KioskScreen()),
      _lazy(AppMode.printStation, print_station.loadLibrary, () => print_station.PrintStationScreen()),
      _lazy(AppMode.owner, owner.loadLibrary, () => owner.OwnerScreen()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

/// Each mode is its own deferred library, loaded the first time it opens.
GoRoute _lazy(AppMode mode, Future<void> Function() load, Widget Function() build) => GoRoute(
      path: '/mode/${mode.path}',
      builder: (_, _) => _Deferred(load: load, build: build),
    );

class _Deferred extends StatefulWidget {
  const _Deferred({required this.load, required this.build});

  final Future<void> Function() load;
  final Widget Function() build;

  @override
  State<_Deferred> createState() => _DeferredState();
}

class _DeferredState extends State<_Deferred> {
  late final Future<void> _loaded = widget.load();

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _loaded,
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done ? widget.build() : const _Splash(),
      );
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'realtime.dart';
import 'session.dart';

part 'realtime_provider.g.dart';

/// The branch stream of the paired device, shared by every screen. Null
/// while not paired. Credentials are read at each connect, so a staff
/// session that starts or ends applies on the next reconnect.
@Riverpod(keepAlive: true)
ActionCableClient? realtime(Ref ref) {
  final session = ref.watch(sessionProvider).value;
  if (session is! Paired) return null;
  final credentials = ref.read(credentialsProvider);
  final client = ActionCableClient(
    uri: cableUri(session.serverUrl),
    protocols: () => deviceProtocols(
      credentials.deviceToken ?? '',
      staffSessionToken: credentials.staffSessionToken,
    ),
    identifier: {'channel': 'Spree::Pos::BranchChannel', 'branch_id': session.me.branch.id},
  );
  client.start();
  ref.onDispose(client.dispose);
  return client;
}

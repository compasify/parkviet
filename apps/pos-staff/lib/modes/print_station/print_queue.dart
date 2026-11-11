import 'package:pos_api/pos_api.dart';

import '../../core/api_client.dart';

/// The station's side of the server queue.
abstract interface class PrintQueue {
  /// The next job of a printer bound to this station, or null.
  Future<PrintJobClaim?> claim();

  /// How one attempt ended. Repeating it is safe.
  Future<void> report(String jobId, {required int attempt, required bool printed, String? error});
}

class ApiPrintQueue implements PrintQueue {
  const ApiPrintQueue(this.client);

  final PosApiClient client;

  @override
  Future<PrintJobClaim?> claim() async {
    final response = await client.call((api) => api.posDevicePrintClaim());
    return response.data;
  }

  @override
  Future<void> report(String jobId, {required int attempt, required bool printed, String? error}) async {
    await client.call((api) => api.posDevicePrintReport(
          id: jobId,
          posDevicePrintReportRequest: PosDevicePrintReportRequest((b) => b
            ..attempt = attempt
            ..status = printed
                ? PosDevicePrintReportRequestStatusEnum.printed
                : PosDevicePrintReportRequestStatusEnum.failed
            ..error = error == null || error.length <= 500 ? error : error.substring(0, 500)),
        ));
  }
}

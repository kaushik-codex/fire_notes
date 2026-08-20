import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  final FirebasePerformance _performance;

  PerformanceService({FirebasePerformance? performance})
      : _performance = performance ?? FirebasePerformance.instance;

  /// Wraps any asynchronous operation in a custom performance trace.
  Future<T> traceOperation<T>({
    required String traceName,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
  }) async {
    final Trace trace = _performance.newTrace(traceName);
    await trace.start();

    if (attributes != null) {
      attributes.forEach((key, value) {
        trace.putAttribute(key, value);
      });
    }

    try {
      final result = await operation();
      return result;
    } finally {
      await trace.stop();
    }
  }
}
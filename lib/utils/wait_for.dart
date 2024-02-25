// import 'dart:async';

// T waitFor<T>(Future<T> future, {Duration? timeout}) {
//   T? result;
//   var futureCompleted = false;
//   Object? error;
//   StackTrace? stacktrace;
//   future.then(
//     (r) {
//       futureCompleted = true;
//       result = r;
//     },
//     onError: (Object e, StackTrace st) {
//       error = e;
//       stacktrace = st;
//     },
//   );

//   Stopwatch? s;
//   if (timeout != null) {
//     s = Stopwatch()..start();
//   }
//   Timer.run(() {}); // Enusre there is at least one message.
//   while (!futureCompleted && (error == null)) {
//     // print('$result, $error');
//     // Duration remaining;
//     if (timeout != null) {
//       if (s!.elapsed >= timeout) {
//         throw TimeoutException('waitFor() timed out', timeout);
//       }
//       // remaining = timeout - s.elapsed;
//     }
//     v();
//     // _WaitForUtils.waitForEvent(timeout: remaining);
//   }
//   if (timeout != null) {
//     s!.stop();
//   }
//   Timer.run(() {}); // Ensure that previous calls to waitFor are woken up.

//   if (error != null) {
//     throw AsyncError(error!, stacktrace);
//   }

//   return result as T;
// }

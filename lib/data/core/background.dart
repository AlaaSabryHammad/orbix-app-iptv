import 'dart:isolate';

/// Runs top-level [fn] with [arg] in a short-lived isolate.
///
/// Prefer this over `Isolate.run(() => …)` inside async methods: such a
/// closure can capture its enclosing async state, which is not sendable and
/// only fails at runtime. Here only [fn] (top-level / static) and [arg] cross.
/// The result returns via `Isolate.exit`, without copying.
Future<R> runInBackground<A, R>(R Function(A arg) fn, A arg) => Isolate.run(_Task<A, R>(fn, arg).call);

class _Task<A, R> {
  const _Task(this.fn, this.arg);

  final R Function(A) fn;
  final A arg;

  R call() => fn(arg);
}

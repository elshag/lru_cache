import '../data_structures/lru_cache.dart';
import '../models/cache_node.dart';

class OperationLogEntry {
  const OperationLogEntry({
    required this.operation,
    required this.resultText,
    required this.cacheStateText,
  });

  final String operation;
  final String resultText;
  final String cacheStateText;
}

class WorkloadRunResult {
  const WorkloadRunResult({
    required this.entries,
    required this.finalState,
    required this.stats,
  });

  final List<OperationLogEntry> entries;
  final List<CacheNode> finalState;
  final CacheStats stats;
}

class VerificationResult {
  const VerificationResult({
    required this.passed,
    required this.expectedFinalStateText,
    required this.actualFinalStateText,
    required this.details,
  });

  final bool passed;
  final String expectedFinalStateText;
  final String actualFinalStateText;
  final String details;
}

String formatCacheStateMostRecentFirst(List<CacheNode> nodes) {
  if (nodes.isEmpty) return '(empty)';
  return nodes.map((n) => '${n.key}:${n.value}').join('  →  ');
}

OperationLogEntry processOperation(LruCache cache, String operationLine) {
  final raw = operationLine.trim();
  if (raw.isEmpty) {
    return OperationLogEntry(
      operation: '',
      resultText: 'SKIP empty line',
      cacheStateText: formatCacheStateMostRecentFirst(cache.snapshotMostRecentFirst()),
    );
  }

  final parts = raw.split(RegExp(r'\s+'));
  final op = parts.first.toLowerCase();

  if (op == 'put') {
    if (parts.length != 3) {
      return OperationLogEntry(
        operation: raw,
        resultText: 'ERROR expected: put <key:int> <value:int>',
        cacheStateText: formatCacheStateMostRecentFirst(cache.snapshotMostRecentFirst()),
      );
    }
    final k = int.tryParse(parts[1]);
    final v = int.tryParse(parts[2]);
    if (k == null || v == null) {
      return OperationLogEntry(
        operation: raw,
        resultText: 'ERROR key/value must be integers',
        cacheStateText: formatCacheStateMostRecentFirst(cache.snapshotMostRecentFirst()),
      );
    }
    cache.put(k, v);
    return OperationLogEntry(
      operation: raw,
      resultText: 'OK',
      cacheStateText: formatCacheStateMostRecentFirst(cache.snapshotMostRecentFirst()),
    );
  }

  if (op == 'get') {
    if (parts.length != 2) {
      return OperationLogEntry(
        operation: raw,
        resultText: 'ERROR expected: get <key:int>',
        cacheStateText: formatCacheStateMostRecentFirst(cache.snapshotMostRecentFirst()),
      );
    }
    final k = int.tryParse(parts[1]);
    if (k == null) {
      return OperationLogEntry(
        operation: raw,
        resultText: 'ERROR key must be an integer',
        cacheStateText: formatCacheStateMostRecentFirst(cache.snapshotMostRecentFirst()),
      );
    }
    final value = cache.getValue(k);
    return OperationLogEntry(
      operation: raw,
      resultText: value.toString(),
      cacheStateText: formatCacheStateMostRecentFirst(cache.snapshotMostRecentFirst()),
    );
  }

  return OperationLogEntry(
    operation: raw,
    resultText: 'ERROR unknown operation "$op" (use put/get)',
    cacheStateText: formatCacheStateMostRecentFirst(cache.snapshotMostRecentFirst()),
  );
}

WorkloadRunResult runWorkload(LruCache cache, String workloadText) {
  final lines = workloadText.split(RegExp(r'\r?\n'));
  final out = <OperationLogEntry>[];
  for (final line in lines) {
    final entry = processOperation(cache, line);
    if (entry.operation.isEmpty) continue;
    out.add(entry);
  }
  return WorkloadRunResult(
    entries: List<OperationLogEntry>.unmodifiable(out),
    finalState: List<CacheNode>.unmodifiable(cache.snapshotMostRecentFirst()),
    stats: cache.stats,
  );
}

VerificationResult verifyBuiltInSequence({int capacity = 2}) {
  final cache = LruCache(capacity: capacity);

  const workload = <String>[
    'put 1 10',
    'put 2 20',
    'get 1',
    'put 3 30',
  ];

  for (final line in workload) {
    processOperation(cache, line);
  }

  final actual = cache.snapshotMostRecentFirst();
  final actualText = formatCacheStateMostRecentFirst(actual);
  const expectedText = '3:30  →  1:10';

  final passed = actualText == expectedText &&
      cache.getValue(2) == -1 &&
      cache.getValue(1) == 10 &&
      cache.stats.cacheHits >= 2;

  return VerificationResult(
    passed: passed,
    expectedFinalStateText: expectedText,
    actualFinalStateText: actualText,
    details: passed
        ? 'PASS'
        : 'FAIL: expected final state "$expectedText", got "$actualText". '
            'Also check: get(2) should be -1 after eviction.',
  );
}


import 'package:flutter/material.dart';

import '../../data_structures/lru_cache.dart';
import '../../logic/workload_runner.dart';

class CachePlaygroundPage extends StatefulWidget {
  const CachePlaygroundPage({super.key});

  @override
  State<CachePlaygroundPage> createState() => _CachePlaygroundPageState();
}

class _CachePlaygroundPageState extends State<CachePlaygroundPage> {
  final TextEditingController _capacityCtrl = TextEditingController(text: '3');
  final TextEditingController _keyCtrl = TextEditingController();
  final TextEditingController _valueCtrl = TextEditingController();
  final TextEditingController _workloadCtrl = TextEditingController(
    text: 'put 1 10\nput 2 20\nget 1\nput 3 30',
  );

  LruCache _cache = LruCache(capacity: 3);

  String _status = '';
  final List<OperationLogEntry> _log = <OperationLogEntry>[];
  VerificationResult? _verification;

  @override
  void dispose() {
    _capacityCtrl.dispose();
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    _workloadCtrl.dispose();
    super.dispose();
  }

  int? _tryParse(TextEditingController c) {
    final s = c.text.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  void _recreateCache() {
    final cap = _tryParse(_capacityCtrl) ?? 3;
    setState(() {
      _cache = LruCache(capacity: cap);
      _status = 'New cache with capacity ${_cache.capacity}';
      _log.clear();
      _verification = null;
    });
  }

  void _put() {
    final k = _tryParse(_keyCtrl);
    final v = _tryParse(_valueCtrl);
    if (k == null || v == null) {
      setState(() => _status = 'Enter integer key and value');
      return;
    }
    setState(() {
      _cache.put(k, v);
      _status = 'put($k, $v)';
      _log.add(
        OperationLogEntry(
          operation: 'put $k $v',
          resultText: 'OK',
          cacheStateText: formatCacheStateMostRecentFirst(
            _cache.snapshotMostRecentFirst(),
          ),
        ),
      );
    });
  }

  void _get() {
    final k = _tryParse(_keyCtrl);
    if (k == null) {
      setState(() => _status = 'Enter integer key');
      return;
    }
    final res = _cache.getValue(k);
    setState(() {
      _status = 'get($k) => $res';
      _log.add(
        OperationLogEntry(
          operation: 'get $k',
          resultText: res.toString(),
          cacheStateText: formatCacheStateMostRecentFirst(
            _cache.snapshotMostRecentFirst(),
          ),
        ),
      );
    });
  }

  void _runWorkload() {
    setState(() {
      _log.clear();
      final result = runWorkload(_cache, _workloadCtrl.text);
      _log.addAll(result.entries);
      _status = 'Workload finished: ${result.entries.length} operations';
    });
  }

  void _runVerification() {
    setState(() {
      _verification = verifyBuiltInSequence(capacity: _cache.capacity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _cache.snapshotMostRecentFirst();
    final evicted = _cache.evictedKeys;
    final stats = _cache.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LRU Cache Playground'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Manual controls', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _capacityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Capacity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _recreateCache,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Key',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(onPressed: _put, child: const Text('put')),
              ElevatedButton(onPressed: _get, child: const Text('get')),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Workload simulation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _workloadCtrl,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Operations (one per line): put k v | get k',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(onPressed: _runWorkload, child: const Text('Run workload')),
              ElevatedButton(
                onPressed: _runVerification,
                child: const Text('Verify built-in test'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_status, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          const SizedBox(height: 16),
          Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('total gets: ${stats.totalGets}'),
                  Text('hits: ${stats.cacheHits}'),
                  Text('misses: ${stats.cacheMisses}'),
                  Text('hit rate: ${stats.hitRatePercent.toStringAsFixed(2)}%'),
                  Text('total puts: ${stats.totalPuts}'),
                  Text('evictions: ${stats.evictionCount}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Operation log', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_log.isEmpty)
            const Text('(no operations yet)')
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: _log
                      .map(
                        (e) => ListTile(
                          dense: true,
                          title: Text(e.operation),
                          subtitle: Text('result: ${e.resultText}\ncache: ${e.cacheStateText}'),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Correctness verification',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _verification == null
                  ? const Text('Run “Verify built-in test” to see PASS/FAIL.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_verification!.details),
                        const SizedBox(height: 8),
                        Text('expected: ${_verification!.expectedFinalStateText}'),
                        Text('actual:   ${_verification!.actualFinalStateText}'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cache (MRU → LRU)  size=${_cache.size}  capacity=${_cache.capacity}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('(empty)')
          else
            ...items.map(
              (n) => ListTile(
                dense: true,
                title: Text('key=${n.key}  value=${n.value}'),
              ),
            ),
          const SizedBox(height: 16),
          Text('Evicted keys', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(evicted.isEmpty ? '(none)' : evicted.join(', ')),
          const SizedBox(height: 16),
          Text('Complexity (expected)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            '- get(key): O(1) average (hash lookup + O(1) move in linked list)\n'
            '- put(key, value): O(1) average (hash lookup/insert + O(1) add/evict)\n'
            '- space: O(capacity)',
          ),
        ],
      ),
    );
  }
}


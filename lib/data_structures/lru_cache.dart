import '../models/cache_node.dart';
import 'custom_hash_map.dart';
import 'doubly_linked_list.dart';

class CacheStats {
  const CacheStats({
    required this.totalGets,
    required this.cacheHits,
    required this.cacheMisses,
    required this.totalPuts,
    required this.evictionCount,
    required this.evictedKeys,
    required this.size,
    required this.capacity,
  });

  final int totalGets;
  final int cacheHits;
  final int cacheMisses;
  final int totalPuts;
  final int evictionCount;
  final List<int> evictedKeys;
  final int size;
  final int capacity;

  double get hitRatePercent => totalGets == 0 ? 0 : (cacheHits * 100.0) / totalGets;
}

class LruCache {
  LruCache({required int capacity})
      : _capacity = capacity < 1 ? 1 : capacity,
        _size = 0,
        _list = DoublyLinkedList(),
        _map = CustomHashMap(bucketCount: (capacity < 1 ? 1 : capacity) * 2 + 1);

  final int _capacity;
  int _size;
  final DoublyLinkedList _list;
  final CustomHashMap _map;

  final List<int> evictedKeys = <int>[];

  int _totalGets = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _totalPuts = 0;
  int _evictionCount = 0;

  int get capacity => _capacity;

  int get size => _size;

  CacheStats get stats => CacheStats(
        totalGets: _totalGets,
        cacheHits: _cacheHits,
        cacheMisses: _cacheMisses,
        totalPuts: _totalPuts,
        evictionCount: _evictionCount,
        evictedKeys: List<int>.unmodifiable(evictedKeys),
        size: _size,
        capacity: _capacity,
      );

  int getValue(int key) {
    _totalGets++;
    final node = _map.get(key);
    if (node == null) {
      _cacheMisses++;
      return -1;
    }
    _cacheHits++;
    _list.moveToFront(node);
    return node.value;
  }

  void put(int key, int value) {
    _totalPuts++;
    final existing = _map.get(key);
    if (existing != null) {
      existing.value = value;
      _list.moveToFront(existing);
      return;
    }

    if (_size >= _capacity) {
      final lru = _list.removeLeastRecent();
      if (lru != null) {
        _map.remove(lru.key);
        evictedKeys.add(lru.key);
        _evictionCount++;
        _size--;
      }
    }

    final node = CacheNode(key: key, value: value);
    _list.addToFront(node);
    _map.put(key, node);
    _size++;
  }

  List<CacheNode> snapshotMostRecentFirst() => _list.toListMostRecentFirst();
}


import '../models/cache_node.dart';
import '../models/hash_entry.dart';

class CustomHashMap {
  CustomHashMap({required int bucketCount})
      : _bucketCount = bucketCount < 1 ? 1 : bucketCount,
        _buckets = List<HashEntry?>.filled(bucketCount < 1 ? 1 : bucketCount, null);

  final int _bucketCount;
  final List<HashEntry?> _buckets;

  int _indexForKey(int key) {
    final idx = key % _bucketCount;
    return idx < 0 ? idx + _bucketCount : idx;
  }

  CacheNode? get(int key) {
    final idx = _indexForKey(key);
    var e = _buckets[idx];
    while (e != null) {
      if (e.key == key) return e.node;
      e = e.next;
    }
    return null;
  }

  void put(int key, CacheNode node) {
    final idx = _indexForKey(key);
    var e = _buckets[idx];
    while (e != null) {
      if (e.key == key) {
        e.node = node;
        return;
      }
      e = e.next;
    }

    final newEntry = HashEntry(key: key, node: node, next: _buckets[idx]);
    _buckets[idx] = newEntry;
  }

  bool remove(int key) {
    final idx = _indexForKey(key);
    HashEntry? prev;
    var cur = _buckets[idx];

    while (cur != null) {
      if (cur.key == key) {
        if (prev == null) {
          _buckets[idx] = cur.next;
        } else {
          prev.next = cur.next;
        }
        return true;
      }
      prev = cur;
      cur = cur.next;
    }

    return false;
  }
}


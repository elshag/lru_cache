import '../models/cache_node.dart';

class DoublyLinkedList {
  DoublyLinkedList() {
    _head.next = _tail;
    _tail.prev = _head;
  }

  final CacheNode _head = CacheNode(key: -1, value: -1);
  final CacheNode _tail = CacheNode(key: -1, value: -1);

  bool get isEmpty => _head.next == _tail;

  void addToFront(CacheNode node) {
    node.prev = _head;
    node.next = _head.next;
    _head.next!.prev = node;
    _head.next = node;
  }

  void remove(CacheNode node) {
    final p = node.prev;
    final n = node.next;
    if (p == null || n == null) return;
    p.next = n;
    n.prev = p;
    node.prev = null;
    node.next = null;
  }

  void moveToFront(CacheNode node) {
    remove(node);
    addToFront(node);
  }

  CacheNode? removeLeastRecent() {
    if (isEmpty) return null;
    final lru = _tail.prev!;
    remove(lru);
    return lru;
  }

  List<CacheNode> toListMostRecentFirst() {
    final out = <CacheNode>[];
    var cur = _head.next;
    while (cur != null && cur != _tail) {
      out.add(cur);
      cur = cur.next;
    }
    return out;
  }
}


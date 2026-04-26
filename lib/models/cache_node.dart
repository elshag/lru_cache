class CacheNode {
  CacheNode({required this.key, required this.value});

  final int key;
  int value;

  CacheNode? prev;
  CacheNode? next;

  @override
  String toString() => '($key → $value)';
}

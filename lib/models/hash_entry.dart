import 'cache_node.dart';

class HashEntry {
  HashEntry({required this.key, required this.node, this.next});

  final int key;

  CacheNode node;

  HashEntry? next;
}

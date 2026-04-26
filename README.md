# Project 12 — LRU Cache Implementation (Flutter + Dart)

## Brief description of the project
This project is a university-style data structures exam project that implements an **LRU (Least Recently Used) Cache** from scratch in Dart and demonstrates it in a small Flutter UI.

The app allows you to:
- manually run `put(key, value)` / `get(key)` operations
- run a multi-line **workload simulation** (`put 1 10`, `get 1`, …)
- view the cache state **MRU → LRU**
- view real cache **statistics** (hits/misses/hit rate, evictions)
- run a built-in **correctness verification** (expected vs actual, pass/fail)

## Goals
- **Implement LRU cache from scratch** (no built-in `Map` / `Queue` as the core engine).
- Achieve **O(1) average** time for `get` and `put` using the standard LRU design:
  - hash map for lookup
  - doubly linked list for recency ordering
- Support required edge cases:
  - capacity = 1
  - get from empty cache (returns `-1`)
  - repeated `put` with same key (updates value and becomes MRU)
  - eviction of LRU when capacity is full
  - correct cache statistics after operations
- Provide an exam-ready UI to visualize and defend the solution.

## Data structures and algorithms used
- **Custom doubly linked list** (`lib/data_structures/doubly_linked_list.dart`)
  - Stores nodes in **MRU → LRU** order.
  - Supports O(1) add-to-front, remove, move-to-front, and remove-least-recent.
- **Custom hash map (separate chaining)** (`lib/data_structures/custom_hash_map.dart`)
  - Buckets array + linked `HashEntry` chain for collisions.
  - Provides O(1) average key → node lookup and deletion.
- **LRU cache wrapper** (`lib/data_structures/lru_cache.dart`)
  - Combines hash map + doubly linked list to implement:
    - `getValue(key)` → value or `-1` (also moves item to MRU)
    - `put(key, value)` → insert/update (evicts LRU if full)
  - Tracks statistics: total gets, hits, misses, hit rate %, puts, evictions, evicted keys.
- **Workload simulation + verification** (`lib/logic/workload_runner.dart`)
  - Parses operations like `put 1 10` / `get 1`
  - Executes them step-by-step and produces an operation log
  - Runs a built-in verification sequence (expected vs actual final state)

## General approach
The LRU cache is implemented using the classic two-structure design:

1) **Hash map** maps `key → node reference` for O(1) average lookup.  
2) **Doubly linked list** maintains recency ordering for O(1) updates:
   - MRU is at the front
   - LRU is at the back

Operations:
- **get(key)**:
  - lookup node in the hash map
  - if found → move node to front (MRU), return value
  - if not found → return `-1`
- **put(key, value)**:
  - if key exists → update node value and move to front
  - else:
    - if cache is full → remove LRU node from list and delete its key from hash map
    - insert new node at front and add it to hash map

Complexities:
- **Time**: `get` = O(1) average, `put` = O(1) average  
- **Space**: O(capacity)

# Lens — performance (thresholds, N+1, memory)

Lens of `graph-woodpecker` for speed and memory. It folds in `graph-performance`. The pillar's
GATES step judges the code; this lens gives the numbers and the patterns to look for.

## Thresholds: pass / warn / critical

| Metric                            | Pass     | Warn       | Critical |
| --------------------------------- | -------- | ---------- | -------- |
| Build time                        | < 30 s   | 30 to 60 s | > 60 s   |
| JS bundle, landing page (gzip)    | < 150 KB | 150 to 250 KB | > 250 KB |
| JS bundle, app page (gzip)        | < 300 KB | 300 to 450 KB | > 450 KB |
| JS bundle, microsite (gzip)       | < 80 KB  | 80 to 130 KB | > 130 KB |
| CSS bundle                        | < 30 KB  | 30 to 50 KB | > 50 KB  |
| Event loop lag                    | < 10 ms  | 10 to 50 ms | > 50 ms  |
| Tool or API response (p95)        | < 200 ms | 200 to 500 ms | > 500 ms |
| RAG query latency                 | < 300 ms | 300 to 800 ms | > 800 ms |
| FCP                               | < 1.5 s  | 1.5 to 3.0 s | > 3.0 s  |
| LCP                               | < 2.5 s  | 2.5 to 4.0 s | > 4.0 s  |
| CLS                               | < 0.1    | 0.1 to 0.25 | > 0.25   |
| Regression against baseline       | < 10%    | 10 to 20%  | > 20%    |

## Algorithm budget by input size

| Input size | Acceptable               | Examples                              |
| ---------- | ------------------------ | ------------------------------------- |
| n < 100    | O(n²) is fine            | Nested loops over small lists         |
| n < 1 K    | O(n²) acceptable; prefer O(n log n) | Insertion sort, simple join |
| n < 100 K  | O(n log n) required      | Merge sort, binary search, heaps      |
| n ≥ 100 K  | O(n) or O(n log n) only  | Hash lookups, BFS/DFS                 |

Rule of thumb: if the inner and outer loops both touch n items, check that n < 1 K or replace
the inner loop with a hash lookup.

## N+1 queries

Detection signal: a store or database call inside `for`, `forEach` or `map`, such as
`store.getNodeById()` or `db.prepare().get()`.

Fix by batching into one call:

```ts
const nodes = await store.getNodesByIds(tasks.map((t) => t.nodeId)) // one query
const byId = new Map(nodes.map((n) => [n.id, n]))
for (const task of tasks) task.node = byId.get(task.nodeId)
```

In SQLite via better-sqlite3, use one `IN` clause:

```ts
const placeholders = ids.map(() => '?').join(',')
const rows = db.prepare(`SELECT * FROM nodes WHERE id IN (${placeholders})`).all(...ids)
```

When callers are spread across the code and cannot be co-located, a DataLoader-style batcher
collects the individual `load(id)` calls into one query per tick.

## Memory

- **Leak signal:** `heapUsed` rising for 10 minutes or more without GC reclaim. Confirm with a
  heap snapshot taken before and after the suspect action, sorted by retained size. Look for
  growing arrays, Maps and EventEmitter entries.
- **Unbounded caches:** a cache without `maxSize` or a TTL, or a Map or Set whose `.size` only
  grows, has no eviction policy.
- **Unpaired resources:** `on()` without `off()`, and `fs.open()` without `close()`.

## Build and bundle

- Build: `time npm run build`. Flag anything over 60 s.
- Bundle: `du -sh dist/` against the table above. Look for duplicated packages and for code
  that tree-shaking failed to remove.

## Web Vitals (UI work only)

FCP under 1.5 s, LCP under 2.5 s, CLS under 0.1, TTI under 3.9 s. Measure with Playwright
through `performance.getEntriesByType('navigation')`.

## Economy and benchmarks

- `agf metrics --economy-report` shows tokens, cost and cache hits.
- `agf eval --gate` fails when cost regresses more than 10% against the committed baseline.
- This repo has no latency benchmark script. Create one before gating on latency numbers,
  because a regression threshold with no benchmark cannot be measured.

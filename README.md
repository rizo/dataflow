# IO – Compositional Communication Model

_Work in progress_

Simple, secure and composable abstraction for efficient stream processing in a purely functional fashion.

This library implements flow-based programming primitives for data processing. An application can be viewed as a network of asynchronous processes, called _nodes_, communicating by means of streams of structured data chunks.

Each node can be in three different states:

- **`Yield (o  * next)`** – producing values for downstream.
- **`Await (i -> next)`** – awaiting for values from upstream.
- **`Ready r`** - returning a final result of computation.

The communication between nodes is described in the following diagram:

```

      +---------+       +---------+       +---------+
      |         |       |         |       |         |
 ... --> node0 -->  i  --> node1 -->  o  --> nnde2 --> ...
      |         |       |         |       |         |
      +----|----+       +----|----+       +----|----+
           v                 v                 v
          ...                r                ...

```


### Features

- Simple and extensible core model.
- First-class composable computations.
- Backend agnostic processing (sources and sinks may be data-structures, sockets, files, etc).
- Support for various kinds of communication patterns (`pair`, `reqrep`, `pubsub`, etc).
- Prompt finalization of resources.
- Early termination by downstream and notification of uptream termination.

## Examples

```ocaml

open IO.Seq

(* Produces a stream of integers from `start` to `stop. *)
let rec range start stop =
  count => take stop => drop start
  
(* Applies a function to each element of a stream. *)
let map f = forever (await >>= fun a -> yield (f a))

(* Identity stream, passes values downstream. *)
let cat = forever (await >>= yield)

(* Filters values of a stream using a predicate. *)
let rec filter pred =
  await >>= fun a ->
    if pred a then yield a >> lazy (filter pred)
    else filter pred

(* Compute the sum of all odd integers up to 1000000. *)
assert (range 1000000 => filter odd => fold (+) 0 = 250000000000);

(* Take 5 integers from an infinit sequence and collect them into a list. *)
assert (count => take 5 => collect = [1; 2; 3; 4; 5]);
```

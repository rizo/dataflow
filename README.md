# Modular Data Flows

<!--
[![Build Status](https://travis-ci.org/rizo/io.svg?branch=master)](https://travis-ci.org/rizo/io?branch=master)
-->

- Development relese: [`0.2.0`](https://github.com/rizo/io/tree/0.2.0)


This library implements flow-based programming primitives for stream processing in a purely functional fashion. An application can be viewed as a network of asynchronous processes, called _nodes_, communicating by means of streams of typed data chunks.

Each node can be in three different states:

- **`Yield`** – the node is producing values for downstream.
- **`Await`** – the node is awaiting values from upstream.
- **`Ready`** - the node is returning the final result of a computation.

The communication between nodes is described in the following diagram:

```

      +---------+       +---------+       +---------+
      |         |       |         |       |         |
 ... --> node0 -->  i  --> node1 -->  o  --> node2 --> ...
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
assert (fold ~init:0 ~f:(+) (iota 1000000 => filter odd) = 250000000000);

(* Take 5 integers from an infinit sequence and collect them into a list. *)
assert (collect (count => take 5) = [0; 1; 2; 3; 4]);

```

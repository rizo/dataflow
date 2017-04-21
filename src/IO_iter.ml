
open Elements
open IO_core

let rec count =
  let rec loop n =
    yield n >> lazy (loop (n + 1)) in
  loop 0

let map f =
  forever (await >>= fun a -> yield (f a))

let rec each f =
  await >>= fun a -> f a; each f

let rec filter f =
  await >>= fun a ->
  if f a then yield a >> lazy (filter f)
  else filter f

let rec filter_map f =
  await >>= fun a ->
  match f a with
  | Some a' -> yield a' >> lazy (filter_map f)
  | None    -> filter_map f

let take n =
  replicate n (await >>= yield)

let rec take_while pred =
  await >>= fun a ->
  if pred a then yield a >> lazy (take_while pred)
  else return ()

let rec drop n =
  if n = 0 then id
  else await >>= fun a -> drop (n - 1)

let rec drop_while pred =
  await >>= fun a ->
  if pred a then drop_while pred
  else id

let tail = Await (fun _ -> id)

let rec repeat ?n x =
  match n with
  | Some n -> replicate n (yield x)
  | None -> forever (yield x)

let rec iota stop =
  count >>> take stop

let range start stop =
  count >>> take stop >>> drop start

let slice i j =
  drop i >>> take (j - i)

let fold ~init ~f source =
  let rec loop source acc =
    match next source with
    | Some (a, rest) -> loop rest (f acc a)
    | None           -> acc in
  loop source init

let nth n source =
  if n < 0 then fail "nth: negative index"
  else
    let rec loop n source =
      match next source with
      | Some (a, rest) ->
        if n = 0 then Some a
        else loop (n - 1) rest
      | None -> None
    in loop n source

let head p =
  match next p with
  | Some (a, _) -> Some a
  | None        -> None

let sum source = fold ~init:0 ~f:(+) source
let length source = fold ~init:0 ~f:(fun c _ -> c + 1) source

let rec any source =
  match next source with
  | Some (a, _) when a -> a
  | Some (a, rest)     -> any rest
  | None               -> false

let last source =
  let rec loop last_opt source =
    match next source with
    | Some (a, rest) -> loop (Some a) rest
    | None           -> last_opt in
  loop None source

let rec list xs =
  match xs with
  | x::xs' -> yield x >> lazy (list xs')
  | []     -> return ()

let rec chan c =
  let rec loop () =
    match guard input_line c with
    | Some line -> yield line >> lazy (loop ())
    | None -> return () in
  loop ()

let rec file file_path =
  let c = open_in file_path in
  chan c >> lazy (return (close_in c))

let collect src =
  let rec loop src acc =
    match next src with
    | Some (a, rest) -> loop rest (a::acc)
    | None -> List.rev acc
  in loop src []

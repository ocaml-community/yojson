(* $Id$ *)

open Printf

let data =
  let l = ref [] in
  try
    while true do
      l := input_line stdin :: !l
    done;
    assert false
  with End_of_file -> String.concat "\n" (List.rev !l)

let n = 10_000

let yojson_loop () =
  for i = 1 to n do
    ignore (Yojson.Safe.from_string data)
  done

let jsonwheel_loop () =
  for i = 1 to n do
    ignore (Json_io.json_of_string data)
  done

let time msg f =
  let t1 = Unix.gettimeofday () in
  f ();
  let t2 = Unix.gettimeofday () in
  printf "%s: %.3f\n%!" msg (t2 -. t1)

let () =
  time "yojson" yojson_loop;
  time "json-wheel" jsonwheel_loop;
  time "yojson" yojson_loop;
  time "json-wheel" jsonwheel_loop

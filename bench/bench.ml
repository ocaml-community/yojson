open Core
open Core_bench

let data =
  In_channel.read_all "bench.json"

let yojson_data = Yojson.Safe.from_string data

(* chosen by fair dice roll, guaranteed to be large *)
let large = 10_000

let large_int_assoc = 
  let ints = List.init large ~f:(fun n ->
   (string_of_int n, `Int n))
  in
  `Assoc ints

let large_int_list = 
  let ints = List.init large ~f:(fun n -> `Int n) in
  `List ints

let large_string_list =
  let strings = List.init large ~f:(fun n ->
    `String (string_of_int n))
  in
  `List strings

let streamable_string =
  let buf = Buffer.create (large * 100) in
  for i = 1 to large do
    Printf.bprintf buf "%d\n" i
  done;
  Buffer.contents buf

let main () =
  Command.run (Bench.make_command [
    Bench.Test.create ~name:"JSON reading" (fun () ->
      ignore (Yojson.Safe.from_string data));
    Bench.Test.create ~name:"JSON writing" (fun () ->
      ignore (Yojson.Safe.to_string yojson_data));
    Bench.Test.create ~name:"JSON writing assoc" (fun () ->
      ignore (Yojson.Safe.to_string large_int_assoc));
    Bench.Test.create ~name:"JSON writing int list" (fun () ->
      ignore (Yojson.Safe.to_string large_int_list));
    Bench.Test.create ~name:"JSON writing string list" (fun () ->
      ignore (Yojson.Safe.to_string large_string_list));
    Bench.Test.create ~name:"JSON writing int list to channel" (fun () ->
      Out_channel.with_file "/dev/null" ~f:(fun oc ->
      ignore (Yojson.Safe.to_channel oc large_int_list)));
    Bench.Test.create ~name:"JSON writing string list to channel" (fun () ->
      Out_channel.with_file "/dev/null" ~f:(fun oc ->
      ignore (Yojson.Safe.to_channel oc large_string_list)));
    Bench.Test.create ~name:"JSON writing assoc to channel" (fun () ->
      Out_channel.with_file "/dev/null" ~f:(fun oc ->
      ignore (Yojson.Safe.to_channel oc large_int_assoc)));
    begin
      let buf = Buffer.create 1000 in
      Bench.Test.create ~name:"JSON stream roundtrip" (fun () ->
        let stream = Yojson.Safe.stream_from_string ~buf streamable_string in
        ignore (Yojson.Safe.stream_to_string ~buf stream)
      )
    end;
  ])

let () =
  main ()

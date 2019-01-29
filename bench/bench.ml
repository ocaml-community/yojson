open Core
open Core_bench

let data =
  In_channel.read_all "bench.json"

let yojson_data = Yojson.Safe.from_string data

let main () =
  Command.run (Bench.make_command [
    Bench.Test.create ~name:"JSON reading" (fun () ->
      ignore (Yojson.Safe.from_string data));
    Bench.Test.create ~name:"JSON writing" (fun () ->
      ignore (Yojson.Safe.to_string yojson_data));
  ])

let () =
  main ()

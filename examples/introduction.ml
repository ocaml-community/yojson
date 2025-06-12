(* Get a file as a string *)
let contents_of_file filename =
  let ch = open_in_bin filename in
    try
      let s = really_input_string ch (in_channel_length ch) in
        close_in ch;
        s
    with
      e -> close_in ch; raise e

(* JSON inline as a string *)
let json_string =
  {|{"Number" : 1,
     "String" : "two",
     "List": ["containing", "different", "types", 35.4]}|}

(* Print as parse tree *)
let print_parse_tree () =
  Format.printf "%a\n" Yojson.Safe.pp (Yojson.Safe.from_string json_string)
  
(* Print as JSON *)
let prettyprint () =
  Printf.printf "%s\n" (Yojson.Safe.pretty_to_string (Yojson.Safe.from_string json_string))

(* Read some JSON from a file, add up all numbers, and print. *)
let sum_floats = List.fold_left ( +. ) 0.

let rec sum_json : Yojson.Safe.t -> float = function
  | `Float f -> f
  | `Int i -> float_of_int i
  | `String _ -> 0.
  | `List l -> sum_floats (List.map sum_json l)
  | `Assoc l -> sum_floats (List.map sum_json (List.map snd l))
  | _ -> failwith "unexpected construct in sum_json"
  
let sum filename =
  Printf.printf "%f\n" (sum_json (Yojson.Safe.from_string (contents_of_file filename)))

(* Read some JSON from a file, reverse any lists in it, and write to file. *)
let rec reverse_json = function
  | `List l -> `List (List.rev (List.map reverse_json l))
  | `Assoc l -> `Assoc (List.map (fun (k, v) -> (k, reverse_json v)) l)
  | x -> x

let reverse in_filename out_filename =
  let json = reverse_json (Yojson.Safe.from_string (contents_of_file in_filename)) in
  let fh = open_out out_filename in
    output_string fh (Yojson.Safe.pretty_to_string json);
    close_out fh

let () =
  match Sys.argv with
  | [|_; "print_parse_tree"|] -> print_parse_tree ()
  | [|_; "prettyprint"|] -> prettyprint ()
  | [|_; "sum"; filename|] -> sum filename
  | [|_; "reverse"; in_filename; out_filename|] -> reverse in_filename out_filename
  | _ -> Printf.eprintf "yojson_example: unknown command line\n"

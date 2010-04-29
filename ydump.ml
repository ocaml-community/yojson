(* $Id$ *)

open Printf

let cat std in_file out_file =
  let ic =
    match in_file with
	`Stdin -> stdin
      | `File s -> open_in s
  in
  let oc =
    match out_file with
	`Stdout -> stdout
      | `File s -> open_out s
  in
  let finally () =
    if oc != stdout then
      close_out_noerr oc;
    if ic != stdin then
      close_in_noerr ic
  in
  try
    let x = Yojson.Safe.from_channel ic in
    Yojson.Safe.to_channel ~std oc x;
    finally ();
    true
  with e ->
    finally ();
    eprintf "Error:\n%s\n%!" (Printexc.to_string e);
    false


let parse_cmdline () =
  let out = ref None in
  let std = ref false in
  let options = [
    "-o", Arg.String (fun s -> out := Some s), 
    "<file>
          Output file";
    "-std", Arg.Set std,
    "
          Convert tuples and variants into standard JSON,
          refuse to print NaN and infinities";
  ]
  in
  let files = ref [] in
  let anon_fun s = 
    files := s :: !files
  in
  let msg =
    sprintf "Usage: %s [input file]" Sys.argv.(0)
  in
  Arg.parse options anon_fun msg;
  let in_file =
    match List.rev !files with
	[] -> `Stdin
      | [x] -> `File x
      | _ ->
	  eprintf "Too many input files\n%!";
	  exit 1
  in
  let out_file =
    match !out with
	None -> `Stdout
      | Some x -> `File x
  in
  !std, in_file, out_file


let () =
  let std, in_file, out_file = parse_cmdline () in
  let success = cat std in_file out_file in
  if success then
    exit 0
  else
    exit 1


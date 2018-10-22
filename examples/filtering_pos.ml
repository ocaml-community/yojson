(*
  ocamlfind ocamlopt -o filtering filtering.ml -package yojson -linkpkg
  ./filtering <<EOF
{
  "id": "398eb027",
  "name": "John Doe",
  "pages": [
    {
      "id": 1,
      "title": "The Art of Flipping Coins",
      "url": "http://example.com/398eb027/1"
    },
    { "id": 2, "deleted": true },
    {
      "id": 3,
      "title": "Artichoke Salad",
      "url": "http://example.com/398eb027/3"
    },
    {
      "id": 4,
      "title": "Flying Bananas",
      "url": "http://example.com/398eb027/4"
    }
  ]
}
EOF
*)

open Yojson.SafePos.Util

let show ?print:prfopt (pos, a) =
  let open Yojson.SafePos in
  let fnamestr =
    match pos.file_name with
    | None -> ""
    | Some(x) -> " in '" ^ x ^ "'"
  in
  let lnum1 = pos.start_line in
  let lnum2 = pos.end_line in
  let () =
    match prfopt with
    | None -> Printf.printf "*"
    | Some(prf) -> Printf.printf "%a" prf a
  in
  if lnum1 = lnum2 then
    Printf.printf " (line %d, column %d-%d%s)\n"
      lnum1 pos.start_column pos.end_column fnamestr
  else
    Printf.printf " (line %d column %d to line %d, column %d)\n"
      lnum1 pos.start_column lnum2 pos.end_column

let extract_titles json =
  let objs =
    [json]
      |> filter_member "pages"
      |> flatten
  in
  List.iter show objs;
  objs
    |> filter_member "title"
    |> filter_string_with_pos

let print_string chan =
  Printf.fprintf chan "%s"

let main () =
  let json = Yojson.SafePos.from_channel stdin in
  List.iter (show ~print:print_string) (extract_titles json)

let () = main ()

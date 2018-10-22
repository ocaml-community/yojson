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
open Format

let pp_position ppf pos =
  let open Yojson in
  let fnamestr =
    match pos.file_name with
    | None -> ""
    | Some(x) -> " in '" ^ x ^ "'"
  in
  let lnum1 = pos.start_line in
  let lnum2 = pos.end_line in
  if lnum1 = lnum2 then
    fprintf ppf "line %d, column %d-%d%s"
      lnum1 pos.start_column pos.end_column fnamestr
  else
    fprintf ppf "line %d column %d to line %d, column %d"
      lnum1 pos.start_column lnum2 pos.end_column

let print_with_pos ?pp:ppopt ((pos, _) as a) =
  match ppopt with
  | None -> printf "<json> (%a)@," pp_position pos
  | Some(pp) -> printf "%a (%a)@," pp a pp_position pos

let extract_titles json =
  let objs =
    [json]
      |> filter_member "pages"
      |> flatten
  in
  List.iter print_with_pos objs;
  objs
    |> filter_member "title"
    |> List.map to_string

let main () =
  printf "@[<v0>";
  begin
    try
      let json = Yojson.SafePos.from_channel stdin in
      List.iter (printf "%s@,") (extract_titles json);
    with
    | Yojson.SafePos.Util.Type_error(msg, json) ->
        printf "! [ERROR] %s:@," msg;
        printf "! ";
        print_with_pos ~pp:Yojson.SafePos.pretty_print json
  end;
  printf "@]"

let () = main ()

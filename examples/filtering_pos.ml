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

let extract_titles json =
  [json]
    |> filter_member "pages"
    |> flatten
    |> filter_member "title"
    |> filter_string_with_pos

let main () =
  let json = Yojson.SafePos.from_channel stdin in
  List.iter (fun (pos, s) ->
    let open Yojson.SafePos in
    let fnamestr =
      match pos.file_name with
      | None -> ""
      | Some(x) -> " in '" ^ x ^ "'"
    in
    let lnum1 = pos.start_line in
    let lnum2 = pos.end_line in
    if lnum1 = lnum2 then
      Printf.printf "%s (line %d, column %d-%d%s)\n"
        s lnum1 pos.start_column pos.end_column fnamestr
    else
      Printf.printf "%s (line %d column %d to line %d, column %d)\n"
        s lnum1 pos.start_column lnum2 pos.end_column
  ) (extract_titles json)

let () = main ()

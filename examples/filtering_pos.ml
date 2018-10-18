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
      | None
      | Some("") -> ""
      | Some(x) -> " in '" ^ x ^ "'"
    in
    Printf.printf "%s (starts from line %d, column %d%s)\n"
      s pos.start_line pos.start_column fnamestr
  ) (extract_titles json)

let () = main ()

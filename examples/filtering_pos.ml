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

let print_with_pos pp ((pos, _) as a) =
  printf "%a (%a)@," pp a pp_position pos

let pp_object ppf _ =
  fprintf ppf "<obj>"

let extract_titles json =
  let objs =
    [json]
      |> filter_member "pages"
      |> flatten
  in
  List.iter (print_with_pos pp_object) objs;
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
        print_with_pos Yojson.SafePos.pretty_print json
  end;
  printf "@]"

let () = main ()

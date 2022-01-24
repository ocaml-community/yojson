let to_string () =
  Alcotest.(check string) __LOC__ Fixtures.json_string (Yojson.Safe.to_string Fixtures.json_value)

let to_file () =
  let test ?newline () =
    let output_file = Filename.temp_file "test_yojson_to_file" ".json" in
    let correction = match newline with
        | None ->
          Yojson.Safe.to_file output_file Fixtures.json_value;
          Fixtures.json_string_newline
        | Some newline -> 
          Yojson.Safe.to_file ~newline output_file Fixtures.json_value;
          if newline then
            Fixtures.json_string_newline
          else
            Fixtures.json_string
    in
    let file_content =
      let ic = open_in output_file in
      let length = in_channel_length ic in
      let s = really_input_string ic length in
      close_in ic;
      s
    in
    Alcotest.(check string) __LOC__ correction file_content;
    Sys.remove output_file
  in
  test ();
  test ~newline:true ();
  test ~newline:false ()

let single_json = [
  "to_string", `Quick, to_string;
  "to_file", `Quick, to_file;
]

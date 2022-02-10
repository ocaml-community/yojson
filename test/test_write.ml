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

let stream_to_file () =
  let output_file = Filename.temp_file "test_yojson_stream_to_file" ".json" in
  let data = [`String "foo"; `String "bar"] in
  Yojson.Safe.stream_to_file output_file (Stream.of_list data);
  let read_data =
    let stream = Yojson.Safe.stream_from_file output_file in
    let acc = ref [] in
    Stream.iter (fun v -> acc := v :: !acc) stream;
    List.rev !acc
  in
  Sys.remove output_file;
  if data <> read_data then
    (* TODO: it would be nice to use Alcotest.check,
       but we don't have a 'testable' instance for JSON values. *)
    Alcotest.fail "stream_{to,from}_file roundtrip failure"

let single_json = [
  "to_string", `Quick, to_string;
  "to_file", `Quick, to_file;
  "stream_to_file", `Quick, stream_to_file;
]

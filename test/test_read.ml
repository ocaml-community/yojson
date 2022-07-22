let from_string () =
  Alcotest.(check Testable.yojson)
    __LOC__
    Fixtures.json_value
    (Yojson.Safe.from_string Fixtures.json_string)

let from_file () =
  let input_file = Filename.temp_file "test_yojson_from_file" ".json" in
  let oc = open_out input_file in
  output_string oc Fixtures.json_string;
  close_out oc;
  Alcotest.(check Testable.yojson) __LOC__ Fixtures.json_value (Yojson.Safe.from_file input_file);
  Sys.remove input_file

let unquoted_from_string () =
  Alcotest.(check Testable.yojson)
    __LOC__
    Fixtures.unquoted_value
    (Yojson.Safe.from_string Fixtures.unquoted_json)

let unquoted_from_lexbuf () =
  let lexbuf = Lexing.from_string "{foo: null, bar: null}" in
  let lexer_state = Yojson.init_lexer () in

  let ident_expected expectation reference start len =
    let identifier = String.sub reference start len in
    Alcotest.(check string)
      (Format.asprintf "Reference %s start %d len %d matches %s" reference start len expectation)
      expectation
      identifier;
    ()
  in
  let skip_over f =
    f lexer_state lexbuf
  in
  let map_ident f =
    Yojson.Safe.map_ident lexer_state f lexbuf
  in

  skip_over Yojson.Safe.read_lcurl;
  map_ident (ident_expected "foo");
  skip_over Yojson.Safe.read_colon;
  skip_over Yojson.Safe.read_space;
  skip_over Yojson.Safe.read_null;
  skip_over Yojson.Safe.read_comma;
  skip_over Yojson.Safe.read_space;
  map_ident (ident_expected "bar");
  skip_over Yojson.Safe.read_colon;
  skip_over Yojson.Safe.read_space;
  skip_over Yojson.Safe.read_null;

  (match Yojson.Safe.read_object_end lexbuf with
  | _ -> Alcotest.fail "Object end expected but did not happen"
  | exception Yojson.End_of_object -> ());

  (* successfully made it here, pass the test *)
  ()

let single_json = [
  "from_string", `Quick, from_string;
  "from_file", `Quick, from_file;
  "unquoted_from_string", `Quick, unquoted_from_string;
  "unquoted_from_lexbuf", `Quick, unquoted_from_lexbuf;
]

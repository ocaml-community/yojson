module M = struct
  include Yojson_json5.Safe

  let from_string s =
    match from_string s with
    | Ok t -> t
    | Error e -> raise (Yojson.Json_error e)
end

let yojson_json5 = Alcotest.testable M.pp M.equal

let test_from_string () =
  Alcotest.(check yojson_json5) "Empty object" (`Assoc []) (M.from_string "{}");
  Alcotest.(check yojson_json5) "Empty list" (`List []) (M.from_string "[]");
  Alcotest.(check yojson_json5)
    "List"
    (`List [ `Int 1; `String "2"; `Float 3. ])
    (M.from_string "[1, \"2\", 3.0]");
  Alcotest.(check yojson_json5) "true" (`Bool true) (M.from_string "true");
  Alcotest.(check yojson_json5) "false" (`Bool false) (M.from_string "false");
  Alcotest.(check yojson_json5) "null" `Null (M.from_string "null");
  Alcotest.(check yojson_json5)
    "double quotes string" (`String "hello world")
    (M.from_string {|"hello world"|});
  Alcotest.(check yojson_json5)
    "single quotes string" (`String "hello world")
    (M.from_string {|'hello world'|});
  Alcotest.(check yojson_json5)
    "float" (`Float 12345.67890)
    (M.from_string "12345.67890");
  Alcotest.(check yojson_json5) "hex" (`Int 0x1) (M.from_string "0x1");
  Alcotest.(check yojson_json5) "int" (`Int 1) (M.from_string "1");
  Alcotest.(check yojson_json5)
    "line break" (`String "foo\\\nbar")
    (M.from_string "\"foo\\\nbar\"");
  Alcotest.(check yojson_json5)
    "string and comment" (`String "bar")
    (M.from_string "\"bar\" //foo");
  let expected =
    `Assoc
      [
        ("unquoted", `String "and you can quote me on that");
        ("singleQuotes", `String "I can use \"double quotes\" here");
        ("lineBreaks", `String {|Look, Mom! \
No \\n's!|});
        ("hexadecimal", `Int 0xdecaf);
        ("leadingDecimalPoint", `Float 0.8675309);
        ("andTrailing", `Float 8675309.0);
        ("positiveSign", `Int 1);
        ("trailingComma", `String "in objects");
        ("andIn", `List [ `String "arrays" ]);
        ("backwardsCompatible", `String "with JSON");
      ]
  in
  Alcotest.(check yojson_json5)
    "More elaborated" expected
    (M.from_string
       {|{
  // comments
  unquoted: 'and you can quote me on that',
  singleQuotes: 'I can use "double quotes" here',
 lineBreaks: "Look, Mom! \
No \\n's!",
  hexadecimal: 0xdecaf,
  leadingDecimalPoint: .8675309, andTrailing: 8675309.,
  positiveSign: +1,
  trailingComma: 'in objects', andIn: ['arrays',],
  "backwardsCompatible": "with JSON",
}|})

let test_to_string () =
  Alcotest.(check string) "Empty object" "{}" (M.to_string (`Assoc []));
  Alcotest.(check string) "Empty list" "[]" (M.to_string (`List []));
  Alcotest.(check string) "true" "true" (M.to_string (`Bool true));
  Alcotest.(check string) "false" "false" (M.to_string (`Bool false));
  Alcotest.(check string) "null" "null" (M.to_string `Null);
  Alcotest.(check string)
    "string" "\"hello world\""
    (M.to_string (`String "hello world"));
  Alcotest.(check string) "float" "12345.6789" (M.to_string (`Float 12345.6789));
  Alcotest.(check string) "hex" "1" (M.to_string (`Int 0x1));
  Alcotest.(check string) "int" "1" (M.to_string (`Int 1))

(* Run it *)
let () =
  let open Alcotest in
  run "JSON5"
    [
      ( "from_string",
        [ test_case "reading from string" `Quick test_from_string ] );
      ("to_string", [ test_case "write to string" `Quick test_to_string ]);
    ]

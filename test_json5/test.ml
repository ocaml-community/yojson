module M = struct
  include Yojson_json5.Safe

  let from_string_err s =
    match from_string s with
    | Ok x ->
        failwith
          (Format.sprintf "Test didn't failed when should: %s" (to_string x))
    | Error e -> e

  let from_string s =
    match from_string s with
    | Ok t -> t
    | Error e -> raise (Yojson.Json_error e)
end

let yojson = Alcotest.testable M.pp M.equal

let parsing_test_case name expected input =
  Alcotest.test_case name `Quick (fun () ->
      Alcotest.check yojson name expected (M.from_string input))

let parsing_tests =
  [
    Alcotest.test_case "Unexpected line break" `Quick (fun () ->
        Alcotest.(check string)
          "string unescaped linebreak fails" "Unexpected character: "
          (M.from_string_err {|"foo
    bar"|}));
    parsing_test_case "Empty object" (`Assoc []) "{}";
    parsing_test_case "Empty list" (`List []) "[]";
    parsing_test_case "List"
      (`List [ `Int 1; `String "2"; `Float 3. ])
      {|[1, "2", 3.0]|};
    parsing_test_case "true" (`Bool true) "true";
    parsing_test_case "false" (`Bool false) "false";
    parsing_test_case "null" `Null "null";
    parsing_test_case "double quotes string" (`String "hello world")
      {|"hello world"|};
    parsing_test_case "single quotes string" (`String "hello world")
      {|'hello world'|};
    parsing_test_case "float" (`Float 12345.67890) "12345.67890";
    parsing_test_case "hex" (`Int 0x1) "0x1";
    parsing_test_case "hex escape sequence" (`String "a") {|"\x61"|};
    parsing_test_case "unicode escape sequence" (`String "λ") {|"\u03bb"|};
    parsing_test_case "more string escaping" (`String "Hello λ world")
      "\"Hello \\u03bb \\x77\\x6F\\x72\\x6C\\x64\"";
    parsing_test_case "null byte string" (`String "\x00") {|"\0"|};
    parsing_test_case "octal string" (`String "?") {|"\077"|};
    parsing_test_case "null and octal string" (`String "\x007") {|"\07"|};
    parsing_test_case "int" (`Int 1) "1";
    parsing_test_case "backslash escape" (`String {|foo\bar|}) {|"foo\\bar"|};
    parsing_test_case "line break" (`String "foobar") "\"foo\\\nbar\"";
    parsing_test_case "string and comment" (`String "bar") "\"bar\" //foo";
    parsing_test_case "object with double quote string"
      (`Assoc [ ("foo", `String "bar") ])
      {|{"foo": "bar"}|};
    parsing_test_case "object with single quote string"
      (`Assoc [ ("foo", `String "bar") ])
      {|{'foo': 'bar'}|};
    parsing_test_case "object with unquoted string"
      (`Assoc [ ("foo", `String "bar") ])
      {|{foo: 'bar'}|};
    (let expected =
       `Assoc
         [
           ("unquoted", `String "and you can quote me on that");
           ("singleQuotes", `String "I can use \"double quotes\" here");
           ("lineBreaks", `String {|Look, Mom! No \n's!|});
           ("hexadecimal", `Int 0xdecaf);
           ("leadingDecimalPoint", `Float 0.8675309);
           ("andTrailing", `Float 8675309.0);
           ("positiveSign", `Int 1);
           ("trailingComma", `String "in objects");
           ("andIn", `List [ `String "arrays" ]);
           ("backwardsCompatible", `String "with JSON");
         ]
     in
     parsing_test_case "More elaborated" expected
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
}|});
  ]

let writing_test_case name expected input =
  Alcotest.test_case name `Quick (fun () ->
      Alcotest.(check string) name expected (M.to_string input))

let writing_tests =
  [
    writing_test_case "Empty object" "{}" (`Assoc []);
    writing_test_case "Empty list" "[]" (`List []);
    writing_test_case "true" "true" (`Bool true);
    writing_test_case "false" "false" (`Bool false);
    writing_test_case "null" "null" `Null;
    writing_test_case "string" "\"hello world\"" (`String "hello world");
    writing_test_case "float" "12345.6789" (`Float 12345.6789);
    writing_test_case "hex" "1" (`Int 0x1);
    writing_test_case "int" "1" (`Int 1);
  ]

let () =
  Alcotest.run "JSON5"
    [ ("parsing", parsing_tests); ("writing", writing_tests) ]

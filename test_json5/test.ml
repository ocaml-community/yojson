module M = Yojson_json5.Safe

let yojson = Alcotest.testable M.pp M.equal

let parsing_test_case name expected input =
  Alcotest.test_case name `Quick (fun () ->
      (* any error message will do *)
      let any_string = Alcotest.testable Fmt.string (fun _ _ -> true) in
      Alcotest.(check (result yojson any_string))
        name expected (M.from_string input))

let parsing_should_succeed name expected input =
  parsing_test_case name (Ok expected) input

let parsing_should_fail name input =
  let failure = Error "<anything>" in
  parsing_test_case name failure input

let parsing_tests =
  [
    parsing_should_fail "Unexpected line break" {|"foo
    bar"|};
    parsing_should_succeed "Empty object" (`Assoc []) "{}";
    parsing_should_succeed "Empty list" (`List []) "[]";
    parsing_should_succeed "List"
      (`List [ `Int 1; `String "2"; `Float 3. ])
      {|[1, "2", 3.0]|};
    parsing_should_succeed "true" (`Bool true) "true";
    parsing_should_succeed "false" (`Bool false) "false";
    parsing_should_succeed "null" `Null "null";
    parsing_should_succeed "double quotes string" (`String "hello world")
      {|"hello world"|};
    parsing_should_succeed "single quotes string" (`String "hello world")
      {|'hello world'|};
    parsing_should_succeed "float" (`Float 12345.67890) "12345.67890";
    parsing_should_succeed "hex" (`Int 0x1) "0x1";
    parsing_should_succeed "hex escape sequence" (`String "a") {|"\x61"|};
    parsing_should_succeed "unicode escape sequence" (`String "λ") {|"\u03bb"|};
    parsing_should_succeed "more string escaping" (`String "Hello λ world")
      "\"Hello \\u03bb \\x77\\x6F\\x72\\x6C\\x64\"";
    parsing_should_succeed "null byte string" (`String "\x00") {|"\0"|};
    parsing_should_succeed "octal string" (`String "?") {|"\077"|};
    parsing_should_succeed "null and octal string" (`String "\x007") {|"\07"|};
    parsing_should_succeed "int" (`Int 1) "1";
    parsing_should_succeed "backslash escape" (`String {|foo\bar|})
      {|"foo\\bar"|};
    parsing_should_succeed "line break" (`String "foobar") "\"foo\\\nbar\"";
    parsing_should_succeed "string and comment" (`String "bar") "\"bar\" //foo";
    parsing_should_succeed "object with double quote string"
      (`Assoc [ ("foo", `String "bar") ])
      {|{"foo": "bar"}|};
    parsing_should_succeed "object with single quote string"
      (`Assoc [ ("foo", `String "bar") ])
      {|{'foo': 'bar'}|};
    parsing_should_succeed "object with unquoted string"
      (`Assoc [ ("foo", `String "bar") ])
      {|{foo: 'bar'}|};
    parsing_should_succeed "trailing comma in list"
      (`List [ `Int 1; `Int 2; `Int 3 ])
      "[1, 2, 3,]";
    parsing_should_fail "multiple trailing commas in list" "[1, 2, 3,]";
    parsing_should_fail "just trailing commas in list" "[,,,]";
    parsing_should_succeed "trailing comma in object"
      (`Assoc [ ("one", `Int 1) ])
      {|{"one": 1,}|};
    parsing_should_fail "multiple trailing commas in object" {|{"one": 1,,}|};
    parsing_should_fail "just trailing commas in object" "{,,,}";
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
     parsing_should_succeed "More elaborated" expected
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

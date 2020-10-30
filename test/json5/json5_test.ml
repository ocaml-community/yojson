module Lexer = Yojson_json5.Lexer
open Yojson_json5.Types

let tokenize_json5 (json_string) =
    let buf = Sedlexing.Utf8.from_string json_string in
    Lexer.lex [] buf

let token = Alcotest.testable pp_token equal_token

let test_float () =
    Alcotest.(check (list token)) "Simple" [FLOAT 23.52] (tokenize_json5 "23.52");
    Alcotest.(check (list token)) "No leading number" [FLOAT 0.52] (tokenize_json5 ".52");
    Alcotest.(check (list token)) "With exponent" [FLOAT 210.; FLOAT 210.] (tokenize_json5 "2.1e2 2.1E2")

let test_int_or_float () =
    Alcotest.(check (list token)) "Int or float" [INT_OR_FLOAT "42"] (tokenize_json5 "42")

let test_int () =
    Alcotest.(check (list token)) "Hex/Int" [INT 16] (tokenize_json5 "0x10")

let test_string () =
    Alcotest.(check (list token)) "Doublequoted simple" [STRING "\"hello\""] (tokenize_json5 "\"hello\"");
    Alcotest.(check (list token)) "Doublequoted single-character escape sequence" [STRING {|"\'\"\\\b\f\n\r\t\v"|}] (tokenize_json5 {|"\'\"\\\b\f\n\r\t\v"|});
    Alcotest.(check (list token)) "Doublequoted non-escape-character escape sequence" [STRING {|"\z"|}] (tokenize_json5 {|"\z"|});
    Alcotest.(check (list token)) "Doublequoted zero escape sequence" [STRING {|"\0"|}] (tokenize_json5 {|"\0"|});
    Alcotest.(check (list token)) "Doublequoted unicode escape" [STRING "\"\\uD83D\\uDC2A\""] (tokenize_json5 "\"\\uD83D\\uDC2A\"");
    Alcotest.(check (list token)) "Doublequoted line continuation" [STRING "\"hel\\\nlo\""] (tokenize_json5 "\"hel\\\nlo\"");
    Alcotest.(check (list token)) "Singlequoted simple" [STRING "'hello'"] (tokenize_json5 "'hello'");
    Alcotest.(check (list token)) "Singlequoted single-character escape sequence" [STRING {|'\'\"\\\b\f\n\r\t\v'|}] (tokenize_json5 {|'\'\"\\\b\f\n\r\t\v'|});
    Alcotest.(check (list token)) "Singlequoted non-escape-character escape sequence" [STRING {|'\z'|}] (tokenize_json5 {|'\z'|});
    Alcotest.(check (list token)) "Singlequoted zero escape sequence" [STRING {|'\0'|}] (tokenize_json5 {|'\0'|});
    Alcotest.(check (list token)) "Singlequoted unicode escape" [STRING "'\\uD83D\\uDC2A'"] (tokenize_json5 "'\\uD83D\\uDC2A'");
    Alcotest.(check (list token)) "Singlequoted line continuation" [STRING "'hel\\\nlo'"] (tokenize_json5 "'hel\\\nlo'");
    ()

let test_identifier () =
    Alcotest.(check (list token))
        "Identifer name in an object"
        [OPEN_BRACE; IDENTIFIER_NAME "hj"; COLON; INT_OR_FLOAT "42"; CLOSE_BRACE]
        (tokenize_json5 "{hj: 42}")

let test_multi_line_comments () =
    Alcotest.(check (list token)) "Simple case" [] (tokenize_json5 "/* hello\nworld */");
    Alcotest.(check (list token)) "Between numbers" [INT_OR_FLOAT "1"; INT_OR_FLOAT "1"] (tokenize_json5 "1/* hello\nworld */1");
    Alcotest.(check (list token)) "Empty" [INT_OR_FLOAT "1"; INT_OR_FLOAT "1"] (tokenize_json5 "1/**/1");
    Alcotest.(check (list token)) "Contains slash" [INT_OR_FLOAT "1"; INT_OR_FLOAT "1"] (tokenize_json5 "1/*/*/1");
    Alcotest.(check (list token)) "Contains asterisk" [INT_OR_FLOAT "1"; INT_OR_FLOAT "1"] (tokenize_json5 "1/***/1");
    Alcotest.(check (list token)) "Contains double asterisk" [INT_OR_FLOAT "1"; INT_OR_FLOAT "1"] (tokenize_json5 "1/****/1");
    Alcotest.check_raises "Contains comment end" (Failure "Unexpected character: ''") (fun () -> ignore @@ tokenize_json5 "/* */ */")

let test_single_line_comments () =
    Alcotest.(check (list token)) "Simple case" [] (tokenize_json5 "//foo\n");
    Alcotest.(check (list token)) "Between numbers" [INT_OR_FLOAT "1"; INT_OR_FLOAT "1"] (tokenize_json5 "1//foo\n1")

let () =
    let open Alcotest in
    run "JSON5" [
            "Numbers", [
                test_case "Float" `Quick test_float;
                test_case "Int or float" `Quick test_int_or_float;
                test_case "Int" `Quick test_int;
            ];
            "Strings", [
                test_case "String" `Quick test_string;
            ];
            "Objects", [
                test_case "Identifiers" `Quick test_identifier;
            ];
            "Comments", [
                test_case "Multi-line comments" `Quick test_multi_line_comments;
                test_case "Single-line comments" `Quick test_single_line_comments;
            ];
        ]

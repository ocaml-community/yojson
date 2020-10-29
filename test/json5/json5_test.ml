module Lexer = Yojson_json5.Lexer
open Yojson_json5.Types

type token_list = token list [@@deriving show, eq]

let () =
    let check_json (name, json_string, expected) =
        let buf = Sedlexing.Utf8.from_string json_string in
        let result = Lexer.lex buf in

        match equal_token_list result expected with
        | true -> ()
        | false ->
          let s = Format.asprintf "%s failed:\n\nInput:\n%a\n\nExpected:\n%a\n" name pp_token_list result pp_token_list expected in
          print_string s
    in

    let lexer_tests = [
        ("Float, no leading number", ".52", [FLOAT 0.52]);
        ("Float, simple", "23.52", [FLOAT 23.52]);
        ("Float with e & E", "2.1e2 2.1E2", [FLOAT 210.; SPACE; FLOAT 210.]);
        ("Int of float", "42", [INT_OR_FLOAT "42"]);
        ("Hex/Int", "0x10", [INT 16]);
        ("identifer name in an object", "{hj: 42}", [OPEN_BRACE; IDENTIFIER_NAME "hj"; COLON; SPACE; INT_OR_FLOAT "42"; CLOSE_BRACE]);
    ] in

    let _ = List.map check_json lexer_tests in
    ()

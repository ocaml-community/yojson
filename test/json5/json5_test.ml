module Lexer = Yojson_json5.Lexer
open Yojson_json5.Types

type token_list = token list [@@deriving show]


let () =
    let check_json (name, json_string, expected) =
        let lex_buffer = Lexing.from_string json_string in

        let rec loop lex_buf token_list =
            match Lexer.read_token lex_buf with
            | exception Failure _ -> token_list
            | token -> loop lex_buf (token::token_list)
        in
        let result = loop lex_buffer []
            |> List.rev
            |> show_token_list
        in
        let expected = show_token_list expected in
        if result <> expected then
            print_string @@ name ^ " failed:\n\nInput:\n" ^ result ^ "\n\nExpected:\n" ^ expected
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

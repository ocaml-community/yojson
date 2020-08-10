module Y = Yojson_json5

type token_list = Y.Types.token list [@@deriving show]

let () =
    let lex_buffer = Lexing.from_string "{}" in
    let result = Y.Lexer.read_token lex_buffer in
    Y.Types.show_token result
    |> print_endline;

    let result = Y.Lexer.read_token lex_buffer in
    Y.Types.show_token result
    |> print_endline

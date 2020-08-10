module Y = Yojson_json5

type token_list = Y.Types.token list [@@deriving show]

let () =
    let lex_buffer = Lexing.from_string "{[0x42e13]}" in

    let rec loop lex_buf token_list =
        match Y.Lexer.read_token lex_buf with
        | exception Failure _ -> token_list
        | token -> loop lex_buf (token::token_list)
    in

    let result = loop lex_buffer [] in
    List.rev result
    |> show_token_list
    |> print_endline;
